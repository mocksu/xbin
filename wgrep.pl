#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

my(%options);
getopts("l:i", \%options);
my $num = -1;

if(exists $options{"l"}) {
    $num = $options{"l"};
}

my $sens = 1;

if(exists $options{"i"}) {
    $sens = 0;
}

if(scalar(@ARGV) < 2) {
    print "Like grep, but just print out the matched word instead line\n";
    print "Usage: ~ [-l lines2check] [-i] <re> <in1.txt> ... <inN.txt>\n";
    print "       -i\tcase insensitive. Default is sensitive\n";
    exit(1);
}

my $re = shift @ARGV;

while($in = shift @ARGV) {
    print "processing file $in\n";

    open IN, "<$in" or die "Cannot open $in\n";

    my $lc = 0;

    while($line = <IN>) {
	if($num!=-1 && ++$lc > $num) {
	    last;
	}

	chomp($line);
	
	my(@words) = split(/\s+/, $line);
	
	foreach $w (@words) {
	    my $match = 0;
	    
	    if($sens) {
		if($w =~ /$re/) {
		    $match = 1;
		}
	    }
	    else { # insensitive
		if($w =~ /$re/i) {
		    $match = 1;
		}
	    }
	    
	    if($match) {
		print "$w\n";
	    }
	}
    }

    close IN;
}
