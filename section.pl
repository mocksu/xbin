#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Evenly divide the rows into different sections each with the specified max number of rows\n";
    print "Usage: ~ <in.csv> <max_section_size> <out_stem>\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $in = Flat->new1($ARGV[0]);
my($size) = $ARGV[1];
my($stem) = $ARGV[2];

my(@fldNames) = $in->getFieldNames();
my($suffix) = Util::getSuffix($ARGV[0]);
my(%val2outfile);

my($i) = 0;

while($row = $in->readNextRow()) {
    my $fh;
    my $sectionNum = int($i++ / $size);

    if(exists $val2outfile{$sectionNum}) {
	$fh = $val2outfile{$sectionNum};
    }
    else { # file does not exist yet
	$fh = "OUT$sectionNum";
	open $fh, "+>$stem.$sectionNum.$suffix" or die $!;

	if($in->hasHeader()) {
	    print $fh Flat::dataRowToString(@fldNames), "\n";
	}

	$val2outfile{$sectionNum} = $fh;
    }

    print $fh Flat::dataRowToString(@{$row}), "\n";
}

# close files
foreach $fh (values %val2outfile) {
    close $fh;
}
