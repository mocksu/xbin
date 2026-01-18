#!/usr/bin/perl -w

if(scalar(@ARGV) != 3 && scalar(@ARGV) != 4) {
    die "Usage: ~ <input.csv> <field_index1> <field_index2> [output.csv]\n";
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
my($ind1) = $in->getFieldIndex($ARGV[1]);
my($ind2) = $in->getFieldIndex($ARGV[2]);
my($out);

if(scalar(@ARGV) == 4) {
    $out = $ARGV[3];
}
else {
    $out = $ARGV[0];
}

my $tout = "$out.swapFields.tmp";

open OUT, "+>$tout" or die "Cannot open $tout\n";

my @fnames = $in->getFieldNames();
($fnames[$ind1], $fnames[$ind2]) = ($fnames[$ind2], $fnames[$ind1]);

print OUT join("\t", @fnames), "\n";

while($row = $in->readNextRow()) {
    ($row->[$ind1],$row->[$ind2]) = ($row->[$ind2], $row->[$ind1]);
    print OUT join("\t", @{$row}), "\n";
}

close OUT;

`mv $tout $out`;
