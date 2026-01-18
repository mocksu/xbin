#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "\nUsage: ~ <in.csv> <fld> <operation> <row1> ... <rowN> <newFldName> <out.csv>\n\n";
    print "         e.g. ~ /tmp/t.csv '\"\$arr[1]-\$arr[0]\"'0 1 coord /tmp/t1.csv\n\n";
    print "where '_anything_' will be subsituted by \$anything\n";
    print "The row indice are 0-based and should be from low to high.\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $cmdLine = Util::getCmdLine();

my($in) = shift @ARGV;
my $inFile = Flat->new1($in);
my $fldIndex = $inFile->getFieldIndex(shift @ARGV);
my($op) = shift @ARGV;
my($out) = pop @ARGV;
my($newFldName) = pop @ARGV;

$op =~ s/_(.+?)_/\$$1/g; # allow usage of "_anything_" etc as "$anything"

my(@rows) = @ARGV;
my $minRow = $rows[0];
my $maxRow = $rows[scalar(@rows)-1];

open OUT, "+>$out.tmp" or die $!;
print OUT "# $cmdLine\n";
print OUT join("\t", $inFile->getFieldNames(), $newFldName), "\n";

my($single) = scalar(@rows) > 1? 0:1;

my($operation) = $op;

if($single) {
    $operation =~ s/__/\$arr[0]/g;
}
else { # multiple
    $operation =~ s/__/\@arr/g;
}

my @arr = ();

while((scalar(@arr) < $maxRow) && ($row = $inFile->readNextRow())) {
  push @arr, $row->[$fldIndex];
  print OUT join("\t", @{$row}, 1), "\n";
}

while($row = $inFile->readNextRow()) {
  push @arr, $row->[$fldIndex];
  print OUT join("\t", @{$row}, eval($operation)), "\n";
  shift @arr;
}

close OUT;

`mv $out.tmp $out`;
