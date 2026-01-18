#!/usr/bin/perl -w


if((@ARGV) != 3 || ($ARGV[0] ne 'p' && $ARGV[0] ne 's')) {
    print "\nUsage: ~ <p/s> <datamatrix.csv> <output.txt>\n\n";
    print "Where the first line in <datamatrix.csv> contains the field names\n";
    print "      the other lines contains the data\n\n";
    print "      p -- pearson\n";
    print "      s -- spearman\n";
    exit(1);
}

use math;
use Flat;

my($type) = $ARGV[0];
my($in) = Flat->new($ARGV[1], 1);
my($out) = $ARGV[2];

my %flds2comp;
my @fnames = $in->getFieldNames();

for(my($i) = 0; $i < scalar(@fnames); $i++) {
    if($in->fieldIsNumeric($i)) {
	$flds2comp{$fnames[$i]} = $i;	
    }
}

my @fnames2comp = keys %flds2comp;
my @findice2comp = values %flds2comp;

open OUT, "+>$out" || die $!;

print OUT join("\t", "COVAR", @fnames2comp), "\n"; 

my(@ndata);

$in->reset();

while($row = $in->readNextRow()) {
    push @ndata, [map { $row->[$_]; } @findice2comp];
}

my(@ccoef);

if($type eq 'p') { # pearson
    @ccoef = math::util::getPearsonCoefMatrix(@ndata);
}
elsif($type eq 's') { # else spearman
    @ccoef = math::util::getSpearmanCoefMatrix(@ndata);
}
else {
    die "Unknown coef type: $type\n";
}

for(my($i) = 0; $i < scalar(@fnames2comp); $i++) {
    print OUT $fnames2comp[$i];

    for(my($j) = 0; $j < scalar(@fnames2comp); $j++) {
	printf OUT "\t%3.2f", $ccoef[$i]->[$j];
    }

    print OUT "\n";
}

close OUT;
