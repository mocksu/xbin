#!/usr/bin/perl -w

sub printUsage {
    print "\nWrapps the randomForest R version\n\n";
    print "Usage: ~ [-a] [-o \"svm_classify options\"] <in.csv> <label_field_index> <predictor_field1_index> ... <predictor_fieldn_index> <test.csv> <labelFld> <pred1> ... <predn> <out>\n\n";
    print "\ta -- to append result or not\n";
    print "\tCommon randomForest options:\n\n";
    print "\tntree -- number of trees\n";
    print "\treplace -- sampling with replacement or not\n\n";
    exit(1);
}

my $DEBUG = 1;

use Util;
use Flat;
use Getopt::Std;
my(%options);
getopts("o:a", \%options);

my($opts) = "";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

my $append = "FALSE";

if(scalar(@ARGV) < 7) {
    printUsage();
}

my $npred = (scalar(@ARGV) - 5) / 2;
my $inFile = shift @ARGV;
my $in = Flat->new($inFile, 1);
my $trnlIndex = $in->getFieldIndex(shift @ARGV); # label index
my @trnPreds = $in->getFieldIndice([splice(@ARGV, 0, $npred)]);
my $tstFile = shift @ARGV;
my $tst = Flat->new($tstFile, 1);
my $tstlIndex = $tst->getFieldIndex(shift @ARGV);
my $out = pop @ARGV;
my @tstPreds = $tst->getFieldIndice([@ARGV]);

if(!$in->hasHeader()) {
    die "The input file has to have column names\n";
}

if($tst->getFieldIndex($out, 1) != -1) {
    die "An input field in the test dataset cannot be taken as the output file\n";
}

if($in->getFieldIndex($out, 1) != -1) {
    die "An input field in the training dataset cannot be taken as the output file\n";
}

if(exists $options{"a"}) {
    $append = "TRUE";
}
else {
    Util::rmIfExists([$out], 0);
}

my @fnames = $in->getFieldNames();
my $trnlFld = $fnames[$trnlIndex];
my @trnpredNames = map { $fnames[$_]; } @trnPreds;
my $trnpredForms = join("+", @trnpredNames);

my($dir, $stem, $suf) = Util::getDirStemSuffix($out);

my $trnTmp = "/tmp/$stem.train.short";
Util::run("csv2svm.pl $inFile $trnTmp $trnlFld @trnpredNames", 1);

# prepare test file
my $tstTmp = "/tmp/$stem.test.short";
my(@sindex) = (1 .. scalar(@tstPreds));
#Util::run("rmRows.pl $tstFile $tstFile ".join(" ", map { "$_ NA" } @sindex), 1);
Util::run("csv2svm.pl $tstFile $tstTmp $tstlIndex @tstPreds", 1);
# remove entries with "NA"
my $tstPredsStr = join(",", map { $_+1; } @sindex);
my $tstlIndex1 = 1;

# build the model using training data
my $model = "/tmp/$stem.model";
Util::run("svm_learn $opts $trnTmp $model", $DEBUG);
# use the model to predict test data
my $predAuc = classify($tstTmp, $model);
my $trainAuc = classify($trnTmp, $model);

open OUT, "+>>$out" or die "Cannot open $out\n";
print OUT "$trainAuc\t$predAuc\n";
close OUT;

sub classify {
    my($exampleFile, $modelFile) = @_;
    
    my($dir, $stem, $suf) = Util::getDirStemSuffix($exampleFile);

    my($rst) = "/tmp/$stem.svm_result";

    # classify
    Util::run("svm_classify $exampleFile $modelFile $rst", $DEBUG);
    
    ### collect results
    # compose a file for ROCR
    my($roc) = "/tmp/$stem.roc";
    open ROC, "+>$roc" or die "Cannot open $roc\n";

    print ROC "ORIGINAL\tPREDICTION\n";

    open EXAM, "<$exampleFile" or die "Cannot open $exampleFile\n";
    open PRED, "<$rst" or die "Cannot open $rst\n";

    my ($prow, @prdata);

    while($exam = <EXAM>) {
	$prow = <PRED>;
	chomp($exam);
	chomp($prow);
	
	@erdata = split(/\s+/, $exam);
	@prdata = split(/\s+/, $prow);
	
	if($erdata[0] == -1) {
	    $erdata[0] = 0;
	}

	print ROC "$erdata[0]\t$prdata[0]\n";
    }

    close EXAM;
    close PRED;
    close ROC;

    my $auc = math::util::getAUC($roc, 0, 1);
    
    # remove intermediate files 
    `rm $roc $rst`;

    return $auc;
}
       
    
