#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

sub printUsage {
    print "Usage: ~ [-s t|c] [-d df] <workingDir> <inFile.csv> <pValFld> <tFld|chisqFld> <title> <colorOfPlot> <out.tiff>\n";
    print "       -s\t't' for t-score field, 'c' for chisq (default)\n\n";
    exit(1);
}

my(%options);
getopts("s:d:", \%options);
my($stat) = exists $options{"s"}?$options{"s"}:"c";
my $df = exists $options{"d"}?$options{"d"}:1;

if($stat ne "c" && $stat ne "t") {
    print "-s has to be either 'c' or 't'\n\n";
    printUsage();
}

if(scalar(@ARGV) != 7) {
    print "Incorrect number of inputs: expecting 7, got ", scalar(@ARGV), "\n\n";
    printUsage();
}

my $wd = shift @ARGV;
my $inFile0 = shift @ARGV;
my $pvalFld0 = shift @ARGV;
my $statFld0 = shift @ARGV;
# remove "NA" entries
my $inFile = "$inFile0.noNA";
Util::run("rmRows.pl $inFile0 /dev/null $inFile $pvalFld0 NA $statFld0 NA", 1);
Util::run("rmComments.pl $inFile", 1);
my $in = Flat->new1($inFile);
my $pvalFld = $in->getFieldIndex($pvalFld0) + 1;
my $statFld = $in->getFieldIndex($statFld0) + 1;
my $title = shift @ARGV;
my $color = shift @ARGV;
my $out = shift @ARGV;

my($odir, $ostem, $osuf) = Util::getDirStemSuffix($out);

my $rscript = "$out.R";

open SCRIPT, "+>$rscript" or die "Cannot open $rscript\n";

print SCRIPT<<R0;
wd<-"$wd";
infile<-"$inFile";
main.lab<-"$title";
col.color <- "$color";
output <- "$out";

setwd(wd);

ps <- read.delim(infile, as.is=T, header=F, skip=1); # skipping 'seq=" "' works both for tab & whitespace

x <- ppoints(ps\$V$pvalFld);
R0

if($stat eq "c") {
    print SCRIPT <<R1;
lambda <- as.numeric(round(median(ps\$V$statFld)/qchisq(0.5,$df),3)); # for 1 df test only. if for 2+ df tests, replace '1' with d.f. (e.g. for 'q' analysis, df = #_of_studies - 1)
R1
}
else {
    print SCRIPT<<R2;
lambda <- as.numeric(round(median(ps\$V$statFld^2)/qchisq(0.5,$df),3)); # for 1 df test only. if for 2+ df tests, this has to be modified
R2
}

print SCRIPT<<R3;
## Plot ##
tiff(output, width=800, height=800);

plot(-log10(x), -log10(sort(ps\$V$pvalFld)), col=col.color, pch=21, lwd=3, main=main.lab, xlab="Expected", ylab="Observed");
abline(a=0, b=1, lty=2);

## Add text ##
txtlabel=paste("lambda=",deparse(lambda));
text(1,5,labels=txtlabel);

dev.off();
R3

close SCRIPT;

Util::run("R --no-save < $rscript", 1);
