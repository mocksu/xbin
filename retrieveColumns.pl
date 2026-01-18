#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("s", \%options);

my $skipCheck = exists $options{"s"};

if((@ARGV) < 3) {
    print "\nUsage: ~ -s <input_file> <out.csv> <column_name1[:rename1] ... <column_nameN[:renameN]>\n";
    print "\t-s skip checking data integrity of the input file. Default is to check\n";
    exit(1);
}

my($inFile) = shift @ARGV;
my($in) = Flat->new1($inFile);
my($outFile) = shift @ARGV;
my(@fldsInOrder) = $in->getFieldIndice([@ARGV]);

$in->writeToFile("$outFile.tmp", [@fldsInOrder], $cmdLine, $skipCheck);
Util::run("mv $outFile.tmp $outFile", 1);
