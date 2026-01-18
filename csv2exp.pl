#!/usr/bin/perl -w

# convert csv format to bed format
if((@ARGV) != 2 && scalar(@ARGV) != 1) {
    print "Usage: ~ <data.csv> [<out.exp>]\n";
    print "\t.exp is the data format of caWorkBench2.0\n\n";
    exit(1);
}

# add a column after the first column

use Flat;

my($in) = Flat->new($ARGV[0], 1);
my(@firstColumn) = $in->getColumnData(0);

$in->insertField('Annotatin', 1, \@firstColumn);

my($out);

if(scalar(@ARGV) == 2) {
    $out = $ARGV[1];
}
else {
    $out = $ARGV[0];
    $out =~ s/\.csv$/\.exp/;
}

$in->writeToFile($out);
