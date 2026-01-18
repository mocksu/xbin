#!/usr/bin/perl -w

use Flat;
use math;
use Util;
use Getopt::Std;
my(%options);
getopts("vswd:e:", \%options);

if(scalar(@ARGV) < 2) {
    print "Usage: ~ [-e RE] [-v|s] [-w] [-d \"fname1 ... fnamen>\"] <input.csv> <fld_no1|fld_name1> .. <fld_non|fld_namen>\n";
    print "\t-e -- exclude keys with the specified regular expression pattern. e.g. 'NA'\n";
    print "\t-s -- semi verbose mode\n";
    print "\t-v -- verbose\n";
    print "\t-w -- sort by keyword instead of count\n";
    print "\t-d -- fields to display after unique counting. Default is the key fields\n";
    exit(1);
}

my($semi) = exists $options{"s"} || exists $options{"d"};
my($verbose) = exists $options{"v"};
my($sortByWord) = exists $options{"w"};
my $exRE = exists $options{"e"}?$options{"e"}:"";

my($in) = Flat->new1(shift @ARGV);

my(@fldIndice) = $in->getFieldIndice([@ARGV]);
my(@fldNames) = $in->getFieldNames(@ARGV);

my(@displayFldIndice); # indice in (@fldIndice)

print join("\t", @fldNames), "\n";

if(exists $options{"d"}) {
    my(@fnames) = split(/\s+/, $options{"d"});
    
    @displayFldIndice = $in->getFieldIndice([@fnames]);
    
    if(scalar(@displayFldIndice) < scalar(@fnames)) {
	Util::dieIt("Not all specified fields exist in ", $in->getFileName(), ": @fnames\n");
      }
}
else {
    @displayFldIndice = @fldIndice;

    if(scalar(@displayFldIndice) < scalar(@ARGV)) {
	Util::dieIt("Not all specified fields exist in ", $in->getFileName(), ": @ARGV\n");
      }
}

for(my($i) = 0; $i < scalar(@displayFldIndice); $i++) {
    if($displayFldIndice[$i] == -1) {
	Util::dieIt("Display field $i does not exist in ", $in->getFileName());
      }
}

my(%uniqueValIndice) = $in->getIndiceOfFieldValues(@fldIndice);
my(%displayVal2count); # display values 

my(@data) = $in->getDataArray();

foreach $fldVals (sort keys %uniqueValIndice) {
    if($exRE && $fldVals =~ /$exRE/) { # if the key value is excluded
	print "Skipping field value $fldVals\n";
	delete $uniqueValIndice{$fldVals};
	next;
    }

    my(@indice) = @{$uniqueValIndice{$fldVals}};

    # create unique display value for the duplicates
    my(%uniqueFldVals);

    for(my($i) = 0; $i < scalar(@displayFldIndice); $i++) {
	for(my($j) = 0; $j < scalar(@indice); $j++) {
	    $uniqueFldVals{$i}{$data[$indice[$j]][$displayFldIndice[$i]]} = 1;
	}
    }

#    my($dval) = join(",", map { $data[$indice[0]][$_] } @displayFldIndice);
    my($dval) = join(",", map {join("/", sort keys %{$uniqueFldVals{$_}})} sort {$a <=> $b } keys %uniqueFldVals);

    $displayVal2count{$dval}++;

    if($verbose && !$semi) {
	for(my($i) = 0; $i < scalar(@indice); $i++) {
	    my(@row) = @{$data[$indice[$i]]};
	    
	    print "Duplicated: ", Flat::dataRowToString(map { $row[$_]; } @fldIndice), "\n";
	}
    }
}

my $accuPct = 0;
my $total = math::util::getSum(map { scalar(@{$uniqueValIndice{$_}}) } keys %uniqueValIndice);

if($semi || $verbose) {
    if(exists $options{"d"}) {
	foreach $v (sort { if($sortByWord) { $a cmp $b } else { scalar(@{$displayVal2count{$b}}) <=> scalar(@{$displayVal2count{$a}})}} keys %displayVal2count) {
	    my $pct = $displayVal2count{$v} / $total;
	    $accuPct += $pct;
	    print "$v\t$displayVal2count{$v}\t$pct\t$accuPct\n";
	}
    }
    else {
	foreach $v (sort { if($sortByWord) { $a cmp $b } else { scalar(@{$uniqueValIndice{$b}}) <=> scalar(@{$uniqueValIndice{$a}})}} keys %uniqueValIndice) {
	    my $pct = scalar(@{$uniqueValIndice{$v}}) / $total;
	    $accuPct += $pct;
	    print "$v\t", scalar(@{$uniqueValIndice{$v}}), "\t$pct\t$accuPct\n";
	}
    }
}

print "\nTotal unique values: ", scalar(keys %uniqueValIndice), "\n";
print "\nTotal cases: ", $total, "\n\n";
