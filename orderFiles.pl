#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <pathBeforeNum> <pathAfterNum> <cmd>\n";
    exit(1);
}

use Util;

my $before = shift @ARGV;
my $after = shift @ARGV;
my $cmd = shift @ARGV;
my $out = "$before.tmp.$after";

my @files = <$before\*$after>;

#print "files = @files\n";
my %numExists = ();

foreach $f (@files) {
    $f =~ /$before(\d+)$after/;

    if($1) {
	$numExists{$1} = 1;
    }
}

my @nums = keys %numExists;

open OUT1, "+>$out.1";

my @orderedNums = sort { $a<=>$b } @nums;
map { print OUT1 "$_\n"; } @orderedNums;
close OUT1;

my @sorted = map { "$before$_$after"; } @orderedNums;

Util::run("$cmd @sorted > $out.2", 0);

Util::run("catColumns.pl $out.1 $out.2 $out", 0);
Util::run("rm $out.1 $out.2", 0);
Util::run("more $out", 0);
Util::run("rm $out", 0);
