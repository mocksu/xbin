#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <in.txt> <out.csv>\n";
    exit(1);
}

open IN, "<$ARGV[0]" || die $!;
open OUT, "+>$ARGV[1].tmp" || die $!;

while($line = <IN>) {
    chomp($line);

    $line =~ s/,\s*/\t/g;

    print OUT "$line\n";
}

close IN;
close OUT;

`mv $ARGV[1].tmp $ARGV[1]`;
