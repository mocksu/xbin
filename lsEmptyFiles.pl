#!/usr/bin/perl

if(scalar(@ARGV) != 1) {
    print "Usage: ~ <RE_FileNames>\n\n";
    exit(1);
}

use Util;
Util::run("rmFiles.pl \"$ARGV[0]\" 4 ^0\$ 1", 0);
