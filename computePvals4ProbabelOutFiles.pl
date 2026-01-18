#!/usr/bin/perl -w

if(scalar(@ARGV) < 2) {
    print "Usage: ~ <paResultFilesRE> <out.csv>\n";
    exit(1);
}

use Flat;

my($out) = pop @ARGV;

my @inFiles = @ARGV;

# list the files in a file
open LIST, "+>$out.fileList" or die "Cannot open $out.fileList\n";

foreach $f (@inFiles) {
    print LIST "$f\n";
}

close LIST;

Util::run("processProbabelOutFiles.pl . $out.fileList $out.tmp", 1);
Util::run("mv $out.tmp $out", 1);
