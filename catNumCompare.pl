#!/usr/bin/perl -w
sub printUsage() {
    print "Numeric comparison of the specified fields of different files and append results to the specified html file\n\n";
    print "Usage: ~ <title> <in1.csv> <numfld1> <numlabel1> <catFld1> <in2.csv> <fld2> <label2> <catFld2>... <inN.csv> <fldN> <labelN> <catFldN> <out.html>\n";
    exit(1);
}

if(scalar(@ARGV) < 10) {
    printUsage();
}

use Flat;
use math;
use Util;

my $title = shift @ARGV;
my $out = pop @ARGV;
#my ($dir, $outStem, $suf) = Util::getDirStemSuffix($out);

if(scalar(@ARGV) % 4 != 0) {
    printUsage();
}

my(@stemFiles, @flds, @labels, @catFlds, @inFiles);
my(%catFldVals);
my $overallArgs = "";

while(scalar(@ARGV) > 0) {
    my $in = Flat->new1(shift @ARGV);
    my $fld = shift @ARGV;
    my $label = shift @ARGV;
    my $catFld = $in->getFieldIndex(shift @ARGV);

    if(!$in->fieldIsNumeric($fld)) {
	die $in->getFieldName($fld)." in ".$in->getFileName()." is not numeric\n";
    }

    my(%fval2indice) = $in->getIndiceOfFieldValues($catFld);

    map { $catFldVals{$_}++; } keys %fval2indice;

    my($fname) = $in->getFileName();
    my ($d, $stem, $s) = Util::getDirStemSuffix($fname);
    undef $in;

    $overallArgs .= " $fname $fld $label";

    # partition the file by the catfield
    Util::run("partition.pl -r $fname $catFld /tmp/$stem.$s", 1, 0);
    
    push @stemFiles, "/tmp/$stem.$s";
    push @flds, $fld;
    push @labels, $label;
    push @catFlds, $catFld;
}

Util::run("numCompare.pl '$title' $overallArgs $out", 1);

# run numCompare on each partitioned file
foreach $fval (keys %catFldVals) {
    my($args) = "";

    for(my($i) = 0; $i < scalar(@stemFiles); $i++) {
	$args .= " $stemFiles[$i].$fval.csv $flds[$i] $labels[$i]";
    }

    Util::run("numCompare.pl '$title.$fval' $args $out", 1);
}
