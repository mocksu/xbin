#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("c:", \%options);

if(scalar(@ARGV) != 2) {
    print "Usage: ~ [-c <numOfColumns>] <in.csv> <out.csv>\n";
    print "       -c: number of columns to read per time. Memory efficient, but slow\n"; 
    exit(1);
}



my($in) = Flat->new(shift @ARGV, 0);
my($out) = shift @ARGV;
open OUT, "+>$out.tmp" || die $!;
    
if(exists $options{"c"}) { # memory efficient 
    my $ncol = $options{"c"};

    my $num = $in->getNumOfColumns();
    my $iter = int($num / $ncol) + 1;
    print "num = $num, ncol = $ncol, total $iter iterations\n";

    for(my($i) = 0; $i < $iter; $i++) {
	print "iteration $i ", `date`;

	$in->reset();
	
	my @rdata = ();
	my $start = $i * $ncol;
	my $end = math::util::getMin(($i+1)*$ncol, $num);

	while($row = $in->readNextRow()) {
	    for(my($j) = $start; $j < $end; $j++) {
		$rdata[$j - $start][$in->getRowIndex() - 1] = $row->[$j];
	    }
	}
	
	for(my($j) = 0; $j < scalar(@rdata); $j++) {
	    print OUT join("\t", @{$rdata[$j]}), "\n";
	}
    }
}
else { # fast
    my(@data) = $in->getDataArray();
    
    for(my($i) = 0; $i < scalar(@{$data[0]}); $i++) {
	print OUT $data[0][$i];

	for(my($j) = 1; $j < scalar(@data); $j++) {
	    print OUT "\t$data[$j][$i]";
	}
	
	print OUT "\n";
    }
    
}

close OUT;

`mv $out.tmp $out`;
