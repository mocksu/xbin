#!/usr/bin/perl -w

use Flat;
use Util;

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "Remove the field names if exist\n";
    print "Usage: ~ <in.csv> [<out.csv>]\n";
    exit(1);
}

my $inFile = shift @ARGV;
my($in) = Flat->new1($inFile);
my($out);

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $inFile;
}

if(!$in->hasHeader()) {
    print "The input file '$inFile' does not have a header\n";
    exit(1);
}
# else has header

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}), "\n";
}

close OUT;


`mv $out.tmp $out`;
