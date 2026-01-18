#!/usr/bin/perl -w

if((@ARGV) != 2) {
    print "\nUsage: ~ <input_file> <regular_expression_of_(column_name[:rename])s>\n\n";
    exit(1);
}

use Flat;
use Util;

my($inFile) = shift @ARGV;
my($re) = shift @ARGV;

my($in) = Flat->new1($inFile);
my(@fldsInOrder) = @{$in->getFieldIndiceByRE($re)};

print join("\t", $in->getFieldNames(@fldsInOrder)), "\n";

while($row = $in->readNextRow()) {
    print join("\t", map { $row->[$_]} @fldsInOrder), "\n";
}

undef $in;
