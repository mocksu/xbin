#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("o:r:", \%options);
my $opts = "";
my $replace;

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

if(exists $options{"r"}) {
    $replace = $options{"r"};
}

if(scalar(@ARGV) < 4) {
    print "Usage: ~ [-o <\"svmlearn_options\">] [-r \"csv2svm.pl replacement options\"] <in.csv> <output_model_file> <label_fldNum> <predictor_fld1> <predictor_fld2> ... <predictor_fldn>\n\n";
    print "         run 'svm_learn' to find out svmlearn_options. '-x 1' specifies leave-one-out estimates\n\n";
    print "         -r to specify label symbols to be replaced with a specific number\n";
    print "         if there are 2 classes, use -1 for negative, 1 for positive as labels\n";
    exit(1);
}

use Flat;
use Util;

my $inFile = shift @ARGV;
my $in = Flat->new1($inFile);
my $out = shift @ARGV;
my $labelFld = $in->getFieldIndex(shift @ARGV);
my @predFlds = map { $in->getFieldIndex($_) } @ARGV;

# convert csv 2 svm data file format
if($replace) {
    Util::run("csv2svm.pl -r \"$replace\" $inFile $inFile.svm.dat $labelFld @predFlds", 1);
  }
else {
    Util::run("csv2svm.pl $inFile $inFile.svm.dat $labelFld @predFlds", 1);
}

# run svm_learn
Util::run("svm_learn $opts $inFile.svm.dat $out", 1);
 
