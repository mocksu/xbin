#!/usr/bin/perl -w

sub printUsage {
    print "Usage: ~ -o <out.csv> <in1.csv> ... <inN.csv> 'fld1|...|fldM'\n";
    exit(1);
}

use Util;
use Flat;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("o:", \%options);
my $out;

if(exists $options{"o"}) {
    $out = $options{"o"};
}
else {
    printUsage();
}

if(scalar(@ARGV) < 2) {
    printUsage();
}

my $flds = pop @ARGV;
my @files = @ARGV;

my(@fldNames) = split(/\|/, $flds);
my $file1 = Flat->new1($files[0]);

map { if($file1->getFieldIndex($_) == -1) { die "Field $_ does not exist for $files[0]"; } } @fldNames;

my @tmpFiles;

for(my($i) = 0; $i < scalar(@files); $i++) {
    $tmpFiles[$i] = "$files[$i].statsMultiFiles.tmp";

    Util::run("extractColumns.pl $files[$i] '$flds' $tmpFiles[$i]", 0);
}

Util::run("catRows.pl @tmpFiles > $out.tmp", 0);
Util::run("rm @tmpFiles", 0);

open OUT, "+>$out" or die "cannot open $out\n";

print OUT join("\t", "Field", "Median", "Mean", "Std", "95%C.I.", "SAMPLE_SIZE"), "\n";

my $ot = Flat->new1("$out.tmp");

foreach $f (@fldNames) {
    my(@fldVals) = $ot->getFieldValues($f);
    my $median = math::util::getMedian(@fldVals);
    my $mean = math::util::getMean(@fldVals);
    my $std = math::util::getStandardDeviation(@fldVals);
    my $ci = math::util::getConfidenceInterval(@fldVals);

    print OUT join("\t", $f, $median, $mean, $std, $ci, scalar(@fldVals)), "\n";
}

close OUT;
    

