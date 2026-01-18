#!/usr/bin/perl -w

use Util;

@ARGV = Util::explainCmdLine(@ARGV);

use Getopt::Std;
my(%options);
getopts("o:i:", \%options);

my $append = "TRUE";
my $niter = -1;

if(exists $options{"i"}) {
    $niter = $options{"i"};
}

my($opts) = "";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

if($niter == -1 || scalar(@ARGV) < 4) {
    print "Permute the specified response field and output the AUC to the specified output. Iterate the process the specified # of times\n";
    print "Usage: ~ -i <iter> [-o \"randomForest options\"] <in.csv> <label_field> <predictor_field1_index> ... <predictor_fieldn_index> <out>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $lFld = shift @ARGV;
my $out = pop @ARGV;

my ($dir, $stem, $suf) = Util::getDirStemSuffix($out);

my $rfOptions = "";

if($opts) {
    $rfOptions = "-o '$opts'";
}

for(my($i) = 0; $i < $niter; $i++) {
    # permute
    my $perm = "/tmp/$stem.permuted$i";
    Util::run("permuteField.pl $inFile $lFld $perm", 1);

    if($i == 0) {
	Util::run("csv.randomForest.pl $rfOptions $perm $lFld @ARGV $out", 1);
    }
    else {
	Util::run("csv.randomForest.pl -a $rfOptions $perm $lFld @ARGV $out", 1);
      }

    Util::run("rm $perm", 0);
}
