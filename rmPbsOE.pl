#!/usr/bin/perl

my($re) = '';

if(scalar(@ARGV) > 0) {
    $re = shift @ARGV;
}

use Util;
# remove .e files
Util::run("rm -rf *$re*.e[0-9][0-9][0-9]*", 1);
# remove .o files
Util::run("rm -rf *$re*.o[0-9][0-9][0-9]*", 1);
