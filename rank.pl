#!/usr/bin/perl -w

# bin the input data file on the specified field, sum or concatenate other fields
if(scalar(@ARGV) != 3) {
    print "Usage: ~ <input.csv> <field_index> <output.csv>\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($fldIndex) = $ARGV[1];
my($out) = $ARGV[2];

if(!$in->fieldIsNumeric($fldIndex)) {
    die "Cannot rank a discrete field $fldIndex\n";
}

my(@fldData) = $in->getColumnData($fldIndex);
my(@ranks) = math::util::getRanks(@fldData);

my(@data) = $in->getDataArray();

open OUT, "+>$out" || die $!;

print OUT Flat::dataRowToString($in->getFieldNames()), "\n";

# discretize @fldData
for(my($i) = 0; $i < scalar(@data); $i++) {
    $data[$i][$fldIndex] = $ranks[$i];

    print OUT Flat::dataRowToString(@{$data[$i]}), "\n";
}

close OUT;

