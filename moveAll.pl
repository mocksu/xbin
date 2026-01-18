#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <RE_files> <outDir>\n";
    exit(1);
}

my(@files) = `find . -name $ARGV[0]`;
chomp(@files);

foreach $f (@files) {
    
    `mv $f $ARGV[1]`;
}
