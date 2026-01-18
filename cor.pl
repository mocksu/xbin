#!/usr/bin/perl -w

sub printUsage {
    print "Usage: ~ [-m p|s|k] <in.csv> <fld1> ... <fldN> <out.csv>\n";
    print "       -p: pearson\n";
    print "       -s: spearman\n";
    print "       -k: kendall\n";
    exit(1);
}

use Util;
use Flat;
use Getopt::Std;

my(%options);
getopts("m:", \%options);
my($method) = "pearson";

if(exists $options{"m"}) {
    my $m = $options{"m"};

    if($m eq "p") {
	$method = "pearson";
    }
    elsif($m eq "s") {
	$method = "spearman";
    }
    elsif($m eq "k") {
	$method = "kendall";
    }
    else {
	print "-m has to be p|s|k\n";
	printUsage();
    }
}

if(scalar(@ARGV) < 3) {
    printUsage();
}

my $inFile = shift @ARGV;
my($in) = Flat->new($inFile, 1);
my($out) = pop @ARGV;
my(@fldIndice) = $in->getFieldIndice([@ARGV]);
my(@fldNames) = map { $in->getFieldName($_); } @fldIndice;
my $indiceStr = join(", ", map { "d[,".($_+1)."]" } @fldIndice);
open OUT, "+>$out" or die "Cannot open $out\n";
print OUT join("\t", $method, @fldNames), "\n";

open RS, "+>$out.R" or die "Cannot open $out.R\n";
my $rout = "$out.Rout";

Util::rmIfExists($rout);
    
print RS<<R0;
d<-read.table("$inFile", header=T, fill=T);
nd<-cbind($indiceStr);

s<-dim(nd)[2];
cor<-matrix(1,nrow=s,ncol=s);

for(i in 1:(s-1)) {
    i1<-i+1;

    for(j in i1:s) {
	cor[i,j]<-cor.test(nd[,i], nd[,j], method="$method")\$estimate;
	cor[j,i]<-cor[i,j];
    }
}

for(i in 1:s) {
    write(cor[i,], sep="\t", file="$rout", ncolumns=length(cor[i,]), append=T);
}

R0

close RS;

Util::run("R --no-restore --no-save < $out.R", 1);

# modify the output file to add row headers
open ROUT, "<$rout" or die "Cannot open $rout\n";

for(my($i) = 0; $i < scalar(@fldNames); $i++) {
    my $line = <ROUT>;
    print OUT $fldNames[$i], "\t", $line;
}

close ROUT;
close OUT;

# remove intermediate files

#Util::run("rm $rout $out.R", 0);
