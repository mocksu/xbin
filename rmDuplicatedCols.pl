#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("i", \%options);

if(scalar(@ARGV) != 2) {
    print "Remove duplicated columns\n\n";
    print "Usage: ~ [-i] <in.csv> <out.csv>\n";
    print "\t-i case-insensitive. Default is case-sensitive\n\n";
    exit(1);
}

use Flat;
use Util;

my $case = 1;

if(exists $options{"i"}) {
    $case = 0;
}

my $inFile = shift @ARGV; 
my($in) = Flat->new($inFile, 1);
my($out) = shift @ARGV;

my @fnames = $in->getFieldNames();
my @dupFnames;

my %counted;

foreach $f (@fnames) {
    my $fn = $f;

    if(!$case) { # case-insensitive
	$fn = uc($f);
    }

    if(exists $counted{$fn}) {
	push @dupFnames, $f;
    }
    else {
	$counted{$fn} = 1;
    }
}

Util::run("rmColumns.pl $inFile '".join("|", @dupFnames)."' $out", 1);
