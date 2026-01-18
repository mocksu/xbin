#!/usr/bin/perl -w

if(scalar(@ARGV) != 5) {
  print "Select rows with values specified in the <selectFile> with the <selectColumn>\n";
    print "\nUsage: ~ <input_file> <column2select> <selectFile> <selectColumn> <outputFile>\n\n";
    exit(1);
}

use Flat;
use Util;

my $cmdLine = Util::getCmdLine();

# read data from the file
my($in) = shift @ARGV;
my($inFlat) = Flat->new1($in);
my $fld2sel = $inFlat->getFieldIndex(shift @ARGV);
my $sFlat = Flat->new1(shift @ARGV);
my $sFld = $sFlat->getFieldIndex(shift @ARGV);
my $out = shift @ARGV;

open OUT, "+>$out.tmp" or die $!;

my(%rowVal2keep) = ();

while($row = $sFlat->readNextRow()) {
  $rowVal2keep{$row->[$sFld]} = 1;
}

$sFlat->destroy();

while($row = $inFlat->readNextRow()) {
  if(exists $rowVal2keep{$row->[$fld2sel]}) {
    print OUT join("\t", @{$row}), "\n";
  }
  # else skip
}

close OUT;

Util::run("mv $out.tmp $out", 1);
