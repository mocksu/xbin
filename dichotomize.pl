#!/usr/bin/perl -w

use Flat;
use Util;

if(scalar(@ARGV) != 3) {
    print "Dichotomize the specified categorical field\n";
    print "Usage: ~ <in.csv> <catFld> <out.csv>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my($in) = Flat->new($inFile, 1);
my $fld = $in->getFieldIndex(shift @ARGV);
my($out) = shift @ARGV;

my(@fnames) = $in->getFieldNames();

my @fldVals = $in->getUniqueValues($fld);

my $opFile = "$inFile";

# skip the last field value
pop @fldVals;

foreach $fv (@fldVals) {
    `opColumns.pl $opFile 'if(\$arr[0] eq "$fv") { 1; } else { 0; }' $fld $fv $out.tmp`;

    $opFile = "$out.tmp";
}

Util::run("rmColumns.pl $out.tmp $fld", 1);
Util::run("mv $out.tmp $out", 1);
