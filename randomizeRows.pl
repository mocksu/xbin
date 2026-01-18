#!/usr/bin/perl -w

sub printUsage() {
    print "Randomize the order of rows\n\n";
    print "Usage: ~ <in.csv> <out.csv>\n\n";
    exit(1);
}

use Flat;
use Util;
use math;

my $cmdLine = Util::getCmdLine();

if(scalar(@ARGV) != 2) {
    printUsage();
}

my $inFile = shift @ARGV;
my $out = shift @ARGV;

my $in = Flat->new1($inFile);
my (@data) = $in->getDataArray();

my(@rowIndice) = (0..scalar(@data) - 1);

my(@randIndice) = math::util::randomize(@rowIndice);

open OUT, "+>$out.tmp" or die "Cannot open $out\n";
print OUT join("\t", $in->getFieldNames()), "\n";

for(my($i) = 0; $i < scalar(@randIndice); $i++) {
    print OUT join("\t", @{$data[$randIndice[$i]]}), "\n";
}

close OUT;

`mv $out.tmp $out`;
