#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("u:U:l:L:", \%options);

if((!(exists $options{"l"}) &&
    !(exists $options{"L"})) ||
   (!(exists $options{"u"}) &&
    !(exists $options{"U"}))) {
    printUsage();
}

my $iu;; # inclusive upperbound
my $il; # inclusive lowerbound
my $upper; # upperbound
my $lower; # lowerbound

if(exists $options{"u"}) {
    $iu = 0;
    $upper = $options{"u"};
}
else {
    $iu = 1;
    $upper = $options{"U"};
}

if(exists $options{"l"}) {
    $il = 0;
    $lower = $options{"l"};
}
else {
    $il = 1;
    $lower = $options{"L"};
}

sub printUsage {
    print "Usage: ~ -(l|L)lowerBound -(u|U)upperBound] <in.csv> <field_#> <out.csv>\n";
    print "\tfield_# 0 based field number. \n";
    print "\tu exclusive upperbound\n";
    print "\tU inclusive upperbound\n";
    print "\tl exlcusive lowerbound\n";
    print "\tL inclusive lowerbound\n";
    print "e.g. ~ -U 0.1 -l 0 /tmp/t1.csv 0 /tmp/t2.csv\n";
    exit(1);
}

if(scalar(@ARGV) != 3) {
    printUsage();
}

use Flat;

my($infile) = Flat->new1(shift @ARGV);
my($fno) = $infile->getFieldIndex(shift @ARGV);
my $out = shift @ARGV;
open OUT, "+>$out" or die $!;

if($infile->hasHeader()) {
    my(@fieldNames) = $infile->getFieldNames();
    print OUT join("\t", @fieldNames), "\n";
}

while($row = $infile->readNextRow()) {
    my $inRange = 0;
    my $fval = $row->[$fno];

    if($iu) { # inclusive upper
	if($il) {
	    if($fval >= $lower && $fval <= $upper) {
		$inRange = 1;
	    }
	    # else out of range
	}
	else { # exclusive lowerbound
	    if($fval > $lower && $fval <= $upper) {
		$inRange = 1;
	    }
	    # else out of range
	}
    }
    else { # exclusive upper
	if($il) {
	    if($fval >= $lower && $fval < $upper) {
		$inRange = 1;
	    }
	    # else out of range
	}
	else { # exclusive lowerbound
	    if($fval > $lower && $fval < $upper) {
		$inRange = 1;
	    }
	    # else out of range
	}
    }

    if($inRange) {
	print OUT join("\t", @{$row}), "\n";
    }
}

close OUT;
