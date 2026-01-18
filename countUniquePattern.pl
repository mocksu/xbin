#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <in.txt> <REPattern>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $re = shift @ARGV;

open IN, "<$inFile" or die $!;
my %w2c;

while($line = <IN>) {
    chomp($line);
    my(@words) = split(/\s+/, $line);

    map { if($_ =~ /($re)/) { $w2c{$1}++}; } @words;
}

my @w = keys %w2c;

print "Total ", scalar(@w), " matched $re:\n";
print join(", ", @w), "\n";


