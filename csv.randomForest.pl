#!/usr/bin/perl -w

sub printUsage {
    print "Wrapps the randomForest R version\n";
    print "Usage: ~ [-f <predfile.csv> -t <topNumOfPreds>] [-i iter] [-c] [-g png|jpeg|postscript] [-s|l <saved.Rdata>] [-a] -o \"randomForest options\" [-m] <in.csv> <label_field_index> [<predictor_field1_index> ... <predictor_fieldn_index>] <out>\n";
    print "-f\tthe file with header containing the predictors. If specifiefied, -t has to be specified as well,\n";
    print "  \tbut predictors cannot be specified at command line\n";
    print "-t\tthe top number of predictors in the file specified by -f\n";
    print "-i\tnumber of iterations\n";
    print "-c\tclassification. Default is to let RF find out.\n";
    print "-g\twhich graphics format to use. default is postscript\n";
    print "-s\tsave the forest built to the specified file\n";
    print "-i\tNubmer of iteration. Default is 1\n";
    print "-a\tWhether to append results to the output file or start from new. Default is to start from new.\n";
    print "-m\tTo keep intermediate files. Default is to delete\n\n";
#    print "\tCommon randomForest options:\n";
#    print "\t
    exit(1);
}

use Util;
@ARGV = Util::explainCmdLine(@ARGV);

use Flat;
use File::stat;
use Time::localtime;

my $cmd = Util::getCmdLine();

use Getopt::Std;
my(%options);
getopts("mcg:o:i:s:l:af:t:", \%options);

my $class = "";

if(exists $options{"c"}) {
    $class = 1;
}

my($opts) = "";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

my $append = "FALSE";

if(exists $options{"a"}) {
    $append = "TRUE";
}

my $toSave = "";

if(exists $options{"s"}) {
    $toSave = $options{"s"};
}

my $iter = 1;

if(exists $options{"i"}) {
    $iter = $options{"i"};
}

my $grf = "pdf";

if(exists $options{"g"}) {
    $grf = $options{"g"};
}

my $predFile = "";
my $numPreds = 0;

if(exists $options{"f"}) {
    $predFile = $options{"f"};

    if(exists $options{"t"}) {
	$numPreds = $options{"t"};
    }
    else {
	printUsage();
    }
}

if(scalar(@ARGV) < 3) {
    printUsage();
}

my $inFile = shift @ARGV;
my $in = Flat->new($inFile, 1);
my $lIndex = $in->getFieldIndex(shift @ARGV); # label index
my $out = pop @ARGV;
my @predIndice;

if($predFile) {
    my $predFlat = Flat->new1($predFile);

    @predIndice = $in->getFieldIndice($predFlat->getTopFieldValues(0, $numPreds));
}
else {
    if(scalar(@ARGV) == 0) {
	printUsage();
    }
    else {
	@predIndice = $in->getFieldIndice([@ARGV]);
    }
}

my $outImp = "$out.importance.csv";
my $outProx = "$out.proximity.csv";

if(!$in->hasHeader()) {
    die "The input file has to have column names\n";
}

if($in->getFieldIndex($out, 1) != -1) {
    die "An input field cannot be taken as the output file\n";
}

if(exists $options{"a"}) {
    $append = "TRUE";
}
else {
    Util::rmIfExists([$out], 0);
}

my @fnames = $in->getFieldNames();
my $lFld = $fnames[$lIndex];
my @predNames = map { $fnames[$_]; } @predIndice;

my($dir, $stem, $suf) = Util::getDirStemSuffix($out);

open SCRIPT, "+>$out.R" or die $!;

my $rfOptions = "na.action=NULL";

if($opts) {
    $rfOptions = $rfOptions.", $opts";
}

Util::run("extractColumns.pl $inFile '".join("|", $lIndex, @predIndice)."' $out.allFlds", 0);
Util::run("rmComments.pl $out.allFlds", 0);

print SCRIPT <<R0;
library(randomForest);
library(ROCR);
rfData<-read.table("$out.allFlds", header=TRUE, sep="\\t", na.strings="NA");
R0

# if classification, then modify the label field to be a categorical field by prefixing with 'c'
if($class) {
print SCRIPT <<R0a;
rfData[,$lIndex]<-factor(rfData[,$lIndex]);
R0a
}

for(my($i) = 0; $i < $iter; $i++) {
    if($i > 0) {
	$append = "TRUE";
    }

print SCRIPT <<R1;
rf<-randomForest($lFld ~ ., data=rfData, $rfOptions)

if(length(unique(rf\$y)) == 2) {# not sure which is better: if(!is.factor(rf\$y)) ?
    rfPred<-prediction(rf\$predicted, rf\$y);
    rfPerf<-performance(rfPred, "tpr", "fpr");
    $grf("$dir/$stem.self.ROC.$grf");
    plot(rfPerf, col=rainbow(10));
    abline(0,1);
    dev.off();
    $stem.auc<-performance(rfPred, "auc");
    perfVal<-matrix(1:1);
    perfVal<-c(attr($stem.auc, "y.values")[[1]]);
} else {
    perfVal<-c(paste("RSQ", rf\$rsq[rf\$ntree]));
}

# importance score
if(!is.null(rf\$importanceSD)) {
    write.table(cbind(rf\$importance, rf\$importanceSD), "$outImp", sep="\\t", append=$append);
} else {
    write.table(rf\$importance, "$outImp", sep="\\t", append=$append);
}

# proximity if exists
if(!is.null(rf\$proximity)) {
    write.table(cbind(rfData, rf\$proximity), "$outProx", sep="\\t", append=$append);
}

R1

if($append eq "FALSE" && $iter == 0) {
    print SCRIPT <<R2;
    write(paste("# $cmd\nACCURACY\n",perfVal), \"$out\", append=$append);
R2
} else {
print SCRIPT <<R3;
write(perfVal, \"$out\", append=TRUE);
R3
}

# save the RF if specified
if($toSave && $i == 0) {
    my $d = ctime(stat($inFile)->mtime());

    print SCRIPT <<R4;
    info<-list(dataFile="$inFile", modDate="$d");
    save(rf, info, file="$toSave");
R4
}

}

close SCRIPT;

# run R script
Util::run("R --no-save < $out.R", 1);

if(!(exists $options{"m"})) {
    Util::run("rm $out.R $out.allFlds", 1);
  }

Util::run("tail -1 $out", 0);
