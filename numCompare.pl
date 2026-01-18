#!/usr/bin/perl -w
sub printUsage() {
    print "Numeric comparison of the specified fields of different files and append results to the specified html file\n\n";
    print "Usage: ~ <title> <in1.csv> <fld1> <label1> <in2.csv> <fld2> <label2> ... <inN.csv> <fldN> <labelN> <out.html>\n";
    exit(1);
}

if(scalar(@ARGV) < 8) {
    printUsage();
}

use Flat;
use math;
use Util;

my $title = shift @ARGV;
my $out = pop @ARGV;
my ($dir, $outStem, $suf) = Util::getDirStemSuffix($out);

if(scalar(@ARGV) % 3 != 0) {
    printUsage();
}

my(@inFiles, @flds, @labels);

while(scalar(@ARGV) > 0) {
    my $in = Flat->new1(shift @ARGV);
    my $fld = $in->getFieldIndex(shift @ARGV);
    my $label = shift @ARGV;

    if(!$in->fieldIsNumeric($fld)) {
	die $in->getFieldName($fld)." of index $fld in ".$in->getFileName()." is not numeric\n";
    }

    push @inFiles, $in;
    push @flds, $fld;
    push @labels, $label;
}

open OUT, ">>$out" or die $!;

### compare and output results

# compare all-together
for(my($i) = 0; $i < scalar(@inFiles); $i++) {
    # box plot
}

# compare pair wise
print OUT "<h3>Numeric Comparison of $title</h3>\n";
print OUT "<table border=1>\n";
print OUT "<tr><th>Field</th><th>Mean</th><th>Var</th><th>Size</th></tr>\n";
my $pval = 'NA';

for(my($i) = 0; $i < scalar(@inFiles) - 1; $i++) {
    my $fname1 = $inFiles[$i]->getFileName();
    my($dir1, $stem1, $suf1) = Util::getDirStemSuffix($fname1);

    my(@arr1) = math::util::removeNaN($inFiles[$i]->getFieldValues($flds[$i]));
    my($mean1) = math::util::getMean(@arr1);
    my($var1) = math::util::getVariance(@arr1);

    for(my($j) = $i + 1; $j < scalar(@inFiles); $j++) {
	my $fname2 = $inFiles[$j]->getFileName();
	print "Comparing $fname1 with $fname2\n";
	my($dir2, $stem2, $suf2) = Util::getDirStemSuffix($fname2);

	# t-tests
	my(@arr2) = math::util::removeNaN($inFiles[$j]->getFieldValues($flds[$j]));
	my($mean2) = math::util::getMean(@arr2);
	my($var2) = math::util::getVariance(@arr2);
	my $t = math::util::getT([@arr1], [@arr2]);
	my $wilcoxPval = math::util::getWilcox([@arr1], [@arr2], "/tmp/wilcox.r");
	
	if($i == 0 && $j == 1) {
	    $pval = $wilcoxPval;
	}

	# print out info
	print OUT "<tr><td>$labels[$i]</td><td>$mean1</td><td>$var1</td><td>", scalar(@arr1), "</td></tr>", 
	"<tr><td>$labels[$j]</td><td>$mean2</td><td>$var2</td><td>", scalar(@arr2), "</td></tr>\n",
	"<tr><td>t (wilcox p-val) </td><td colspan=3>$t ($wilcoxPval)</td></tr>\n";
    }
}

my(@colors) = ("red", "green", "blue", "cyan", "yellow", "magenta");
my($densityCmd) = "density.R.pl '$title (p $pval)'";
my $picFile = $outStem;

for(my($i) = 0; $i < scalar(@inFiles); $i++) {
    my $fname1 = $inFiles[$i]->getFileName();
    my($dir1, $stem1, $suf1) = Util::getDirStemSuffix($fname1);
    $picFile .= ".".Util::shortenName("$stem1$flds[$i]$suf1", 60);
    $densityCmd .= " ".$inFiles[$i]->getFileName()." $flds[$i] $colors[$i] $labels[$i]";
}

$picFile .= ".jpeg";
$densityCmd .= " $dir/$picFile";
Util::run($densityCmd, 1);
print OUT "<tr><td colspan=4><img src=\"$picFile\"/></td></tr>\n";

print OUT "</table><p>\n";
#print OUT "</body>\n";
#print OUT "</html>\n";

close OUT;
