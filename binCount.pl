#!/usr/bin/perl -w

if(scalar(@ARGV) != 5) {
    print "Count the specified field based on the specified threshold for a data with the specified binned field\n";
    print "Usage: ~ <in.csv> <bin_field> <count_fld> <count_fld_threshold> <out.csv>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $bfldName = shift @ARGV;
my $cfldName = shift @ARGV;
my $cthold = shift @ARGV;
my $outFile = shift @ARGV;

use Util;
use Flat;
use math;

# discretize the specified field
#my($binTmp) = "/tmp/binCountTmp.csv";

#Util::run("discretize.pl $inFile $bfldName $numBins $binTmp", 1);

# read the tmp file and do the thresholding
my $tmp = Flat->new1($inFile);
my @data = $tmp->getDataArray();
my $bfldIndex = $tmp->getFieldIndex($bfldName);
my $cfldIndex = $tmp->getFieldIndex($cfldName);

my %count;

for(my($i) = 0; $i < scalar(@data); $i++) {
    my $cval = $data[$i][$cfldIndex];

    if(math::util::isNumeric($cval)) {
	if($cval >= $cthold) {
	    $count{$data[$i][$bfldIndex]}{"1"}++;
	}
	else {
	    $count{$data[$i][$bfldIndex]}{"0"}++;
	}
    }
    else {
	$count{$data[$i][$bfldIndex]}{"NA"}++;
    }
}

open OUT, "+>$outFile" or die "Cannot open $outFile\n";

print OUT "$bfldName\t$cfldName>=$cthold\t$cfldName<$cthold\t$cfldName.NA\n";

foreach $bval (sort { $a <=> $b } keys %count) {
    my $c1 = 0, $c0 = 0, $cNA = 0;

    if(exists $count{$bval}{"1"}) {
	$c1 = $count{$bval}{"1"};
    }

     if(exists $count{$bval}{"0"}) {
	$c0 = $count{$bval}{"0"};
    }

    if(exists $count{$bval}{"NA"}) {
	$cNA = $count{$bval}{"NA"};
    }

    print OUT "$bval\t$c1\t$c0\t$cNA\n";
}

close OUT;
