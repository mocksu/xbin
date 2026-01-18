#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <file.csv> <fld_name>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new($ARGV[0], 1);
my($fldNo) = $in->getFieldIndex($ARGV[1]);

if($fldNo == -1) {
    print "\nField name not found: $ARGV[1]\n\n";
}
else {
    print "\nField index for '$ARGV[1]': $fldNo\n\n";
}

