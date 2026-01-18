#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my(%options);
getopts("uo", \%options);
my($overlapOnly) = $options{"o"};

my($unique) = 0;

if(exists $options{"u"}) {
    $unique = 1;
}

if(scalar(@ARGV) < 4) {
  print "Use the specified fields to join the specified files to a single file\n\n";
    print "Usage: ~ [-u] [-o] \"fld1 fld2 ... fldX\" <file1.csv> ... <fileN> <out.csv>\n\n";
    print "       -u\tThe entries in each file specified by the fields are unique [NOT IMPLEMENTED YET!!!]\n";
    print "       -o\tOverlap only. Entries in <file1.csv> that do not have matches in <file2.csv> will be ignored\n";  
    exit(1);
}

my $fldStr = shift @ARGV;
my($out) = pop @ARGV;
my @files = @ARGV;

my $optStr = "";

if(exists $options{"u"}) {
  $optStr .= " -u";
}

if(exists $options{"o"}) {
  $optStr .= " -o";
}

my $f1 = shift @files;

for(my($i) = 0; $i < scalar(@files); $i++) {
  Util::run("leftJoins.pl $optStr $f1 \"$fldStr\" $files[$i] \"$fldStr\" $out.$i", 1);

  $f1 = "$out.$i";
}
