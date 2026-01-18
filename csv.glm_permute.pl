#!/usr/bin/perl -w

use Util;
use Getopt::Std;
my(%options);
getopts("n:", \%options);

my $append = "TRUE";
my $niter = -1;

if(exists $options{"n"}) {
    $niter = $options{"n"};
}

if($niter == -1 || scalar(@ARGV) < 4) {
    print "Permute the specified response field and output the AUC to the specified output. Iterate the process the specified # of times\n";
    print "Usage: ~ -n <iter> <in.csv> <label_field> <predictor_field1_index> ... <predictor_fieldn_index> <out>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $lFld = shift @ARGV;
my $out = pop @ARGV;

my ($dir, $stem, $suf) = Util::getDirStemSuffix($out);

for(my($i) = 0; $i < $niter; $i++) {
    # permute
    my $perm = "/tmp/$stem.permuted$i";
    Util::run("permuteField.pl $inFile $lFld $perm", 1);
    Util::run("csv.glm.pl -a -o 'family=\"binomial\"' $perm $lFld @ARGV $out", 1);
    Util::run("rm $perm", 0);
}
