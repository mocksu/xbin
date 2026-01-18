#!/usr/bin/perl -w
sub printUsage() {
    print "Count how many unique values of the specified field in each of the specified category field.\n";
    print "e.g. count unique number of snp ids in each of the 5' UTR, Intron in each file ...\n\n";
    print "Usage: ~ <in1.csv> <uniqueFld1> <label1> <catFld1> ... <inN.csv> <uniqueFldNum> <labelN> <catFldN> <out.csv>\n";
    exit(1);
}

if(scalar(@ARGV) < 5) {
    printUsage();
}

use Flat;
use math;
use Util;

my $out = pop @ARGV;

if(scalar(@ARGV) % 4 != 0) {
    printUsage();
}

open OUT, "+>$out" or die $!;

my(@stemFiles, @flds, @labels, @catFlds, @inFiles);

my %catLabel2count;
my %cats;
my %labels;

while(scalar(@ARGV) > 0) {
    my $in = Flat->new1(shift @ARGV);
    my $fld = shift @ARGV;
    my $label = shift @ARGV;
    my $catFld = $in->getFieldIndex(shift @ARGV);
    $labels{$label} = 1;

    my($fname) = $in->getFileName();
    my ($d, $stem, $s) = Util::getDirStemSuffix($fname);
    undef $in;

    # partition the file by the catfield
    Util::run("rm -rf /tmp/$stem.$s*", 1);
    Util::run("partition.pl $fname $catFld /tmp/$stem.$s", 1);
    my @catFiles = Util::getFilePaths("/tmp/$stem.$s*", 1);

    foreach $cf (@catFiles) {
	my $cff = Flat->new1($cf);
	my @catFldVals = $cff->getUniqueValues($catFld);
	my $cat = shift @catFldVals;
	$catLabel2count{$cat}{$label} = $cff->getUniqueValueCount($fld);
#	print "catFld = $catFld, cat = $cat, label = $label, count = $catLabel2count{$cat}{$label}\n";
	$cats{$cat} = 1;
    }

    Util::run("rm -rf @catFiles", 1);
}

my @catVals = sort keys %cats;
my @labVals = sort keys %labels;

print OUT join("\t", "CATEGORY", @labVals), "\n";

foreach $cat (@catVals) {
    print OUT $cat;

    foreach $lab (@labVals) {
	my $c = 0;

	if(exists $catLabel2count{$cat}{$lab}) {
	    $c = $catLabel2count{$cat}{$lab};
	}

	print OUT "\t$c";
    }

    print OUT "\n";
}

close OUT;
