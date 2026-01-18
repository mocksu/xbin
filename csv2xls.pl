#!/usr/bin/perl -w

use Flat;
use Util;
use ExcelUtil;

if(scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> <out.xls>\n";
    exit(1);
}

ExcelUtil::csv2xls(@ARGV);
