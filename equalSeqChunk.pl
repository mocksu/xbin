#!/usr/bin/perl -w

sub printUsage {
    print "Allocate equal sized un-broken chunks into output files\n";
    print "Usage: ~ [-s] [-h y|n] [-r total_num_of_rows] <in1.csv> <num_of_files> <out_stem>\n";
    print "       -s\tSkip checking row data format. Default is no.\n\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("sh:r:", \%options);
my $APPEND = exists $options{"a"};
my $header = "U"; # unspecified
my $skip = exists $options{"s"};

if(exists $options{"h"}) {
    $header = $options{"h"};
}

if(scalar(@ARGV) != 3) {
    printUsage();
}

use Util;
use Flat;
use math;
use Fcntl ':flock';

my $in;
if($header eq "U") {
    $in = Flat->new1(shift @ARGV);
}
if($header eq "y") {
    $in = Flat->new(shift @ARGV, 1);
}
elsif($options{"h"} eq "n") {
    $in = Flat->new(shift @ARGV, 0);
}
else {
    print "-h should be followed by either 'y' or 'n'\n";
    printUsage();
}

my $numRows;

if(exists $options{"r"}) {
    $numRows = $options{"r"};
}
else {
    $numRows = $in->getNumOfRows();
    $in->reset();
}

my($num) = $in->getFieldIndex(shift @ARGV);
my $chunkSize;

if($numRows % $num == 0) {
    $chunkSize = $numRows / $num;
}
else {
    $chunkSize = int($numRows / $num) + 1;
}

print "numRows = $numRows, num = $num, chunkSize = $chunkSize\n";

my($outStem) = shift @ARGV;

my(@fieldNames) = $in->getFieldNames();
  
my %fname2fh;

my $outFileIndex = 0;

while($row = $in->readNextRow($skip)) {
    if($in->getRowIndex() % $chunkSize == 1) {
	$outFileIndex ++;
	print "outFileIndex = $outFileIndex\n";
    }

#    next;

    my $fh;
    
    if(exists $fname2fh{$outFileIndex}) {
      $fh = $fname2fh{$outFileIndex};
    }
    else { # file does not exist yet
	$fh = "OUT$outFileIndex";
	my @fldNames = @fieldNames;

	open $fh, "+>$outStem.$outFileIndex.csv" or die $!;
	
#disable lock for now:      flock($fh, LOCK_EX);
	
	if($in->hasHeader()) {
	    print $fh Flat::dataRowToString(@fldNames), "\n";
	}
      
	$fname2fh{$outFileIndex} = $fh;
    }
    
    print $fh join("\t", @{$row}), "\n";
}

  # unlock the output files
#  foreach $fh (values %val2outfile) {
# disable lock for now:      flock($fh, LOCK_UN);
#  }

#  Util::run("gzip $fname", 1);

# close files
foreach $fh (values %fname2fh) {
    close $fh;
}

print "DONE partition.pl at ", `date`;
