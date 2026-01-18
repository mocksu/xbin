#!/usr/bin/perl -w

use Util;
use Getopt::Std;
my $cmdLine = Util::getCmdLine();

my(%options);
getopts("fsor", \%options);
my($firstSorted) = (exists $options{"f"});
my($secondSorted) = (exists $options{"s"});
my($overlap) = (exists $options{"o"});
my($resort) = exists $options{"r"}?"-r":"";

if(scalar(@ARGV) != 9) {
    print "Usage: ~ [-f] [-s] [-o] [-r] <first.csv> <chr[:rename]> <start[:rename]> <end[:rename]> <second.csv> <chr[:rename]> <start[:rename]> <end[:rename]> <out.bed>\n\n";
    print "       -f the first file is already sorted by coordinates.\n";
    print "       -s the second file is already sorted by coordinates.\n";
    print "       -r resort the coordinate files\n";
    print "       -o give overlapping boundaries in the output\n";
    print "       print the overlapped entries in <inner.csv> & <u.genes.withRefseqIDs.longestTx.50k.50k.bed>\n";
    print "       assuming each <start> is <= <end>\n\n";
    exit(1);
}

use Flat;
use Util;
use math;
use Coords;

my $iFile = shift @ARGV;
my($inner) = Flat->new1($iFile);
my($ichr, $ichrName) = @{$inner->getFieldIndexAndName(shift @ARGV)};
my($istart, $istartName) = @{$inner->getFieldIndexAndName(shift @ARGV)};
my($iend, $iendName) = @{$inner->getFieldIndexAndName(shift @ARGV)};
my $oFile = shift @ARGV;
my($outer) = Flat->new1($oFile);
my($ochr, $ochrName) = @{$outer->getFieldIndexAndName(shift @ARGV)};
my($ostart, $ostartName) = @{$outer->getFieldIndexAndName(shift @ARGV)};
my($oend, $oendName) = @{$outer->getFieldIndexAndName(shift @ARGV)};

my($out) = shift @ARGV;
open OUT, "+>$out.tmp" or die "Cannot open $out\n";
print OUT "# $cmdLine\n";

if($inner->hasHeader() && $outer->hasHeader()) {
    my @iFldNames = $inner->getFieldNames();
    $iFldNames[$ichr] = $ichrName;
    $iFldNames[$istart] = $istartName;
    $iFldNames[$iend] = $iendName;
    my @oFldNames = $outer->getFieldNames();
    $oFldNames[$ochr] = $ochrName;
    $oFldNames[$ostart] = $ostartName;
    $oFldNames[$oend] = $oendName;

    my(@olFldNames) = ();

    if($overlap) {
	@olFldNames = ("OVERLAP_START", "OVERLAP_END");
    }

    print OUT join("\t", @iFldNames, @oFldNames, @olFldNames), "\n";
}

# sort the inner and outer files based on (chr, start, end)
if($resort || !$firstSorted) {
    my($_ichr, $_istart, $_iend) = ($ichr + 1, $istart + 1, $iend + 1);
    Util::run("FlatSort.pl $resort \"-k $_ichr,$_ichr"."d -k $_istart,$_istart"."n -k $_iend,$_iend"."n\" $iFile $iFile.sorted", 1);
    $inner = Flat->new1("$iFile.sorted");
}

if($resort || !$secondSorted) {
    my($_ochr, $_ostart, $_oend) = ($ochr + 1, $ostart + 1, $oend + 1);
    Util::run("FlatSort.pl $resort \"-k $_ochr,$_ochr"."d -k $_ostart,$_ostart"."n -k $_oend,$_oend"."n\" $oFile $oFile.sorted", 1);
    $outer = Flat->new1("$oFile.sorted");
}

my(@orows);

while($irow = $inner->readNextRow()) {
    my $orowIndex = -1;
    my $overRead = 0;

    # check if entries can be found in the already read @orows
#    print "irow = ", Flat::dataRowToString(@{$irow}), "\n";

    for(my($i) = 0; $i < scalar(@orows); $i++) {
	my $cmpCoords = cmpCoords($irow->[$ichr], $irow->[$istart], $irow->[$iend],
				  $orows[$i][$ochr], $orows[$i][$ostart], $orows[$i][$oend]);

#	print "orows[$i] = @{$orows[$i]}, cmpCoords = $cmpCoords\n";

	if($cmpCoords > 0) { # not reached the point yet, continue to read
	    $orowIndex = $i;
	    next;
	}
	elsif($cmpCoords == 0) {
	    # update the start row index of outer data
	    if($orowIndex == -1) {
		$orowIndex = $i;
	    }
	    # print the intersect
	    
	    my(@olCoords) = ();

	    if($overlap) {
		my $olReg = Coords::getOverlapOfRegions($irow->[$ichr], $irow->[$istart], $irow->[$iend],
							$orows[$i]->[$ochr], $orows[$i]->[$ostart], $orows[$i]->[$oend]);
		@olCoords = ($olReg->[1], $olReg->[2]);
	    }

	    print OUT Flat::dataRowToString(@{$irow}, @{$orows[$i]}, @olCoords), "\n";
	}
	else { # cmpCoords < 0; overread
	    $overRead = 1;
	    last;
	}
    }

    # update @orows
#    print "orowIndex = $orowIndex, overread = $overRead\n";

    splice(@orows, 0, $orowIndex);

    if($overRead) { # overread in @orows already, not need to read down
	next;
    }
    # else continue check unread lines

    while($orow = $outer->readNextRow()) {
	push @orows, $orow;
	       
	my $cmpCoords = cmpCoords($irow->[$ichr], $irow->[$istart], $irow->[$iend],
				  $orow->[$ochr], $orow->[$ostart], $orow->[$oend]);
	
#	print "orow = @{$orow}, cmpCoords = $cmpCoords\n";

	if($cmpCoords == 0) {
	    my(@olCoords) = ();
	    
	    if($overlap) {
		my $olReg = Coords::getOverlapOfRegions($irow->[$ichr], $irow->[$istart], $irow->[$iend],
							$orow->[$ochr], $orow->[$ostart], $orow->[$oend]);
		@olCoords = ($olReg->[1], $olReg->[2]);
	    }

	    print OUT Flat::dataRowToString(@{$irow}, @{$orow}, @olCoords), "\n";
	}
	elsif($cmpCoords < 0) { # over-read, stop
	    last;
	}
	else { #$cmpCoords > 0, too early, continue reading
	    @orows = (); # 
	}
    }
}

# compare segment 1 & 2. if segment 1 lies before 2, return -1; if intersects, 0; after, 1.
sub cmpCoords {
    my($chr1, $start1, $end1, $chr2, $start2, $end2) = @_;

    my $chrCmp = $chr1 cmp $chr2;

    if($chrCmp != 0) {
	return $chrCmp;
    }

    my($left1) = math::util::min($start1, $end1);
    my($right1) = math::util::max($start1, $end1);
    my($left2) = math::util::min($start2, $end2);
    my($right2) = math::util::max($start2, $end2);

    my($left) = math::util::max($left1, $left2);
    my($right) = math::util::min($right1, $right2);

    if($left <= $right) {
	return 0;
    }
    elsif($end1 < $start2) {
	return -1;
    }
    else { #($start1 > $end2) {
	return 1;
    }
}
    
close OUT;

`mv $out.tmp $out`;
