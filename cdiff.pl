#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

sub printUsage {
    print "Usage: ~ [-a|o] <file1.csv> <file2.csv> <out.csv> <id1> <fld1> [<id2> <fld2>]\n";
    print "-a|o\tappend|overwrite results in <out.csv>. Default is to create <out.csv> and write results to it\n";
    print "The id field and the comparing field can be omitted if same with those of file1\n\n";
    exit(1);
}

my(%options);
getopts("ao", \%options);
my($append) = exists $options{"a"};
my $overwrite = exists $options{"o"};

if($append && $overwrite) {
    print "-a and -o cannot be specified at the same time\n";
    printUsage();
}

if(scalar(@ARGV) != 5 && scalar(@ARGV) != 7) {
    printUsage();
}

my($file1) = shift @ARGV;
my $file2 = shift @ARGV;
my $out = shift @ARGV;

if(!$overwrite && (-e $out)) {
    print "output file $out exists\n";
    printUsage();
}

my $id1 = shift @ARGV;
my $fld1 = shift @ARGV;
my($id2, $fld2);


if(scalar(@ARGV) == 2) {
    $id2 = shift @ARGV;
    $fld2 = shift @ARGV;
}
else {
    my $flat1 = Flat->new1($file1);
    $id2 = $flat1->getFieldName($id1);
    $fld2 = $flat1->getFieldName($fld1);
    $flat1->destroy();
}

### extract relevant fields, rm duplicated rows, sort by ids
Util::run("extractColumns.pl $file1 '$id1|$fld1' $file1.cdiff", 0);
Util::run("rmDuplicatedRows.pl $file1.cdiff", 0);
Util::run("FlatSort.pl -r '-k 1' $file1.cdiff $file1.cdiff.sorted", 0);
Util::run("rm $file1.cdiff", 0);

Util::run("extractColumns.pl $file2 '$id2|$fld2' $file2.cdiff", 0);
Util::run("rmDuplicatedRows.pl $file2.cdiff", 0);
Util::run("FlatSort.pl -r '-k 1' $file2.cdiff $file2.cdiff.sorted", 0);
Util::run("rm $file2.cdiff", 0);

### compare
my $oh = "OUT";

if($append) {
    open $oh, ">>$out" or die "Cannot open $out\n";
}
else { # create new
    open $oh, "+>$out" or die "Cannot open $out\n";
}

print $oh "Field to compare: $fld2\n";
close $oh;

Util::run("diff $file1.cdiff.sorted $file2.cdiff.sorted > $out.new", 1);

Util::run("cat $out $out.new > $out.large", 0);
Util::run("mv $out.large $out", 0);
Util::run("rm $out.new $file1.cdiff.sorted $file2.cdiff.sorted", 1);
Util::run("more $out", 1);
