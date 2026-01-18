#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;
my(%options);
getopts("o:", \%options);
my($opts) = "";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

if(scalar(@ARGV) < 4 || $opts !~ /size/) {
    print "Wrapps the nnet (neural net) R version\n";
    print "Usage: ~ <input.csv> -o \"nnet options. must specify size\" <label_field_index> <predictor_field1_index> ... <predictor_fieldn_index> <out>\n\n";
    print "\tCommon nnet options:\n\n";
    print "\tsize     : the hidden layer number of nodes. This must be specified at command line\n";
    print "\tmaxit    : max number of iterations\n";
    print "\tlinout   : linear output or not. The default is logistic in 'nnet', but linear in this script\n";
    print "\tna.action: default is to fail in 'nnet', but 'na.omit' in this script\n\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $in = Flat->new($inFile, 1);
my $lIndex = $in->getFieldIndex(shift @ARGV); # label index
my $out = pop @ARGV;
my @predIndice = $in->getFieldIndice([@ARGV]);

if(!$in->hasHeader()) {
    die "The input file has to have column names\n";
}

if($in->getFieldIndex($out, 1) != -1) {
    die "An input field cannot be taken as the output file\n";
}

# extract the involved fields into a separate file because R might not be able to read the input correctly
Util::run("extractColumns.pl $inFile '".join("|", $lIndex, @predIndice)."' $out.data", 1);

my @fnames = $in->getFieldNames();
my $lFld = $fnames[$lIndex];
my @predNames = map { $fnames[$_]; } @predIndice;
my $predForms = join("+", @predNames);

my($dir, $stem, $suf) = Util::getDirStemSuffix($out);

open SCRIPT, "+>$out.R" or die $!;

my $rOptions = "";

if($opts !~ /na\.action/) {
    $rOptions = "na.action=na.omit";
}
# else take the specified value

if($opts !~ /linout/) {
    $rOptions = join(",", $rOptions, "linout=TRUE");
}

if($opts) {
    $rOptions = $rOptions.", $opts";
}

print SCRIPT <<R;
library(nnet)
library(ROCR)
$stem.data<-read.table("$out.data", sep="\\t", header=TRUE, na.strings="NA")
$stem.rst<-nnet($lFld ~ $predForms, data=$stem.data, $rOptions)
$stem.rst.y<-$stem.rst\$residuals+$stem.rst\$fitted.values
$stem.pred<-prediction($stem.rst\$fitted.values, $stem.rst.y)
$stem.perf<-performance($stem.pred, "tpr", "fpr")
plot($stem.perf, col=rainbow(10))
$stem.auc<-performance($stem.pred, "auc")
$stem.auc;
R

close SCRIPT;

# run R script
Util::run("R --no-save < $out.R > $out", 1);
Util::run("more $out", 0);
