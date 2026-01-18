#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "Usage: ~ <input.csv> <out.csv> <fld_no1|fld_name1> .. <fld_non|fld_namen>\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1(shift @ARGV);
my(@data) = $in->getDataArray();

my($out) = shift @ARGV;
open OUT, "+>$out" || die $!;
print OUT Flat::dataRowToString($in->getFieldNames()), "\n";

my(@fldIndice) = $in->getFieldIndice([@ARGV], 1);

my(%uniqueValIndice) = $in->getIndiceOfFieldValues(@fldIndice);

foreach $fldVals (sort keys %uniqueValIndice) {
    my(@indice) = @{$uniqueValIndice{$fldVals}};

    if(scalar(@indice) > 1) {
	for(my($i) = 0; $i < scalar(@indice); $i++) {
	    my(@row) = @{$data[$indice[$i]]};
	    print OUT Flat::dataRowToString(@row), "\n";
	}
    }
}

close OUT;
