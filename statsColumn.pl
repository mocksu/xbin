#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <min|max|median|mean|sum|ci|basic|full> <fldNum>\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $inFile = shift @ARGV;
my($in) = Flat->new1($inFile);
my($stats) = shift @ARGV;
my($fldNo) = $in->getFieldIndex(shift @ARGV);
my $fldName = "No field name";

if($stats eq "basic") {
    Util::run("statsColumn.pl $inFile mean $fldNo", 0);
      Util::run("statsColumn.pl $inFile ci $fldNo", 0);      
      exit(0);
  }
elsif($stats eq "full") {
    Util::run("statsColumn.pl $inFile min $fldNo", 0);
      Util::run("statsColumn.pl $inFile max $fldNo", 0);
      Util::run("statsColumn.pl $inFile mean $fldNo", 0);
      Util::run("statsColumn.pl $inFile median $fldNo", 0);
      Util::run("statsColumn.pl $inFile ci $fldNo", 0);
      
      exit(0);
  }
elsif($stats =~ /\|/) {
    my @ss = split(/\|/, $stats);

    foreach $s (@ss) {
	Util::run("statsColumn.pl $inFile $s $fldNo", 0);
      }
    exit(0);
}
# else, continue

if($in->hasHeader()) {
    $fldName = $in->getFieldName($fldNo);
}

my(@fldVals) = $in->getFieldData($fldNo);

my $num = 0;
map { if(math::util::isNumeric($_)) { $num++; } } @fldVals;

my($val);

if($stats eq 'min') {
    $val = math::util::getMin(@fldVals);
}
elsif($stats eq 'max') {
    $val = math::util::getMax(@fldVals);
}
elsif($stats eq 'median') {
    $val = math::util::getMedian(@fldVals);
}
elsif($stats eq 'mean') {
    $val = math::util::getMean(@fldVals);
}
elsif($stats eq 'sum') {
    $val = math::util::getSum(@fldVals);
}
elsif($stats eq 'ci') {
    $val = math::util::getConfidenceInterval(@fldVals);
}
else {
    die "statsColumn.pl: statistics not implemented: $stats\n";
}

print "$stats for Field $fldNo (", $fldName, ") with $num entries is $val\n";
