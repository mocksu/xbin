#!/usr/bin/perl -w

if(scalar(@ARGV) != 4) {
    print "\nUsage: ~ <in.csv> <fldNum|fldName> <delimiter> <out.csv>\n\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($fldNum) = math::util::isNaN($ARGV[1])?$in->getFieldIndex($ARGV[1]):$ARGV[1];
my($delimiter) = $ARGV[2];
open OUT, "+>$ARGV[3]" || die $!;

my(@data) = $in->getDataArray();
my($fldName) = $in->getFieldName($fldNum);
my(@fldSplit) = split(/$delimiter/, $data[0][$fldNum]);
my($numFlds) = scalar(@fldSplit);
my(@newFldNames);

for(my($i) = 0; $i < $numFlds; $i++) {
    $newFldNames[$i] = "$fldName.split$i";
}

print OUT Flat::dataRowToString($in->getFieldNames(), @newFldNames), "\n";

for(my($i) = 0; $i < scalar(@data); $i++) {
    my(@newData) = split(/$delimiter/, $data[$i][$fldNum]);

    print OUT Flat::dataRowToString(@{$data[$i]}, @newData), "\n";
}

close OUT;
