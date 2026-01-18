#!/usr/bin/perl -w

sub printUsage {
    print "Crossvalidate with the specified # of iteration using svm\n\n";
    print "Usage: ~ [-o svm_learn options] -i <iteration> (-n <#_to_train>|-p <%_to_train>) <in.csv> <label> <pred1> ... <predN> <out.csv>\n";
    exit(1);
}

use Util;
use Getopt::Std;
my $cmdLine = Util::getCmdLine();

my(%options);
getopts("o:i:n:p:", \%options);
my $opts = "";

if(exists $options{"o"}) {
    $opts = "-o '".$options{"o"}."'";
}

my $iter = "";

if(exists $options{"i"}) {
    $iter = "-i ".$options{"i"};
}
else {
    print "csv.svm_xval.pl: -i has to be specified\n";
    printUsage();
}

my $n = "";

if(exists $options{"n"}) {
    $n = $options{"n"};
}
elsif(exists $options{"p"}) {
    $n = "-p ".$options{"p"};
}
else {
    print "-n or -p has to be specified\n";
    printUsage();
}

if(scalar(@ARGV) < 4) {
    printUsage();
}

Util::run("csv.xval.pl -c \"csv.svm_test.pl $opts\" $iter $n @ARGV", 1);
