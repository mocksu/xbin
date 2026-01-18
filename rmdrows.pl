#!/usr/bin/perl -w

if(scalar(@ARGV) != 2 && scalar(@ARGV) != 1) {
    print "\nUsage: ~ <in.csv> [<out.csv>]\n\n";
    exit(1);
}

# read data from the file
open IN, "<$ARGV[0]" or die "Cannot open $ARGV[1]\n";

my $out;

if(scalar(@ARGV) == 2) {
    $out = $ARGV[1];
}
else {
    $out = "$ARGV[0].tmp";
}

open OUT, "+>$out" or die "Cannot open $out\n";

my(%printed);
my $dupCount = 0;

while($line = <IN>) {
    if(!exists $printed{$line}) {
	print OUT $line;
	$printed{$line} = 1;
    }
    # else printed already, skip
    else {
	$dupCount++;
    }
}

close IN;

close OUT;

if(scalar(@ARGV) == 1) {
    `mv $out $ARGV[0]`;
}

print "$dupCount duplicated rows removed\n";
