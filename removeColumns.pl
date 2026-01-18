#!/usr/bin/perl -w

if((@ARGV) != 3) {
    print "\nUsage: ~ <input_file> <regular_expression_of_column_names> <result>\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new($ARGV[0], 1);
$in->removeFieldsByRE($ARGV[1]);
$in->writeToFile($ARGV[2]);
