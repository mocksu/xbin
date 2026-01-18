#!/usr/bin/perl -w

use Flat;
use Getopt::Std;

my(%options);
getopts("s:n:x:", \%options);

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <numOfTailRows> <out.csv>\n\n";
    exit(1);
}

my($in) = Flat->new(shift @ARGV, 1);
my $num = shift @ARGV;
my($out) = shift @ARGV;

my $inFile = $in->getFileName();
my $totalRows = $in->getNumOfRows();

if($totalRows < $num) {
  warn "The number of tail rows is more than the number of rows in the file. Returning all the rows.\n";
  $num = $totalRows;
}

my(@fnames) = $in->getFieldNames();

open H, "+>$out.head" or die $!;
print H "# the last $num rows of the file '$inFile'\n";
print H join("\t", @fnames), "\n";
close H;

`tail -$num $inFile > $out.tail`;
`cat $out.head $out.tail > $out`;
