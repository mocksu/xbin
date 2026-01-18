#!/usr/bin/perl -w

if(scalar(@ARGV) != 6) {
    print "Usage: ~ <samplesToBeExcluded.csv> <sampleIDFld> <phenoFld> <samplesToExlude.csv> <sampleIDFld> <out.csv>\n";
    exit(1);
}

use Flat;

my $orig = Flat->new1(shift @ARGV);
my $osid = $orig->getFieldIndex(shift @ARGV);
my $opheno = $orig->getFieldIndex(shift @ARGV);
my $ex = Flat->new1(shift @ARGV);
my $esid = $ex->getFieldIndex(shift @ARGV);
my $out = shift @ARGV;

my %sampleIsToExclude; map { $sampleIsToExclude{$_} = 1; } $ex->getUniqueValues($esid);

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

print OUT join("\t", $orig->getFieldNames()), "\n";

my $sid;
my $dup = 0;

while($row = $orig->readNextRow()) {
    $sid = $row->[$osid];

    if(exists $sampleIsToExclude{$sid}) {
	$dup++;
	$row->[$opheno] = "NA";
    }

    print OUT join("\t", @{$row}), "\n";
}

close OUT;

`mv $out.tmp $out`;

print "$dup duplicates excluded\n";
