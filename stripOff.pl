#!/usr/bin/perl -w

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> [out.sh]\n";
    exit(1);
}

my $in = shift @ARGV;

my $out = $in;

if(scalar(@ARGV) > 0) {
    $out = shift @ARGV;
}

open IN, "<$in" or die $!;

open OUT, "+>$out.tmp" or die $!;

while($line = <IN>) {
    chomp($line);

    my($cmd, $date) = ($line =~ /(.+?)\(.+?\)/);

    print OUT "$cmd\n";
}

close IN;
close OUT;

`mv $out.tmp $out`;
`chmod +x $out`;
