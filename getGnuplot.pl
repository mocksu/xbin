#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <gnuplot.txt> <output.jpg>\n";
    exit(1);
}

my($cmd) = $ARGV[0];
my($out) = $ARGV[1];

use Util;
my($dir, $stem, $suffix) = Util::getDirStemSuffix($out);

my($tmpCmd) = "/tmp/.__getGnuplot.$stem.txt";

open TMP, "+>$tmpCmd" || die $!;

print TMP "set term jpeg;\n";
print TMP "set out \"$out\";\n\n";

open CMD, "<$cmd" || die $!;

while($line = <CMD>) {
    print TMP $line;
}

close CMD;

print TMP "\n";
print TMP "set out;\n";
print TMP "set term X11;\n";
close TMP;

Util::run("gnuplot < $tmpCmd", 1);

#Util::run("rm -rf $tmpCmd", 1);
