#!/usr/bin/perl

if(scalar(@ARGV) != 1) {
    print "Usage: ~ <RE_FileNames>\n\n";
    print "\tCheckOnly\t1 print out files to be removed;\n";
    print "\t         \t0 remove files\n\n";
    print "You had ", scalar(@ARGV), " arguments\n\n";
    exit(1);
}

use Util;
Util::run("rmFiles.pl \"$ARGV[0]\" 4 ^0\$ 0", 1);
