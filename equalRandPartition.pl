#!/usr/bin/perl -w

sub printUsage {
    print "Allocate rows into output files row by row\n";
    print "Usage: ~ [-h y|n] [-a] <in.csv> <num_of_files> <out_stem>\n";
    print "       -h whether the input file has header or not\n";
    print "       -a\tto append results to existing results (if any)\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("h:a", \%options);
my $APPEND = exists $options{"a"};
my $header = "U"; # unspecified

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
elsif($header eq "y") {
    $in = Flat->new(shift @ARGV, 1);
}
elsif($options{"h"} eq "n") {
    $in = Flat->new(shift @ARGV, 0);
}
else {
    print "-h should be followed by either 'y' or 'n'\n";
    printUsage();
}

my($num) = $in->getFieldIndex(shift @ARGV);

my($outStem) = shift @ARGV;

my(@fieldNames) = $in->getFieldNames();
  
my %fname2fh;

my $nrows = $in->getNumOfRows();
$in->reset();

my @fileIndice = math::util::randomize(map { $_ % $num + 1 } (0..($nrows - 1)));

#die "fileIndice = @fileIndice\n";

while($row = $in->readNextRow()) {
    my $outFileIndex = shift @fileIndice;
#    print "$outFileIndex\n";
#    next;

    my $fh;
    
    if(exists $fname2fh{$outFileIndex}) {
      $fh = $fname2fh{$outFileIndex};
    }
    else { # file does not exist yet
	$fh = "OUT$outFileIndex";
	my @fldNames = @fieldNames;

	if($APPEND) {
	    open $fh, ">>$outStem.$outFileIndex.csv" or die $!;
	}
	else {
	    open $fh, "+>$outStem.$outFileIndex.csv" or die $!;
	}
	
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
