#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Convert wig to csv. The start position is converted by -1.\nPlease check the data to verify this modification.\n\n";
    print "Usage: ~ <in.wig> <out.csv>\n";
    exit(1);
}

use Util;

my($in) = shift @ARGV;
my($out) = shift @ARGV;

open IN, "<$in" or die $!;
open OUT, "+>$out" or die $!;

print OUT "CHR\tSTART\tEND\tVALUE\n";

my($chr, $span);

while($line = <IN>) {
    chomp($line);
    
    if($line =~ /variableStep chrom=(chr.+?) span=(.+)/) {
	$chr = $1;
	$span = $2;
    }
    elsif($line =~ /^(\d+)\s+(.+)$/) {
	my $start = $1 - 1; # to make it exclusive for ucsc
	my $val = $2;
	
	my $end = $start + $span;

	print OUT join("\t", $chr, $start, $end, $val), "\n";
    }
    # else assuming leading "track" parameters, ignore
}

close IN;
close OUT;
