#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;
my(%options);
getopts("o:a", \%options);
my($opts) = "";
my$append = "FALSE";

if(exists $options{"o"}) {
    $opts = $options{"o"};
}

if(scalar(@ARGV) < 4) {
    print "Wrapps the glm R version\n";
    print "Usage: ~ [-a] -o \"glm options\" <in.csv> <label_field_index> <predictor_field1_index> ... <predictor_fieldn_index> <out>\n";
    print "-a\tto append results to the output file. Default is override\n";
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

if(exists $options{"a"}) {
    $append = "TRUE";
}
else {
    Util::run("rm $out", 0); # clean it up
}

# extract the involved fields into a separate file because R might not be able to read the input correctly
Util::run("extractColumns.pl $inFile '".join("|", $lIndex, @predIndice)."' $out.data", 1);

my @fnames = $in->getFieldNames();
my $lFld = $fnames[$lIndex];
my @predNames = map { $fnames[$_]; } @predIndice;
my $predForms = join("+", @predNames);
$predForms =~ s/\-/\./g;

my($dir, $stem, $suf) = Util::getDirStemSuffix($out);

open SCRIPT, "+>$out.R" or die $!;

my $rOptions = "na.action=na.exclude";

if($opts) {
    $rOptions = $rOptions.", $opts";
}

#my $headerRow = join("\t", "AUC", map { ("$_.Estimate", "$_.Stderr", "$_.Z", "$_.PVAL") } ("Intercept", map {$in->getFieldName($_) } @predNames));
my $headerRow = join("\t", map { ("$_.Estimate", "$_.Stderr", "$_.Z", "$_.PVAL") } ("Intercept", map {$in->getFieldName($_) } @predNames));

print SCRIPT <<R;
library(ROCR)
gdata<-read.table("$out.data", sep="\\t", header=TRUE, na.strings="NA")
grst<-glm($lFld ~ $predForms, data=gdata, $rOptions)
#gpred<-prediction(grst\$fitted.values, grst\$y)
#gperf<-performance(gpred, "tpr", "fpr")
#plot(gperf, col=rainbow(10))
#gauc<-performance(gpred, "auc")
#aucVal<-matrix(1:1)
#aucVal<-c(attr(gauc, "y.values")[[1]])
#gauc;

# write the glm results
R

if($append eq "FALSE") { # not specified to append at the command line, write a header line
print SCRIPT<<R;
    write("$headerRow", file=\"$out\");
R
}

print SCRIPT<<R;
#write.table(c(attr(gauc, "y.values")[[1]], as.matrix(coefficients(summary(grst)))), file=\"$out\", sep="\t", row.names=F, col.names=F,append=T, eol="\t"); # forget about auc for now because "c(..)" messes up the order of elements
write.table(as.matrix(coefficients(summary(grst))), file=\"$out\", sep="\t", row.names=F, col.names=F,append=T, eol="\t");
write("",file="$out", append=T); # return
R

close SCRIPT;

# run R script
Util::run("R --no-save < $out.R", 1);
Util::run("trim.pl $out $out", 0);
Util::run("tail $out", 1);
