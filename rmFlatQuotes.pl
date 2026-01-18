#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Remove double quotes from the input file, assuming text within paired double quotes is one field\n";
    print "Usage: ~ <in.csv> <out.csv>\n";
    exit(1);
}

my $in = shift @ARGV;
my $out = shift @ARGV;

open IN, "<$in" or die "Cannot open $in\n";
open OUT, "+>$out" or die "Cannot open $out\n";

while($line = <IN>) {
    chomp($line);

    my(@segs) = split(/\"/, $line);

    if(scalar(@segs) % 2 != 1) {
	die "unpaired quotes at line:\n$line\n";
    }

    my(@newSegs);

    $newSegs[0] = $segs[0];

    for(my($i) = 1; $i < scalar(@segs) - 1; $i += 2) {
	$newSegs[$i] = $segs[$i]; # text inside paired quotes
	$newSegs[$i] =~ s/\t+/ /g; # replace tab with space

	$newSegs[$i + 1] = $segs[$i + 1]; # text outside of paired quotes
    }
    
    print OUT join("", @newSegs), "\n";
}

close IN;
close OUT;
