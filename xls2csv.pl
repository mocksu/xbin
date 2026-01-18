#!/usr/bin/perl -w

use Flat;
use Util;
use ExcelUtil;

if(scalar(@ARGV) != 2) {
  print "Convert the input xls file to the output csv using 'xls2csv'\n";
  print "Usage: ~ <in.xls> <out.csv>\n";
  exit(1);
}

my $in = shift @ARGV;
my $out = shift @ARGV;

ExcelUtil::xls2csv($in, $out);
