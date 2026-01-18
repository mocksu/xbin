#!/usr/bin/perl -w

if((@ARGV) != 2 && (@ARGV) != 3) {
    print "\nUsage: ~ <input_file> <RE_of_Fields> [<out.csv>]\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my($in) = Flat->new1(shift @ARGV);
my($fldRE) = shift @ARGV;
my($out);

my $inFile = $in->getFileName();

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in->getFileName();
}

my(@indice) = @{$in->getFieldIndiceByRE($fldRE)};

if(scalar(@indice) == 0) { # no fields found
    if($in->getFileName() ne $out) {
	Util::run("cp $inFile $out", 0);
      }
    # else same file, no need to do anything
}
else { 
    Util::run("rmColumns.pl $inFile '".join("|", @indice)."' $out", 1);
  }
