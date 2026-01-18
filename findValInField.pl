#!/usr/bin/perl -w

use Flat;
use math;

use Getopt::Std;

my(%options);
getopts("f:", \%options);

if(scalar(@ARGV) != 3) {
    print "Usage: ~ [-f <fld1|...|fldN>] <input.csv> <ID_fld> <re_of_val>\n";
    print "e.g. ~ /tmp/t.csv name2 '=~ /^CREM\$/'\n";
    exit(1);
}

my($in) = Flat->new1($ARGV[0]);
my($idFld) = $in->getFieldIndex($ARGV[1]);
my $idName = $in->getFieldName($idFld);

my(@fldNames);

if(exists $options{"f"}) {
    my @flds = split(/\|/, $options{"f"});
    @fldNames = $in->getFieldNames(@flds);
}
else {
    @fldNames = $in->getFieldNames();
}

my @fldIndice = $in->getFieldIndice([@fldNames]);

my($val) = $ARGV[2];

if($val !~ /\/.+?\//) {
    $val = "=~ /$val/";
}

my(@data) = $in->getDataArray();

print join("\t", $idName, @fldNames), "\n";

for(my($i) = 0; $i < scalar(@data); $i++) {
    my($m) = "'$data[$i][$idFld]' $val";

    if(eval($m)) {
	print join("\t", $data[$i][$idFld], map { $data[$i][$_]; } @fldIndice), "\n";
    }
}
