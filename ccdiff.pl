#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

my(%options);
getopts("a", \%options);
my($append) = exists $options{"a"}?"-a":"";

if(scalar(@ARGV) != 5 && scalar(@ARGV) != 7) {
    print "Get the rows with shared IDs and compare the specified columns\n\n";
    print "Usage: [-a] ~ <file1.csv> <file2.csv> <out.txt> <id1> <fld1> [<id2> <fld2>]\n";
    print "-a\tappend results in <out.csv>. Default is to create <out.csv> and write results to it\n";
    print "The id field and the comparing field can be omitted if same with those of file1\n\n";
    exit(1);
}

my($file1org) = shift @ARGV;
my $file2org = shift @ARGV;
my $out = shift @ARGV;
my $id1 = shift @ARGV;
my $fld1 = shift @ARGV;
my($id2, $fld2);

if(scalar(@ARGV) == 2) {
    $id2 = shift @ARGV;
    $fld2 = shift @ARGV;
}
else {
    my $flat1 = Flat->new1($file1org);
    $id2 = $flat1->getFieldName($id1);
    $fld2 = $flat1->getFieldName($fld1);
    $flat1->destroy();
}

### get the rows with shared ids
my $file1 = "$file1org.shared";
my $file2 = "$file2org.shared";
Util::run("segregate.pl $file1org $id1 $file2org $id2 $file1 /dev/null", 1);
Util::run("segregate.pl $file2org $id2 $file1 $id1 $file2 /dev/null", 1);

### extract relevant fields, rm duplicated rows, sort by ids
Util::run("cdiff.pl $append $file1 $file2 $out $id1 $fld1 $id2 $fld2", 1);
