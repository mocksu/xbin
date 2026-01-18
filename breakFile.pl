#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <maxLinesPerFile> <outStem>\n";
    exit(1);
}

my $in = shift @ARGV;
my $max = shift @ARGV;
my $outStem = shift @ARGV;

my $c = 0;
my $fno;

open IN, "<$in" or die "Cannot open $in\n";

my $out1;

while($line = <IN>) {
    if($c++ % $max == 0) {
	$fno = int($c / $max);
	print "Processing chunk $fno\n";

	if($fno != 0) {
	    close $out1;
	}

	$out1 = "OUT$fno";
	
	open $out1, "+>$outStem.$fno" or die "Cannot open $outStem.$fno\n";
    }
    # else file already exist

    print $out1 $line;
}

close IN;
close $out1;
