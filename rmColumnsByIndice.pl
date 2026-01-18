#!/usr/bin/perl -w

if((@ARGV) < 3) {
    print "\nUsage: ~ <input_file> <result> (<field_index> )+\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
my($out) = $ARGV[1];

shift @ARGV;
shift @ARGV;
my(@indice) = @ARGV;

$in->removeFieldsByIndice(@indice);
$in->writeToFile($out);
