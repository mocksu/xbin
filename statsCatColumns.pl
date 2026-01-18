#!/usr/bin/perl -w

if(scalar(@ARGV) < 4) {
    print "For each specified category, compute the mean, stdev, and 95%C.I. of the specified field\n\n";
    print "Usage: ~ <in1.csv> ... <inN.csv> <catFldName> <statFldName> <out.csv>\n\n";
    print "e.g.   ~ result/cre.part.h2az.r*.csv1 DIST ENRICH_PART result/cre.part.h2az.r0_9.csv\n\n";
    exit(1);
}

use Flat;
use math;

my($out) = pop @ARGV;
my $statFldName = pop @ARGV;
my $catFldName = pop @ARGV;

my %catVal2fldVals;

foreach $inFile (@ARGV) {
    my $in = Flat->new1($inFile);
    my $statFld = $in->getFieldIndex($statFldName);
    my $catFld = $in->getFieldIndex($catFldName);

    while($row = $in->readNextRow()) {
	push @{$catVal2fldVals{$row->[$catFld]}}, $row->[$statFld];
    }
}

open OUT, "+>$out" or die $!;

print OUT join("\t", "$catFldName", "MEAN_".$statFldName, "STDEV_".$statFldName, "95%CI"), "\n";

my $sortOpt = "\$a <=> \$b";

map { if(math::util::isNaN($_)) { $sortOpt = "\$a cmp \$b"; } } keys %catVal2fldVals;

foreach $cat (sort { eval($sortOpt) }  keys %catVal2fldVals) {
    my(@fldVals) = @{$catVal2fldVals{$cat}};

    my($mean) = math::util::getMean(@fldVals);
    my($stdev) = math::util::getStandardDeviation(@fldVals);
    my($ci) = 1.96 * $stdev / sqrt(scalar(@fldVals));

    print OUT join("\t", $cat, $mean, $stdev, $ci), "\n";
}

close OUT;
    
