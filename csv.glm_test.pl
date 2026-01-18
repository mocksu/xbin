#!/usr/bin/perl -w

sub printUsage {
    print "\nWrapps the randomForest R version\n\n";
    print "Usage: ~ [-c] [-i iter] [-g png|jpeg|postscript] [-a] [-o \"glm\"] [-t] <train.csv> <test.csv> <label_field_index> <predictor_field1_index> ... <predictor_fieldn_index>  <out>\n\n";
    print "\tc -- classification. Default is to let RF find out.\n";
    print "\tg -- which graphics format to use. default is postscript. Partner's cluster -- postscript; beast/pc571 -- jpeg/png/ps\n";
    print "\ta -- to append result or not\n";
    print "\tt -- Save predicted labels on the test dataset if specified; otherwise do not save\n\n";
    print "\tCommon randomForest options:\n\n";
    print "\tntree -- number of trees\n";
    print "\treplace -- sampling with replacement or not\n\n";
    exit(1);
}

use Util;
use Flat;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();
my $iter = 1;

my(%options);
getopts("ci:g:o:ats:", \%options);

my $class = "";

if(exists $options{"c"}) {
    $class = 1;
}

if(exists $options{"i"}) {
    $iter = $options{"i"};
}

my $saveTest = 0;

if(exists $options{"t"}) {
    $saveTest = 1;
}

my $grf = "pdf";

if(exists $options{"g"}) {
    $grf = $options{"g"};
}


my($opts) = "";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

my$append = "FALSE";

if(scalar(@ARGV) < 7) {
    printUsage();
}

# parse arguments
my $inFile = shift @ARGV;
my $in = Flat->new($inFile, 1);
my $tstFile = shift @ARGV;
my $trnlIndex = $in->getFieldIndex(shift @ARGV); # label index
my $out = pop @ARGV;
my @trnPreds = $in->getFieldIndice([@ARGV]);

my @predNames = $in->getFieldNames(@trnPreds);
my $tstlIndex = $tst->getFieldIndex(@predNames);

my $tst = Flat->new($tstFile, 1);

my @tstPreds = $tst->getFieldIndice([@ARGV]);
my $outImp = "$out.importance.csv";
my $outProx = "$out.proximity.csv";

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
    Util::rmIfExists([$outImp], 0);
    Util::rmIfExists([$outProx], 0);
}

my $toSave = 0;

if(exists $options{"s"}) {
    $toSave = $options{"s"};
}

if(!(-e $out) || !Util::fileIsComplete($out, 1, 0)) { # if file does not exist or is empty, record command line
    open OUT, "+>$out" or die "Cannot open $out\n";
    print OUT "# $cmdLine\n";
    close OUT;

    open IMP, "+>$outImp\n";
    print IMP "# $cmdLine\n";
    close IMP;

    open PROX, "+>$outProx\n";
    print PROX "# $cmdLine\n";
    close PROX;    
}

my @fnames = $in->getFieldNames();
my $trnlFld = $fnames[$trnlIndex];
my @trnpredNames = map { $fnames[$_]; } @trnPreds;
my $trnpredForms = join("+", @trnpredNames);

my($dir, $stem, $suf) = Util::getDirStemSuffix($out);

my $trnTmp = "$stem.train.short";
Util::run("extractColumns.pl $inFile '".join("|", $trnlIndex, @trnPreds)."' $trnTmp", 1);

# prepare test file
my $tstTmp = "$stem.test.short";
Util::run("rmRows.pl -l o $tstFile /dev/null $tstTmp.known ".join(" ", map { "$_ '^NA\$|^\\s*\$'" } ($tstlIndex, @tstPreds)), 1);
Util::run("extractColumns.pl $tstTmp.known '".join("|", $tstlIndex, @tstPreds)."' $tstTmp", 1);
# remove entries with "NA"
my(@sindex) = (1 .. scalar(@tstPreds));

my $tstPredsStr = join(",", map { $_+1; } @sindex);
my $tstlIndex1 = 1;

my $rscript = "$stem.R";

open SCRIPT, "+>$rscript" or die $!;

my $rfOptions = "na.action=NULL";

if($opts) {
    $rfOptions = $rfOptions.", $opts";
}

### get number of cases and controls for training and testing datasets
# training dataset
my $trnFlat = Flat->new1($trnTmp);
my %trnFld2indice = $trnFlat->getIndiceOfFieldValues(0);
my $trnCases = (exists $trnFld2indice{1})?scalar(@{$trnFld2indice{1}}):0;
my $trnCons = $trnFlat->getNumOfRows() - $trnCases;
# testing dataset
my $tstFlat = Flat->new1($tstTmp);
my %tstFld2indice = $tstFlat->getIndiceOfFieldValues(0);
my $tstCases = (exists $tstFld2indice{1})?scalar(@{$tstFld2indice{1}}):0;
my $tstCons = $tstFlat->getNumOfRows() - $tstCases;

Util::run("rmComments.pl $trnTmp", 0);
Util::run("rmComments.pl $tstTmp", 0);

print SCRIPT <<R0a;
library(randomForest);
library(ROCR);
$stem.data<-read.table("$trnTmp", header=TRUE, sep="\\t", na.strings="NA");
$stem.tstData<-read.table("$tstTmp", header=TRUE, sep="\\t");
R0a

# if classification, then modify the label field to be a categorical field by prefixing with 'c'
if($class) {
print SCRIPT <<R0a;
$stem.data[,$trnlIndex]<-factor($stem.data[,$trnlIndex]);
R0a
}

for(my($i) = 0; $i < $iter; $i++) {

print SCRIPT <<R0b;
$stem.xt<-$stem.tstData[c($tstPredsStr)];
$stem.glm<-glm($trnlFld ~ . - $trnlFld, data=$stem.data, family='binomial', $rfOptions);

R0b

if($saveTest) {
    print SCRIPT <<R1;
write("PREDICTED", file="$dir/$stem.test.predicted");
write($stem.rf\$test\$predicted, file="$dir/$stem.test.predicted", sep="\n", append=T);
R1
}

#print "classification = $class, rfOptions = $rfOptions\n";

print SCRIPT <<R2a;

if(length(unique($stem.rf\$y)) == 2) {
    $stem.pred<-prediction($stem.rf\$predicted, $stem.rf\$y);
    $stem.perf<-performance($stem.pred, "tpr", "fpr");
    write(paste("PREDICTED", "CLASS", sep="\t"), file="$dir/$stem.train.predicted");
    write(paste($stem.rf\$predicted, $stem.rf\$y, sep="\t"), file="$dir/$stem.train.predicted", sep="\n", append=T);

    $grf("$dir/$stem.train.ROC.$grf");
    plot($stem.perf, col=rainbow(10));
    abline(0,1);
    dev.off();
    $stem.tst.pred<-prediction($stem.rf\$test\$predicted,$stem.tstData[1]);
    $stem.tst.perf<-performance($stem.tst.pred, "tpr", "fpr");
    $grf("$dir/$stem.test.ROC.$grf");
    plot($stem.tst.perf, col=rainbow(10));
    dev.off();
    $stem.auc<-performance($stem.pred, "auc");
    aucVal<-matrix(1:1);
    aucVal<-c(attr($stem.auc, "y.values")[[1]]);
    $stem.tpred<-prediction($stem.rf\$test\$predicted, $stem.tstData[,$tstlIndex1]);
    $stem.tauc<-performance($stem.tpred, "auc");
    taucVal<-c(attr($stem.tauc, "y.values")[[1]]);
    write(paste(aucVal, taucVal, $trnCases, $trnCons, $tstCases, $tstCons, sep="\\t"), \"$out\", append=T);
} else {
    rsq<-$stem.rf\$rsq[$stem.rf\$ntree];
    cor<-cor.test($stem.tstData[,$tstlIndex1], $stem.rf\$test\$predicted);
    write(paste(paste("RSQ", rsq), paste("RSQ", cor\$estimate * cor\$estimate), $trnCases, $trnCons, $tstCases, $tstCons, sep="\\t"), \"$out\", append=T);
}

R2a

# save the RF if specified
if($toSave && $i == 0) {
print SCRIPT <<R4;
rf<-$stem.rf;
save(rf, file="$toSave");
R4
}

print SCRIPT <<R2b;

# importance score
if(!is.null($stem.rf\$importance)) {
    write.table($stem.rf\$importance, "$outImp", sep="\t", append=T);
}

# proximity if exists
if(!is.null($stem.rf\$proximity)) {
    print("proximity exists");
    write.table($stem.rf\$proximity, "$outProx", sep="\t", append=T);
} else {
        print("proximity NOT exists");
}

R2b
}

    close SCRIPT;

# run R script
Util::run("R --no-save < $rscript", 1);

if($saveTest) {
    `catColumns.pl -o $dir/$stem.test.predicted $tstTmp.known $tstFile.predicted.tmp`;
    `mv $tstFile.predicted.tmp $dir/$stem.test.predicted`;
    `rm $tstTmp.known`;
}
else {
    `rm $inFile.predicted $trnTmp $tstTmp $rscript`;
}

Util::run("tail -1 $out", 0);
