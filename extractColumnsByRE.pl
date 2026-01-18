#!/usr/bin/perl -w

if((@ARGV) != 2 && (@ARGV) != 3) {
    print "\nUsage: ~ <input_file> <RE_of_Fields> [<out.csv>]\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my($in) = Flat->new1(shift @ARGV);
my($fldRE) = shift @ARGV;
my($out);

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in->getFileName();
}

my(@selectedFlds);
map { if($_ =~ /$fldRE/) { push @selectedFlds, $_; } } $in->getFieldNames();

my(@indice) = $in->getFieldIndice([@selectedFlds]);

Util::run("extractColumns.pl ".$in->getFileName()." '".join("|", @indice)."' $out", 1);
