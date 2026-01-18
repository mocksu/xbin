#!/usr/bin/perl -w

use Util;
use Getopt::Std;

my(%options);
getopts("l", \%options);
my($trimLine) = exists $options{"l"}?1:0;

if(scalar(@ARGV) != 2) {
    print "Convert files with white spaces as separators to be with tab as seps\n";
    print "Usage: [-l] ~ <in.csv> <out.csv>\n";
    print "       -l trim off the leading and trailing spaces of each line\n";
    exit(1);
}

my $in = shift @ARGV;
my $out = shift @ARGV;

open IN, "<$in" or die $!;
open OUT, "+>$out.tmp" or die "cannot open $out.tmp\n";

while($line = <IN>) {
    chomp($line);

    if($trimLine) {
	$line = Util::trim($line);
    }

    @rdata = split(/\s+/,$line);

    print OUT join("\t", @rdata), "\n";
}

close IN;
close OUT;

`mv $out.tmp $out`;
