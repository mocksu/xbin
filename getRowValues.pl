#!/usr/bin/perl -w

sub printUsage {
    print "Usage: ~ <input.csv> <fld_1 fldVal_1> ... [<fld_N fldVal_N>] [fld_to_be_displayed]\n";
    exit(1);
}

if(scalar(@ARGV) < 3) {
    printUsage();
}

use Flat;
use math;

my($in) = Flat->new1(shift @ARGV);
my $dispFld = $in->getFieldIndex(pop @ARGV);

if(scalar(@ARGV) % 2 != 0) {
    printUsage();
}

my(@flds, %fld2val);

while(scalar(@ARGV) != 0) {
    my $fld = $in->getFieldIndex(shift @ARGV);
    my $fval = shift @ARGV;

    push @flds, $fld;
    $fld2val{$fld} = $fval;
}
    
while($row = $in->readNextRow()) {
    my $match = 1;

    foreach $fld (@flds) {
	if($row->[$fld] ne $fld2val{$fld}) {
	    $match = 0;
	    last;
	}
    }

    if($match) {
	print $row->[$dispFld], "\n";
    }
}



