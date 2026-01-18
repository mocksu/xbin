#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "\nUsage: ~ <in.csv> <operation> <fld1> ... <fldn> <newFldName> <out.csv>\n\n";
    print "         e.g. ~ /tmp/t.csv '\"$arr[0]:$arr[1]\"' 9 10 coord /tmp/t1.csv\n\n";
    print "\twhere '__' will be subsituted by the specified elements\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $cmdLine = Util::getCmdLine();

my($in) = shift @ARGV;
my($out) = pop @ARGV;
my($newFldName) = pop @ARGV;
my($op) = shift @ARGV;
my $inFile = Flat->new1($in);
my $oldCmt = $inFile->getComments();

$op =~ s/_(.+?)_/\$$1/g; # allow usage of "_anything_" etc as "$anything"

my(@flds) = $inFile->getFieldIndice([@ARGV], 1);

my(@data) = $inFile->getDataArray();
open OUT, "+>$out.tmp" or die $!;
print OUT "$oldCmt";
print OUT "# $cmdLine\n";
print OUT Flat::dataRowToString($inFile->getFieldNames(), $newFldName), "\n";

my($single) = scalar(@flds) > 1? 0:1;

my($operation) = $op;

if($single) {
    $operation =~ s/__/\$arr[0]/g;
}
else { # multiple
    $operation =~ s/__/\@arr/g;
}

for(my($i) = 0; $i < scalar(@data); $i++) {
    my(@arr) = map { $data[$i][$_]; } @flds;

    print OUT Flat::dataRowToString(@{$data[$i]}, eval($operation)), "\n";
}

close OUT;

`mv $out.tmp $out`;
