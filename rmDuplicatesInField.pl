#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "\nUsage: ~ <in.csv> <fldNum1> ... <fldNum2> <out.csv>\n\n";
    print "\nRemove duplicated values separated by ',' in the specified fields of the specified input file\n";
    exit(1);
}

use Flat;
my($inName) = shift @ARGV;
my($in) = Flat->new1($inName);
my($out) = pop @ARGV;
my(@fldIndice) = $in->getFieldIndice([@ARGV]);

my(@data) = $in->getDataArray();

for(my($i) = 0; $i < scalar(@data); $i++) {
    foreach $fldNum (@fldIndice) {
	$data[$i][$fldNum] = rmDups($data[$i][$fldNum]);
    }
}

$in->writeToFile($out);

sub rmDups {
    my($fval) = @_;

    if(!($fval =~ /,/)) {
	return $fval;
    }

    my(@vals) = split(/,/, $fval);

    my($num) = scalar(@vals);

    if($num == 0) {
	return '';
    }
    elsif($num == 1) {
	return $fval;
    }
    # else rm dups below

    my(%counted);
    my(@uvals);

    for(my($i) = 0; $i < scalar(@vals); $i++) {
	if(exists $counted{$vals[$i]}) { 
	    # skip
	}
	else {
	    push @uvals, $vals[$i];
	    $counted{$vals[$i]} = 1;
	}
    }

    return join(',', @uvals);
}

