#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my(%options);
getopts("s:n:x:", \%options);

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> <out.csv>\n";
    exit(1);
}

my($in) = Flat->new(shift @ARGV, 1);
my($out) = shift @ARGV;

my(@fnames) = $in->getFieldNames();

while($row = $in->readNextRow()) {
}
