#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <matrix1.csv> <output.csv>\n";
    exit(1);
}

use Flat;
use math;
use Util;

print "reading $ARGV[0]\n";
my($mat1) = math::Matrix->new($ARGV[0]);
print "transposing and saving to $ARGV[1]\n";

$mat1->transpose()->serialize($ARGV[1]);
