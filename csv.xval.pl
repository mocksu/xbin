#!/usr/bin/perl -w

sub printUsage {
    print "Crossvalidate with the specified # of iteration\n\n";
    print "Usage: ~ -c <command> -i <iteration> (-n <#_to_train>|-p <%_to_train>) <in.csv> <label> <pred1> ... <predN> <out.csv>\n";
    exit(1);
}

use Util;
use Flat;
use Getopt::Std;
my $cmdLine = Util::getCmdLine();

my(%options);
getopts("c:i:n:p:", \%options);

if(!(exists $options{"c"})) {
    print "-c has to be specified\n";
    printUsage();
}

my $cmd = $options{"c"};

if(scalar(@ARGV) < 4) {
    print "Insufficient number of arguments\n";
    printUsage();
}

my $inFile = shift @ARGV;
my($in) = Flat->new1($inFile);
my $label = shift @ARGV;
my($out) = pop @ARGV;
my @preds = @ARGV;

if(!(exists $options{"i"})) {
    print "-i (iteration) has to be specified\n";
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
    print "-p has to be specified\n";
    printUsage();
}

Util::rmIfExists([$out], 0);
my($odir, $ostem, $osuf) = Util::getDirStemSuffix($out);

open OUT, "+>$out" or die "Cannot open $out";
print OUT "# $cmdLine\n";
print OUT join("\t", "TRAIN_AUC", "TEST_AUC", "TRAIN_CASES", "TRAIN_CONTROLS", "TEST_CASES", "TEST_CONTROLS"), "\n";
close OUT;

for(my($i) = 0; $i < $iter; $i++) {
    my $trnset = "/tmp/$ostem.train$i.csv";
    my $tstset = "/tmp/$ostem.test$i.csv";
    
    Util::run("randomSelect.pl $inFile $n $trnset $tstset", 1);
    # to any algorithm, only the following line needs to be changed
    Util::run("$cmd -a $trnset $label @preds $tstset $label @preds $out", 1);
}
