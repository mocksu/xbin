#!/usr/bin/perl -w

use Flat;
use Getopt::Std;

my(%options);
getopts("s:n:x:", \%options);

if(scalar(@ARGV) != 2) {
  print "Reverse the order of the rows.\n\n";
    print "Usage: ~ <in.csv> <out.csv>\n";
    exit(1);
}

my($in) = Flat->new(shift @ARGV, 1);
my($out) = shift @ARGV;

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

my(@fnames) = $in->getFieldNames();
print OUT join("\t", @fnames), "\n";

my @data = $in->getDataArray();

for(my($i) = scalar(@data) - 1; $i >= 0; $i--) {
  print OUT join("\t", @{$data[$i]}), "\n";
}

close OUT;

`mv $out.tmp $out`;
