#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <matrix1.csv> <matrix2.csv> <output.csv>\n";
    exit(1);
}

use Flat;
use math;
use Util;

print "reading $ARGV[0]\n";
my($mat1) = math::Matrix->new($ARGV[0]);
print "reading $ARGV[1]\n";
my($mat2) = math::Matrix->new($ARGV[1]);

print "getting the product ...\n";
my($prod) = math::Matrix::getProduct($mat1, $mat2);

print "saving the results to $ARGV[2]\n";
$prod->serialize($ARGV[2]);
