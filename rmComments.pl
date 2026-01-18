#!/usr/bin/perl -w

use Util;
use Flat;

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> [<out.csv>]\n";
    exit(1);
}

my($in) = Flat->new1(shift @ARGV);
my($out) = $in->getFileName();

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}


open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

if($in->hasHeader()) {
    my(@fnames) = $in->getFieldNames();

    print OUT join("\t", @fnames), "\n";
}

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}), "\n";
}

close OUT;

Util::run("mv $out.tmp $out", 0);
