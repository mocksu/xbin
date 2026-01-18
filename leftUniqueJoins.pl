#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("o", \%options);

if((@ARGV) != 6) {
    print "\nLike leftJoins.pl, but first make unique entries of the second file with the specified compare fields and keep fields\n\n";
    print "Usage: ~ -o <file1.csv> <\"field1 field2 ... fieldn\"> <file2.csv> <\"Field1 Field2 ... Fieldn\"> <\"Field1_to_keep ... FieldN_to_keep\"> <out.csv>\n\n";
    print "       -o\tOverlap only. Entries in <file1.csv> that do not have matches in <file2.csv> will be ignored\n";
    exit(1);
}

use Flat;
use Util;

my $file1 = shift @ARGV;
my $flds1 = shift @ARGV;
my $file2 = shift @ARGV;
my $flds2 = shift @ARGV;
my $keepFlds2 = shift @ARGV;
my $out = shift @ARGV;

# extract the fields to compare and to keep
my($reFlds) = join("|", split(/\s+/, $flds2), split(/\s+/, $keepFlds2));
Util::run("extractColumns.pl $file2 '$reFlds' $out.tmp", 1);
# get unique entries
Util::run("rmDuplicatedRows.pl $out.tmp", 1);

# run leftJoins.pl
my $opt = '';

if(exists $options{"o"}) {
    $opt = "-o";
}

Util::run("leftJoins.pl $opt $file1 $flds1 $out.tmp $flds2 $out", 1);
