#!/usr/bin/perl -w

# bin the input data file on the specified field, sum or concatenate other fields
if(scalar(@ARGV) != 3) {
    print "Usage: ~ <input.csv> <fld_no> <#_of bins>\n";
    print "input.csv\tinput data file to be binned\n";
    print "fld_no\tthe number of the field (0 based) to be binned\n";
    print "#_of bins\tthe size of bin of the specified field\n";
    exit(1);
}

my($infile) = $ARGV[0];
my($file) = Flat->new1($infile);
my($fldNo) = $file->getFieldIndex($ARGV[1]);
my($numOfBins) = $ARGV[2];

my(@fldNames) = $file->getFieldNames();
my(@columnData) = $file->getFieldData($fldNo);

# remove NaN
@columnData = math::util::removeNaN(@columnData);

my($min) = math::util::getMin(@columnData);
my($max) = math::util::getMax(@columnData);
my($binSize) = ($max - $min) / $numOfBins;

use Flat;
use math;

if(math::util::NaN($fldNo) || math::util::NaN($binSize)) {
    die "All should be numeirc: fldNo = $fldNo, binSize = $binSize\n";
}

my(%counts);

for(my($i) = 0; $i < scalar(@columnData); $i++) {
    push @{$counts{int(($columnData[$i] - $min) / $binSize)}}, $columnData[$i];
}

# print the data out
my($fldName);
if(scalar(@fldNames) > 0) {
    $fldName = $fldNames[$fldNo];
}
else {
    $fldName = "Field $fldNo";
}

print "$fldName\tCount\n";

for(my($i) = 0; $i < $numOfBins; $i++) {
    my($bmin, $bmax);

    if(!(exists $counts{$i})) {
	$counts{$i} = 0;
	$bmin = '';
	$bmax = '';
    }
    else {
	$bmin = math::util::getMin(@{$counts{$i}});
	$bmax = math::util::getMax(@{$counts{$i}});
    }

    print $min + $binSize * ($i + 0.5), "[$bmin ~ $bmax]\t", scalar(@{$counts{$i}}), "\n";
}
