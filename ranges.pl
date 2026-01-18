#!/usr/bin/perl -w

sub printUsage {
    print "Usage: ~ -(L|U) <in.csv> <field_#> <threshold1> ... <thresholdN> <outStem>\n";
    print "\tfield_# 0 based field number. \n";
    print "\tL lowerbound inclusive\n";
    print "\tU upperbound inclusive\n";
    print "e.g. ~ -U /tmp/t1.csv -100 0 100 /tmp/t\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("LU", \%options);

if(!(exists $options{"L"}) &&
   !(exists $options{"U"})) {
    printUsage();
}

my $iu;; # inclusive upperbound

if(exists $options{"U"}) {
    $iu = 1;
}
else {
    $iu = 0;
}

if(scalar(@ARGV) < 4) {
    printUsage();
}

use Flat;
use Util;

my $in = Flat->new1(shift @ARGV);
my $inFile = $in->getFileName();
my @fldNames = $in->getFieldNames();
my $fldNum = $in->getFieldIndex(shift @ARGV);
my $outStem = pop @ARGV;
my @bounds = sort { $a <=> $b} @ARGV;
my $bsize = scalar(@bounds);

my $firstFile = "$outStem.below$bounds[0].csv";
open F, "+>$firstFile" or die $!;
print F join("\t", @fldNames), "\n";
my $lastFile = "$outStem.above".$bounds[$bsize -1 ].".csv";
open L, "+>$lastFile" or die $!;
print L join("\t", @fldNames), "\n";

my(%partFiles, %outFile);

for(my($i) = 0; $i < $bsize - 1; $i++) {
    my $pfile = "$outStem.$bounds[$i]"."_".$bounds[$i+1].".csv";
    $partFiles{$bounds[$i]}{$bounds[$i+1]} = $pfile;
    my $fh = "OUT$i";
    open $fh, "+>$pfile" or die $!;
    print $fh join("\t", @fldNames), "\n";
    $outFile{$bounds[$i]}{$bounds[$i+1]} = $fh;
}

while($row = $in->readNextRow()) {
    my $fval = $row->[$fldNum];
    
    if(($fval < $bounds[0]) ||
       ($iu && $fval == $bounds[0])) {
	print F join("\t", @{$row}), "\n";
    }
    elsif(($fval > $bounds[$bsize - 1]) ||
	  (!$iu && $fval == $bounds[$bsize - 1])) {
	print L join("\t", @{$row}), "\n";
    }
    else {
	my $found = 0;

	for(my($i) = 0; $i < $bsize - 1; $i++) {
	    if(($fval > $bounds[$i] && $fval < $bounds[$i + 1]) ||
	       ($iu && $fval > $bounds[$i] && $fval == $bounds[$i + 1]) ||
	       (!$iu && $fval == $bounds[$i] && $bounds[$i] && $fval < $bounds[$i + 1])) {
		my $fh = $outFile{$bounds[$i]}{$bounds[$i+1]};
		print $fh join("\t", @{$row}), "\n";
		$found = 1;
		last;
	    }
	}
	
	if(!$found) {
	    die "cannot find boundaries for $fval at row: ", join("\t", @{$row}), "\n";
	}
    }
}

close F;
close L;

for(my($i) = 0; $i < $bsize - 1; $i++) {
    my $fh = "OUT$i";

    close $fh;
}
	    
    
    
