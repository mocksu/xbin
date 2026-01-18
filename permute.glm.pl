#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my(%options);
getopts("o:", \%options);

sub printUsage {
    print "Permute the label in R glm and output the beta, stderr, p-value, etc. when approppriate\n";
    print "Usage: ~ -o <glmOptions> <numOfPermutations> <in.csv> <label> <pred1> ... <predN> <out.csv>\n";
    print "       <in.csv> must has a header row to describe each field\n";
    exit(1);
}

if(scalar(@ARGV) < 5) {
    printUsage();
}

my $num = shift @ARGV;

if(math::util::isNaN($num)) {
    print "expecting <numOfPermutations> to be a number, but got $num\n";
    printUsage();
}

my $inFile = shift @ARGV;
my $in = Flat->new1($inFile);
my $lindex = $in->getFieldIndex(shift @ARGV) + 1; # label index
my $out = pop @ARGV;
my @pindice = map { $in->getFieldIndex($_) + 1; } @ARGV;

if(!$in->hasHeader()) {
    print "<in.csv> must has a header row to describe each field\n";
    printUsage();
}

# start from an empty output file
#Util::rmIfExists($out);

# write the R script to permute and test
open RS, "+>$out.R" or die "Cannot open $out.R\n";

my $optStr = exists $options{"o"}?$options{"o"}:"";

my $modelStr = "sample(d[,$lindex]) ~ ".join("+", map { "d[,$_]"; } @pindice);
my $headerRow = join("\t", map { ("$_.Estimate", "$_.Stderr", "$_.Z", "$_.PVAL") } ("Intercept", map {$in->getFieldName($_ - 1) } @pindice));

print RS<<R0;
d<-read.table("$inFile", header=T);
write("$headerRow", file="$out");
for (iter in 1:$num) {
    s<-summary(glm($modelStr, $optStr));
R0
# print out the result parameters for the predictors
for(my($i) = 1; $i <= scalar(@pindice); $i++) {
    print RS<<R1;
    
    write.table(as.matrix(coefficients(s)), file="$out", sep = "\t", row.names=F, col.names=F,append=T, eol="\t");
R1
}

print RS<<R2;
write("",file="$out", append=T);
}
R2

close RS;

`R --no-save<$out.R`;
