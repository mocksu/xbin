#!/usr/bin/perl

if(scalar(@ARGV) != 2) {    
    print "\nUsage: <long|short|medium|zodiac> <my.pbs>\n\n";
    print "Run <my.pbs>\n\n";
    exit(1);
}

use Util;

my $ls = shift @ARGV;
my($pbs) = shift @ARGV;

Util::run("qsub -q $ls $pbs", 1);
