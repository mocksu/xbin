#!/usr/bin/perl -w

# bin the input data file on the specified field, sum or concatenate other fields
if(scalar(@ARGV) != 2) {
    print "\nUsage: ~ <input.csv> <output.csv>\n\n";
    print "\tConvert all numeric columns to corresponding ranks\n\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($out) = $ARGV[1];

my(@fnames) = $in->getFieldNames();

for(my($i) = 0; $i < scalar(@fnames); $i++) {
    if($in->fieldIsNumeric($i)) {
	my(@fldData) = $in->getColumnData($i);
	my(@ranks) = math::util::getRanks(@fldData);
	$in->setFieldData($i, \@ranks);
    }
}

$in->writeToFile($out);
