#!/usr/bin/perl -w

sub printUsage {
    print "\nUsage: ~ <input_file> <fldNo> [<result>]\n\n";
    print "fldNo\t0 based field index\n";
    exit(1);
}

if((@ARGV) != 2 && (@ARGV) != 3) {
    printUsage();
}

use Flat;
use math;
use Util;

my($in) = shift @ARGV;
my($fld) = shift @ARGV;
my($out);

if(math::util::isNaN($fld)) {
    printUsage();
}

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in;
}

open IN, "<$in" or die $!;

my $tmp = "$out.tmp";

open OUT, "+>$tmp" or die $!;

while($line = <IN>) {
    chomp($line);

    my @row = split(/\t/, $line);
    splice @row, $fld, 1;
    print OUT join("\t", @row), "\n";
}

close OUT;
print "rmColumns.pl: all rows processed\n";
`mv $tmp $out`;
