#!/usr/bin/perl -w

if(scalar(@ARGV) != 3 && scalar(@ARGV) != 4) {
    print "Usage: ~ <input.csv> <from_index> <to_index> [output.csv]\n";
    print "\tMove field from_index to to_index\n\n";
    exit(1);
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

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

my @fnames = $in->getFieldNames();
### get new field names

print OUT join("\t", @{moveFld(\@fnames, $ind1, $ind2)}), "\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{moveFld($row, $ind1, $ind2)}), "\n";
}

close OUT;

`mv $out.tmp $out`;

sub moveFld {
    my($arr, $from, $to) = @_;

    # remove field "$from" first
    my $val = splice(@{$arr}, $from, 1);

    # insert $val to "$to"
    splice(@{$arr}, $to, 0, $val);

    return $arr;
}
