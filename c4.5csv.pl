#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    die "Usage: ~ <file.csv> <fld_no> <bin_size>\n";
}

use Flat;

my($in) = Flat->new($ARGV[0], 0);
my($fldNo) = $ARGV[1];
my($size) = $ARGV[2];

my(@data) = $in->getDataArray();

my(%count);

foreach $d (@data) {
    $count{int($d->[$fldNo] / $size)}++;
}

foreach $key (sort keys %count) {
    print $key * $size, "\t$count{$key}\n";
}
