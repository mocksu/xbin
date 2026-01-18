#!/usr/bin/perl -w

use Flat;
use math;
use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("o:g:", \%options);
my($grf) = "pdf";

if(exists $options{"g"}) {
    $grf = $options{"g"};
}

my($op) = "";

if(exists $options{"o"}) {
    $op = $options{"o"};
}

if(scalar(@ARGV) != 4) {
    print "Usage: ~ [-o operation_on-predFld] [-g jpeg|png|...|pdf|postscript] <in.csv> <labelField> <predField> <out.csv>\n";
    print "       -o operation to be specified on predField. e.g. '-'\n";
    print "       -g graphics device. Default is 'pdf'\n\n";
    exit(1);
}

my $in = Flat->new1(shift @ARGV);
my $lfld = $in->getFieldIndex(shift @ARGV);
my $pfld = $in->getFieldIndex(shift @ARGV);
my $out = shift @ARGV;

my $auc = math::util::getAUC($in->getFileName(), $lfld, $pfld, $grf, $op);

open OUT, "+>$out" or die "Cannot open $out\n";

print OUT "# $cmdLine\n";
print OUT "AUC\n";
print OUT "$auc\n";
close OUT;
