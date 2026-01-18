#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "Usage: ~ <in.csv> <fldNo> <newFldName> <bound1> ... <boundN> <out.csv>\n\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new(shift @ARGV, 1);
my $fldNo = $in->getFieldIndex(shift @ARGV);
my $newFldName = shift @ARGV;
my($out) = pop @ARGV;
my(@boundaries) = sort { $a <=> $b } @ARGV;

open OUT, "+>$out" or die $!;

my(@fnames) = $in->getFieldNames();
print OUT join("\t", @fnames, $newFldName), "\n";

while($row = $in->readNextRow()) {
    my $fldVal = $row->[$fldNo];

    if(math::util::isNaN($fldVal)) {
	next;
    }

    my $newFldVal;

    if($fldVal < $boundaries[0]) {
	$newFldVal = $boundaries[0];
    }
    else {
	my $found = 0;

	for(my($i) = 0; $i < scalar(@boundaries) - 1; $i++) {
	    if($fldVal >= $boundaries[$i] && $fldVal < $boundaries[$i + 1]) {
		$found = 1;
		$newFldVal = $boundaries[$i + 1];
		last;
	    }
	    # else check the next $i
	}

	if(!$found) {
	    $newFldVal = $boundaries[scalar(@boundaries) - 1];
	}
    }

    print OUT join("\t", @{$row}, $newFldVal), "\n";
		
}

close;
