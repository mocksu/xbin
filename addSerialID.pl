#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <id_field_name> <out.csv>\n";
    exit(1);
}

use Flat;

my $in = Flat->new1(shift @ARGV);
my $idName = shift @ARGV;
my $out = shift @ARGV;

open OUT, "+>$out" or die $!;

if($in->hasHeader()) {
    print OUT join("\t", $idName, $in->getFieldNames()), "\n";
}

while($row = $in->readNextRow()) {
    print OUT join("\t", $in->getRowIndex(), @{$row}), "\n";
}

close OUT;
