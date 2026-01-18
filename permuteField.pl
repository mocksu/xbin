#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Permute the specified field\n\n";
    print "Usage: ~ <in.csv> <fld> <out.csv>\n\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new(shift @ARGV, 1);
my $fldIndex = $in->getFieldIndex(shift @ARGV);
my($out) = shift @ARGV;
open OUT, "+>$out" or die "Cannot open $out\n";

my(@fnames) = $in->getFieldNames();
print OUT join("\t", @fnames), "\n";
my (@fldVals) = $in->getColumnData($fldIndex);
my (@rFldVals) = math::util::randomize(@fldVals);

$in->reset();

my $i = 0;

while($row = $in->readNextRow()) {
    $row->[$fldIndex] = $rFldVals[$i++];

    print OUT join("\t", @{$row}), "\n";
}

close OUT;
