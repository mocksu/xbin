#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> <out.csv>\n";
    exit(1);
}

use Flat;

my($in) = shift @ARGV;
my($out) = shift @ARGV;

open IN, "<$in" or die "Cannot open $in\n";
open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";
print OUT "PREDICTOR\tIMPORTANCE\n";

$line = <IN>; # skip the first line

while($line =<IN>) {
    chomp($line);
    $line =~ s/\"//g;

    my(@d) = split(/\s+/, $line);

    print OUT join("\t", @d), "\n";
}

close IN;
close OUT;

`FlatSort.pl -r '-g -k 2 -r' $out.tmp $out`;
#`rm $out.tmp`;
