#!/usr/bin/perl -w

if(scalar(@ARGV) != 5) {
    print "Usage: ~ <in.csv> <fldToBeSorted> <Reference.csv> <reference_fld> <out.csv>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1(shift @ARGV);
my $fld = $in->getFieldIndex(shift @ARGV);
my $ref = Flat->new1(shift @ARGV);
my $refFld = $ref->getFieldIndex(shift @ARGV);
my($out) = shift @ARGV;

### map fld => index
my %fval2indice = $in->getIndiceOfFieldValues($fld);
my @data = $in->getDataArray();

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

if($in->hasHeader()) {
    print OUT join("\t", $in->getFieldNames()), "\n";
}

$in->destroy();

while($row = $ref->readNextRow()) {
    if(exists $fval2indice{$row->[$refFld]}) {
	print OUT join("\t", @{$data[shift @{$fval2indice{$row->[$refFld]}}]}), "\n";
    }
}

close OUT;

`mv $out.tmp $out`;
