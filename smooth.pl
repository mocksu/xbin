#!/usr/bin/perl -w

if(scalar(@ARGV) != 4) {
    print "Smooth a point by its neighbors using 1/(n+1) as weight for n-th neighbor\n";
    print "Usage: ~ <in.csv> <field_no> <side_width> <out.csv>\n";
    exit(1);
}

use Flat;
use Peak;

my($in) = Flat->new1(shift @ARGV);
my($fldNo) = $in->getFieldIndex(shift @ARGV);
my $fldName = $in->getFieldName($fldNo);
my($side_width) = shift @ARGV;
my $out = shift @ARGV;

my(@colData) = $in->getColumnData($fldNo);
my($numOfRows) = $in->getNumOfRows();
my(@smoothed) = Peak::smooth(\@colData, $side_width);

open OUT, "+>$out.tmp" or die "cannot open $out.tmp\n";
print OUT join("\t", $in->getFieldNames(), "$fldName.smoothed"), "\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}, shift @smoothed), "\n";
}

close OUT;

`mv $out.tmp $out`;
