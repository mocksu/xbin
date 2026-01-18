#!/usr/bin/perl

if(scalar(@ARGV) != 3) {
    die "Usage: ~ <in.csv> <out.csv> <step>\n";
}

open IN, "<$ARGV[0]" || die $!;

# get number of columns
my $line = <IN>;
chomp($line);
my(@data) = split(/\t/, $line);
my $numOfCols = scalar(@data);
close IN;

open OUT, "+>$ARGV[1]" || die $!;

my $STEP = $ARGV[2];

for(my($i) = 0; $i < $numOfCols; $i += $STEP) {
    print "processing column $i of $numOfCols\n";

    open IN, "<$ARGV[0]" || die $!;

    my(@colData);

    while($line = <IN>) {
	chomp($line);
	my(@rdata) = split(/\t/, $line);

	my(@toUse) = splice(@rdata, $i, $STEP);

	push @colData, \@toUse;
    }

    close IN;

    for(my($j) = 0; $j < scalar(@{$colData[0]}); $j++) {
	print OUT $colData[0]->[$j];

	for(my($k) = 1; $k < scalar(@colData); $k++) {
	    print OUT "\t$colData[$k]->[$j]";
	}
	
	print OUT "\n";
    }
}

close OUT;
