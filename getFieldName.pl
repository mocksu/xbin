#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <file.csv> <fld>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new($ARGV[0], 1);
my($fldNo) = $in->getFieldIndex($ARGV[1]);
my @fnames = $in->getFieldNames();

$in->destroy();

if($fldNo == -1) {
    print "\nField name not found: $ARGV[1]\n\n";
}
else {
    print "\nField name for '$ARGV[1]': $fnames[$fldNo]\n\n";
}

