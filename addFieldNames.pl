#!/usr/bin/perl -w

if((@ARGV) < 2) {
    print "\nUsage: ~ <input.csv> <output.csv> <fld1> ... <fldn> or\n";
    print "\nUsage: ~ <input.csv> <output.csv>\n";
    
    exit(1);
}

use Flat;

my($in) = Flat->new1($ARGV[0]);

if($in->hasHeader()) {
#    die "Input file $ARGV[0] already has header: ", $in->getFieldNames(), "\n";
}

my($out) = $ARGV[1];

my($numFlds) = $in->getNumOfFields();

if(scalar(@ARGV) == $numFlds + 2) {
    shift @ARGV;
    shift @ARGV;
    $in->setFieldNames(@ARGV);
}
elsif(scalar(@ARGV) == 2) {
    my(@fldNames);

    for(my($i) = 0; $i < $numFlds; $i++) {
	$fldNames[$i] = "field$i";
    }

    $in->setFieldNames(@fldNames);
}
else {
    Util::dieIt("Incorrect number of fields specfied: expecting ", $numFlds, ", but got ", scalar(@ARGV), "\n");
  }

my($numOfRows) = $in->getNumOfRows();

$in->writeToFile("$out.tmp");
`mv $out.tmp $out`;
