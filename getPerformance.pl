#!/usr/bin/perl -w

sub printUsage {
    print "Compute and output sensitivity & specificity, precision & recall, ppv & npv\n\n";
    print "Usage: ~ [-o operation_on-predFld] <in.csv> <label_field> <predictor_field> <out.csv>\n";
    exit(1);
}

use Flat;
use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("o:", \%options);

my($op) = "";

if(exists $options{"o"}) {
    $op = $options{"o"};
}

if(scalar(@ARGV) != 4) {
    printUsage();
}

my($in) = Flat->new(shift @ARGV, 1);
my $lfld = $in->getFieldIndex(shift @ARGV);
my $pfld = $in->getFieldIndex(shift @ARGV);
my($out) = shift @ARGV;

#print "lfld = $lfld, pfld = $pfld\n";

my(@fnames) = $in->getFieldNames();
my(@pairs);

my %label2sum;

while($row = $in->readNextRow()) {
    $label2sum{$row->[$lfld]}++;

    if($op) {
	push @pairs, [$row->[$lfld], eval("$op($row->[$pfld])")];
    }
    else {
	push @pairs, [$row->[$lfld], $row->[$pfld]];
    }
}

# check if there are only two classes
my(@labels) = sort { $a <=> $b } keys %label2sum;
my $TOTAL_NEG = $label2sum{$labels[0]};
my $TOTAL_POS = $label2sum{$labels[1]};
#print "TOTAL_NEG = $TOTAL_NEG, TOTAL_POS = $TOTAL_POS\n";

if(scalar(@labels) != 2) {
    print "Expecting two classes, but got ", scalar(@labels), "\n";
    printUsage();
}


# sort the pairs with predictor value ranked from high to low
my @sorted = sort { $b->[1] <=> $a->[1] } @pairs;
my($tp, $fp, $tn, $fn) = (0,0,$TOTAL_NEG,$TOTAL_POS);
my($preTP, $preTN) = (0,$TOTAL_NEG);

my(%counted);

open OUT, "+>$out" or die "Cannot open $out\n";
print OUT join("\t", "PREDICTED", "TP", "FP", "TN", "FN", "SLOPE", "ODDS", "SENS(REC)", "SPEC", "PPV(PREC)", "NPV"), "\n";

for(my($i) = 0; $i < scalar(@sorted); $i++) {
    if($i != 0 && !(exists $counted{$sorted[$i]->[1]})) {
	printPerf($sorted[$i-1]);
    }

    if($sorted[$i]->[0] == $labels[0]) { # negative
	$fp++;
    }
    else { # positive
	$tp++;
    }
    
    $counted{$sorted[$i]->[1]} = 1;
}

# print the last entry
printPerf(pop @sorted);

sub printPerf {
    my($s) = @_;

    # process the previous value if exists
    my $tn = $TOTAL_NEG - $fp;
    my $fn = $TOTAL_POS - $tp;
    
    # sensitivity & specificity
    my $sens = ($tp + $fn == 0)?"Inf":($tp / ($tp + $fn));
    my $spec = ($tn + $fp == 0)?"Inf":($tn / ($tn + $fp));
    
    # ppv & npv
    my $ppv = ($tp + $fp == 0)?"Inf":($tp / ($tp + $fp));
    my $npv = ($tn + $fn == 0)?"Inf":($tn / ($tn + $fn));
    
    # precision and recall
#    my $prec = $ppv;
#    my $recall = $sens;

    # odds ratio
    my $odds = ($fp == 0 || $fn == 0)?"Inf":($tp * $tn) / ($fp * $fn);

    # slope
    
    my $slope = ($preTN == $tn)?"Inf":($TOTAL_NEG / $TOTAL_POS) * ($tp - $preTP) / ($preTN - $tn);
    $preTP = $tp;
    $preTN = $tn;

    printf OUT "%f\t%d\t%d\t%d\t%d\t%5.4f\t%5.4f\t%5.4f\t%5.4f\t%5.4f\t%5.4f\n", $s->[1], $tp, $fp, $tn, $fn, $slope, $odds, $sens, $spec, $ppv, $npv;
}
