#!/usr/bin/perl -w
sub printUsage() {
    print "Categorical comparison of the specified fields of different files\n\n";
    print "Usage: ~ [-o 'opColumns.pl op'] <title> <in1.csv> <fld1> <label1> <in2.csv> <fld2> <label2> ... <inN.csv> <fldN> <labelN> <out.html>\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("o:", \%options);
my($op) = "";

if(exists $options{"o"}) {
    $op = $options{"o"};
}

if(scalar(@ARGV) < 8) {
    printUsage();
}

my $title = shift @ARGV;
my $out = pop @ARGV;

if(scalar(@ARGV) % 3 != 0) {
    printUsage();
}

use Flat;
use math;

my(@inFiles, @flds, @labels);

while(scalar(@ARGV) > 0) {
    my $inFile = shift @ARGV;
    my $fldName = shift @ARGV;

    if($op) {
	Util::run("opColumns.pl $inFile '$op' $fldName OP_$fldName $inFile.op", 1);
	  $inFile = "$inFile.op";
	  $fldName = "OP_$fldName";
      }
    
    my $in = Flat->new1($inFile);
    my $fld = $in->getFieldIndex($fldName);
    my $label = shift @ARGV;

    push @inFiles, $in;
    push @flds, $fld;
    push @labels, $label;
}

open OUT, ">>$out" or die $!;
print OUT "<html><title>Categorical Comparison of $title @labels</title></html>\n";
print OUT "<body>\n";

### compare and output results

# compare all-together
for(my($i) = 0; $i < scalar(@inFiles); $i++) {
    # box plot
}

# compare pair wise
print OUT "<h3>Categorical Comparison of $title</h3>\n";
print OUT "<table border=1>\n";
print OUT "<tr><th>Field</th><th>Value</th><th>Count (Total)</th><th>Pct</th><th>Pct Ratio</th></tr>\n";

my(%val2count); # categorical data for chi-square test

for(my($i) = 0; $i < scalar(@inFiles) - 1; $i++) {
    my(@arr1) = $inFiles[$i]->getFieldValues($flds[$i]);
    my(%val2count1);
    map {$val2count1{$_}++;} @arr1;
    my($sum1) = math::util::getSum(values %val2count1);
    my @keys1 = keys %val2count1;
    %{$val2count{$i}} = %val2count1;

    # category comparison
    for(my($j) = $i + 1; $j < scalar(@inFiles); $j++) {
	print "Comparing ", $inFiles[$i]->getFileName(), " with ", $inFiles[$j]->getFileName(), "\n";
	my(@arr2) = $inFiles[$j]->getFieldValues($flds[$j]);
	my(%val2count2);
	map {$val2count2{$_}++;} @arr2;
	my($sum2) = math::util::getSum(values %val2count2);
	my @keys2 = keys %val2count2;
	my @keys12 = @keys1;
	push @keys12, @keys2;
	@keys12 = math::util::getUniqueElements(@keys12);
	%{$val2count{$j}} = %val2count2;

	foreach $val (sort @keys12) {
	    my $ratio;

	    if(exists $val2count2{$val}) {
		print "val2count1{$val} = $val2count1{$val}, sum1 = $sum1, val2count2{$val} = $val2count2{$val}, sum2 = $sum2\n";
		$ratio = $val2count1{$val}/$sum1 / ($val2count2{$val}/$sum2);
	    }
	    elsif(exists $val2count1{$val}) { 
		$ratio = "$val2count1{$val}/0";
	    }
	    else {
		$ratio = "0/0";
	    }

	    print OUT "<tr><td>$labels[$i]</td><td>$val</td><td>$val2count1{$val} ($sum1)</td><td>", $val2count1{$val}/$sum1, "</td><td rowspan=2>", $ratio, "</td></tr>\n", 
	    "<tr><td>$labels[$j]</td><td>$val</td><td>$val2count2{$val} ($sum2)</td><td>", $val2count2{$val}/$sum2, "</td></tr>\n";
	} 
	
#	print OUT "<tr><td colspan=2>Sum</td><td colspan=2>$sum1</td><td colspan=4>$sum2</td><td></td></tr>\n";
    }
}

my(%catValCounts);
foreach $i (keys %val2count) {
    map {$catValCounts{$_}++; } keys %{$val2count{$i}}; 
}

my(@catVals) = keys %catValCounts;

my(@catData); # categorical data for chi-square analysis
foreach $i (keys %val2count) {
    for(my($j) = 0; $j < scalar(@catVals); $j++) {
	if(exists $val2count{$i}{$catVals[$j]}) {
	    $catData[$i][$j] = $val2count{$i}{$catVals[$j]};
	}
	else {
	    $catData[$i][$j] = 0;
	}
    }
}

my $chisq = math::util::getChiSquare([@catData], "$out.r");
print OUT "<tr><td>chi-squared</td><td>X-squared = $chisq->[0]</td><td>df = $chisq->[1]</td><td colspan=2>p-value $chisq->[2]</td></tr>\n"; 
print OUT "</table><p>\n";
#print OUT "</body>\n";
#print OUT "</html>\n";

close OUT;
