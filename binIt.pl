#!/usr/bin/perl -w

# bin the input data file on the specified field, sum or concatenate other fields
if(scalar(@ARGV) < 3) {
    print "Usage: ~ [-s <sum|mean>] [-n min_val] [-x max_val] <input.csv> <fld_no> <bin_size>\n";
    print "\tinput.csv\tthe input data file to be binned\n";
    print "\tfld_no\tthe number of the field (0 based) to be binned\n";
    print "\tbin_size\tthe size of bin of the specified field\n";
    print "\tsum|mean\tsum -- sum or average the values within the bin (default)\n";
    print "\t\t\tmean -- average the values within the bin\n";
    exit(1);
}

use Flat;
use Getopt::Std;

my(%options);
getopts("s:n:x:", \%options);
my($stat) = $options{"s"};
my($min) = $options{"n"};
my($max) = $options{"x"};

my($infile) = $ARGV[0];
my($fldNo) = Flat->new1($infile)->getFieldIndex($ARGV[1]);
my($binSize) = $ARGV[2];

#print "min = $min, stat = $stat, infile = $infile, fldNo = $fldNo, binSize = $binSize\n";

if(!$stat) {
    $stat = 'sum';
}

use math;

if(math::util::NaN($fldNo) || math::util::NaN($binSize)) {
    die "binIt.pl -- All should be numeirc: fldNo = $fldNo, binSize = $binSize\n";
}

my(@fldNames, $numOfFlds, @colData, $numOfRows, %binNo2rows, @fldIsNumeric);

# check to see if there is a header line
my($firstLine) = `head -1 $infile`;
chomp($firstLine);

my($with_header) = 0;

my(@pieces) = split(/\t/, $firstLine, -1);
    
$numOfFlds = scalar(@pieces);
@fldIsNumeric = (1) x $numOfFlds;

if($firstLine =~ /fld/i) {
    $with_header = 1;
}
else {
    my($numFound) = 0;
    
    foreach $p (@pieces) {
	if(!math::util::NaN($p)) { # is some field is a pure number, it's not a header
	    $with_header = 0;
	    $numFound = 1;
	    last;
	}
    }
    
    if(!$numFound) {
	$with_header = 1;
    }
}

# sort the input file by the specified field
my($unixFldNo) = $fldNo + 1;

`sort $infile -n -k $unixFldNo > $infile.sorted`;

open IN, "<$infile.sorted" or die "Cannot open file $infile.sorted\n";

if($with_header) {
    $line = <IN>;
    chomp($line);

    @fldNames = split(/\t/, $line, -1);
}
else {
    @fldNames = ();
}

# find min max if not specified
if(!$min || !$max) {
    my $pos = tell IN;

    while($line = <IN>) {
	chomp($line);
	
	my(@row) = split(/\t/, $line, -1);
	push @colData, $row[$fldNo];
    }

    if(!$min) {
	$min = math::util::getMin(@colData);
    }

    if(!$max) {
	$max = math::util::getMax(@colData);
    }

    seek IN, $pos, 0;
}

if(scalar(@fldNames) > 0) {
    print "$fldNames[0]";

    for(my($j) = 1; $j < $numOfFlds; $j++) {
	print "\t$fldNames[$j]";
    }

    print "\n";
}

my(@binCols) = (); # binned column data
my($binNum) = 0;

while($line = <IN>) {
    chomp($line);

    my @row = split(/\t/, $line, -1);
    
    if(math::util::NaN($row[$fldNo])) {
#	warn "colData[$i] = $colData[$i] is not a number\n";
	next;
    }

    my $curBinNum = int(($row[$fldNo] - $min) / $binSize);

    if($curBinNum > $binNum) {
	$binNum = $curBinNum;

	if(scalar(@binCols) > 0) {
	    # print whatever is in @binCols	
	    my(@binnedVals) = map { getStat($_) } @binCols;
	    $binnedVals[$fldNo] = $binCols[$fldNo][0]; # do not sum or whatever to the binned field
	    
	    print Flat::dataRowToString(@binnedVals), "\n";
	    @binCols = ();
	}
    }

    for(my($i) = 0; $i < $numOfFlds; $i++) {
	push @{$binCols[$i]}, $row[$i];
    }

}

close IN;

# print the last bin
my(@binnedVals) = map { getStat($_) } @binCols;
$binnedVals[$fldNo] = $binCols[$fldNo][0]; # do not sum or whatever to the binned field
print Flat::dataRowToString(@binnedVals), "\n";

sub getStat {
    my($arr) = @_;

    my(@vals) = @{$arr};

    my $isNum = 1;

    foreach $v (@vals) {
	if(math::util::isVirtuallyNaN($v)) {
	    $isNum = 0;
	    last;
	}
    }

    my $result;

    if($isNum) {
	if($stat eq 'mean') {
	    $result = math::util::getMean(@vals);
	}
	elsif($stat eq 'sum') {
	    $result = math::util::getSum(@vals);
	}
	elsif($stat eq 'max') {
	    $result = math::util::getMax(@vals);
	}
	elsif($stat eq 'min') {
	    $result = math::util::getMin(@vals);
	}
	else {
	    die "binIt: unkown statistics $stat\n";
	}
    }
    else {
	my($rst) = $vals[0];

	for(my($i) = 1; $i < scalar(@vals); $i++) {
	    $rst .= ",$vals[$i]";
	}

	$result = $rst;
    }

    @vals = ();

    return $result;
}
