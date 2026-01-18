#!/usr/bin/perl -w

if(scalar(@ARGV) < 4) {
    print "Convert the specified flat file into html table\n\n";
    print "Usage: ~ <flat.csv> <output.svm> <label_field> <field1> <field2> ... <fieldn>\n";
    print "e.g. ~ myfile.csv myfile.svm 0 1 4 5\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
open OUT, "+>$ARGV[1]" || die $!;
my($label) = $ARGV[2];

my(@flds);
my(%sym2num);

for(my($i) = 3; $i < scalar(@ARGV); $i++) {
    if($ARGV[$i] =~ /\-/) {
	my($s, $e) = split(/\-/, $ARGV[$i]);

	for(my($j) = $s; $j <= $e; $j++) {
	    push @flds, $j;
	}
    }
    else {
	push @flds, $ARGV[$i];
    }
}

my(@data) = $in->getDataArray();

foreach $d (@data) {
    print OUT getFieldVal($label, $d->[$label]);

    for(my($i) = 0; $i < scalar(@flds); $i++) {
	print OUT "\t$flds[$i]:", getFieldVal($flds[$i], $d->[$flds[$i]]);
    }

    print OUT "\n";
}

close OUT;

sub getFieldVal {
    my($fldIndex, $val) = @_;

    if($in->fieldIsNumeric($fldIndex)) {
	return $val;
    }
    else { # non numeric field
	if(!(exists $sym2num{$fldIndex})) {
	    $sym2num{$fldIndex}{$val} = 0;
	}
	elsif(!(exists $sym2num{$fldIndex}{$val})) {
	    $sym2num{$fldIndex}{$val} = scalar(keys %{$sym2num{$fldIndex}});
	}
	# else mapping exists
	
	return $sym2num{$fldIndex}{$val};
    }
}
    
