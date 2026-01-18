#!/usr/bin/perl -w

if(scalar(@ARGV) != 6) {
    print "Usage: ~ <in.csv> <idFld> <valFld> <portion2include> <included.csv> <excluded.csv>\n";
    exit(1);
}

use Flat;

my($in) = shift @ARGV;
my $id = shift @ARGV;
my $pheno = shift @ARGV;
my $p = shift @ARGV;
my($inc) = shift @ARGV;
my $exc = shift @ARGV;

# randomly select samples
Util::run("randomSelect.pl $in $p /dev/null $exc", 1);
Util::run("excludeSamples.pl $in $id $pheno $exc $id $inc", 1);
