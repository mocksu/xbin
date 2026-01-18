#!/usr/bin/perl -w

sub printUsage {
    print "Predict using the specified random model\n\n";
    print "Usage: ~ [-l] [-m] [-g png|jpeg|pdf|postscript] -o \"randomForest options\" <rf.model> <pred.csv> [<label>] [<modelFldx:predFldx> ... <modelFldz:predFldz>] (<aucOout.csv>|<predOut.csv>)\n";
    print "       -l\tThere is not label field in <pred.csv>. If so, do not specify <label> nor <predFldx> at the command line.\n";
    print "       -m\tTo keep intermediate files. Default is to delete\n";
    print "       If a field name in <pred.csv> does not match that in the model file, rename it\n";
    print "Remember proximity does not work for regression\n\n";
    exit(1);
}

use Util;
use Flat;
use math;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("lmg:o:", \%options);

if(scalar(@ARGV) < 3) {
    printUsage();
}

my $model = shift @ARGV;
my $predFile = shift @ARGV;
my $outFile = pop @ARGV;

if(!(-e $model)) {
    print "Model file '$model' does not exist\n";
    printUsage();
}

if(!(-e $predFile)) {
    print "PredFile '$predFile' does not exist\n";
    printUsage();
}

my $grf = "pdf";

if(exists $options{"g"}) {
    $grf = $options{"g"};
}

my($opts) = "";

if(exists $options{"o"}) {
    $opts = ", ".$options{"o"};
}

if(!(exists $options{"l"})) {
    if(scalar(@ARGV) < 1) {
	printUsage();
    }
}
# else OK

# get the field names from the model
use RF;
my(@mdlFldNames) = @{RF::getFieldNamesFromModel($model)};

my $pred = Flat->new($predFile, 1);
my $labelField = "";

if(!(exists $options{"l"})) {
    $labelField = $pred->getFieldName(shift @ARGV);
}

my @predFields;

my $fldIndex;
    
my @renamedFlds = @ARGV; # fields to be renamed
    
my %model2file2; 

for(my($i) = 0; $i < scalar(@renamedFlds); $i++) {
    my($f1, $f2) = split(/:/, $renamedFlds[$i]);
    
    $model2file2{$1} = $2;
}

# check to see if the field names stored in the model exist in <pred.csv>
for(my($i) = 0; $i < scalar(@mdlFldNames); $i++) {
    if(exists $model2file2{$mdlFldNames[$i]}) {
	$fldIndex = $pred->getFieldIndex($model2file2{$mdlFldNames[$i]});
    }
    else {
	$fldIndex = $pred->getFieldIndex($mdlFldNames[$i]);
    }

    if($fldIndex == -1) {
	my @predFldNames = $pred->getFieldNames();
	die "Field name '$mdlFldNames[$i]' is not in '$predFile'.\nFields in the model: @mdlFldNames\nFields in '$predFile': @predFldNames\n";
    }
    else {
	$predFields[$i] = $pred->getFieldName($fldIndex);
    }
}

my($dir, $stem, $suf) = Util::getDirStemSuffix($outFile);

# extract prediction related fields
#my $allFldsFile = "$outFile.allFlds";
my @allFlds;

if($labelField eq "") { # no label specified
    @allFlds = @predFields;
}
else {
    @allFlds = ($labelField, @predFields);
}

my $predRE = join("|", map { "$_" } @allFlds);

# remove rows empty values ( "NA" seems to be OK with a saved RF model)
my $ready = "$outFile.ready";
my $naRE = join(" ", map {  "$_ '^\\s*\$|NA'" } @allFlds);
my $naRemoved = "$outFile.NARemoved";

Util::run("rmRows.pl $predFile /dev/null $naRemoved $naRE", 0);
Util::run("extractColumns.pl $naRemoved '$predRE' $ready", 0);

my $rscript = "$stem.R";

open SCRIPT, "+>$rscript" or die "Cannot open $rscript\n";
print SCRIPT <<R0a;
library(randomForest);
library(ROCR);
load("$model");
rfPrdData<-read.table("$ready", header=TRUE, fill=T);

predicted<-predict(rf, rfPrdData $opts);

write("PREDICTED", "$outFile.pred0", append=F);
write(predicted, \"$outFile.pred0\", append=T, sep="\\n");

# proximity if exists
if(!is.null(rf\$proximity)) {
    write.table(cbind(rfData, rf\$proximity), "$outFile.proximity", sep="\\t");
}

R0a

close SCRIPT;

# run R script
Util::run("R --no-save --no-restore < $rscript >& /dev/null", 1);

# concatenate "$outFile.pred" & $predFile to form a single output file
Util::rmIfExists(["$outFile.pred"]);

# get the output
if($labelField eq "") { # label field not specified, no AUC computation
    Util::run("catColumns.pl -o $outFile.pred0 $ready $outFile.combined", 1);
    Util::run("mv $outFile.pred0 $outFile", 1);
}
else { # compute AUC
    if(scalar(Flat->new1($naRemoved)->getUniqueValues($labelField)) == 2) {
	Util::run("catColumns.pl -o $outFile.pred0 $naRemoved $outFile.pred", 1);
	Util::run("getAUC.pl -g $grf $outFile.pred $labelField PREDICTED $outFile", 1);
    }
    else {
      Util::run("catColumns.pl -o $outFile.pred0 $naRemoved $outFile.combined", 1);
      Util::run("mv $outFile.pred0 $outFile", 1);
    }
}

if(!(exists $options{"m"})) {
    if($labelField eq "") {
	Util::run("rm $rscript $naRemoved $ready", 1);
      }
    else {
	Util::rmIfExists([$rscript, "$outFile.pred0", "$outFile.pred", "$ready"]);
      }
}
