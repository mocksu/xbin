#!/usr/bin/perl -w

use Util;
use Flat;

my $cmdLine = Util::getCmdLine();

if(scalar(@ARGV) != 4) {
    print "Usage: ~ <in.csv> <partitionFld> <'joinFld1|...|joinFldN'> <out.csv>\n";
    exit(1);
}

my $inFile = shift @ARGV;
my $in = Flat->new1($inFile);
my $pfld = shift @ARGV;
my @jflds = $in->getFieldNames($in->getFieldIndice([split(/\|/, shift @ARGV)]));
my($out) = shift @ARGV;

my $ostem = "$out.part";

Util::run("partition.pl -r $inFile $pfld $ostem", 0);

my(@partFiles) = Util::getFilePaths("$ostem*");

# label field names for each partitoned files
# and prepare command line for leftJoins.pl
my $cmd = "leftJoins.pl";

foreach $p (@partFiles) {
    my($pval) = ($p =~ /$out\.part\.(.+?)\.csv/);
    Util::run("labelFieldNames.pl -p $pval. $p", 0);
    
    $cmd .= " $p '".join(" ", map { "$pval.$_"; } @jflds)."'";
}

# join the partioned files into one
Util::run("$cmd $out", 1);

# remove the tmp files
Util::run("rm @partFiles", 0);
