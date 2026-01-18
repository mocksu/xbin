#!/usr/bin/perl -w

sub printUsage {
    print "Crossvalidate with the specified # of iteration\n\n";
    print "Usage: ~ [-a] [-o \"randomForest options\"] [-i <iteration>] (-n <#_to_train>|-p <%_to_train>) <in.csv> <label> <pred1> ... <predN> <out.csv>\n";
    exit(1);
}

use Util;

@ARGV = Util::explainCmdLine(@ARGV);

use Flat;
use Getopt::Std;
my $cmdLine = Util::getCmdLine();

my(%options);
getopts("ai:n:p:o:", \%options);

if(scalar(@ARGV) < 4) {
    printUsage();
}

my $inFile = shift @ARGV;
my($in) = Flat->new1($inFile);
my $label = shift @ARGV;
my($out) = pop @ARGV;
my @preds = @ARGV;

if(!(exists $options{"i"})) {
    printUsage();
}

my $iter = $options{"i"};

my($n); # number of cases to train

if(exists $options{"n"}) {
    $n = $options{"n"};
}
elsif(exists $options{"p"}) {
    $n = int($in->getNumOfRows() * $options{"p"});
}
else {
    printUsage();
}

if(!(exists $options{"a"})) {
    Util::rmIfExists([$out], 0);
  }

my $rfOpt = "";

if(exists $options{"o"}) {
    $rfOpt = "-o '".$options{"o"}."'";
}

my($odir, $ostem, $osuf) = Util::getDirStemSuffix($out);

open OUT, "+>$out" or die "Cannot open $out";
print OUT "# $cmdLine\n";
print OUT join("\t", "TRAIN_AUC", "TEST_AUC", "TRAIN_CASES", "TRAIN_CONTROLS", "TEST_CASES", "TEST_CONTROLS"), "\n";
close OUT;

for(my($i) = 0; $i < $iter; $i++) {
    my $trnset = "/tmp/$ostem.train$i.csv";
    my $tstset = "/tmp/$ostem.test$i.csv";
    
    Util::run("randomSelect.pl $inFile $n $trnset $tstset", 1);
    Util::run("csv.randomForest_test.pl -a $rfOpt $trnset $label @preds $tstset $label @preds $out", 1);
}
