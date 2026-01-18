#!/usr/bin/perl -w

use Flat;
use math;
use Getopt::Std;

sub printUsage {
    print "Remove rows from the input file matching the specified patterns\n\n";
    print "Usage: ~ [-l a|o] <input.csv> <removed> <retained.csv> (<fld_index|fld_name> <re_ptn>)+\n\n";
    print "         -l\tlogical operations of the patterns: a -- and, o -- or (default)\n";
    print "         fld_index is 0 based\n\n";
    exit(1);
}

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("l:", \%options);
my $and = 0; # default: or

if(exists $options{"l"}) {
    my $opt = $options{"l"};

    if($opt eq "a") {
	$and = 1;
    }
    elsif($opt eq "o") {
	$and = 0;
    }
    else {
	printUsage();
    }
}

if((@ARGV) < 5 || scalar(@ARGV) % 2 != 1) {
    printUsage();
}

# read data from the file
my($in) = Flat->new1(shift @ARGV);
my $removed = shift @ARGV;
my($out) = shift @ARGV;

my(%fld2ptn);

for(my($i) = 0; $i < scalar(@ARGV); $i += 2) {
    my($fldNo) = $ARGV[$i];

    if(math::util::isNaN($ARGV[$i])) {
	$fldNo = $in->getFieldIndex($ARGV[$i]);
    }

    if($fldNo == -1) {
	die "Unknown field: $ARGV[$i]\n";
    }

    $fld2ptn{$fldNo} = $ARGV[$i + 1];
}

my $outTmp = "$out.tmp";

if($out eq "/dev/null") {
    $outTmp = $out;
}

open OUT, "+>$outTmp" or die "Cannot open $outTmp\n";

my $rmTmp = "$removed.tmp";

if($removed eq "/dev/null") {
    $rmTmp = $removed;
}

open RMD, "+>$rmTmp" or die "Cannot open $rmTmp\n";

my(@fldIndex) = sort keys %fld2ptn;
my(@fldNames) = $in->getFieldNames();

print RMD "# $cmdLine; removed.\n";
print OUT "# $cmdLine. retained.\n";

if($in->hasHeader() > 0) {
    print RMD join("\t", @fldNames), "\n";
    print OUT join("\t", @fldNames), "\n";
}

while($line = $in->readNextRow()) {
    my(@row) = @{$line};

    my($match);

    if($and) {
	$match = 1;
    }
    else { # or
	$match = 0;
    }

    foreach $fi (sort {$a <=> $b} keys %fld2ptn) {
	if($and) {
	    if($row[$fi] !~ /$fld2ptn{$fi}/) {
		$match = 0;
		last;
	    }
	}
	else { # or
	    if($row[$fi] =~ /$fld2ptn{$fi}/) {
		#print "$fi matched to $fld2ptn{$fi} at line ", $in->getRowIndex(), "\n";
		$match = 1;
		last;
	    }
	}
    }

    if($match) {
	print RMD join("\t", @row), "\n";
    }
    else {
	print OUT join("\t", @row), "\n";
    }
}

close RMD;
close OUT;

if($removed ne "/dev/null") {
    `mv $rmTmp $removed`;
}

if($outTmp ne $out) {
    `mv $outTmp $out`;
}
