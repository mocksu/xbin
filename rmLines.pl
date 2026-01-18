#!/usr/bin/perl -w

if(scalar(@ARGV) != 2 && scalar(@ARGV) != 3) {
    print "\nUsage: ~ <input_file>  <re_of_line> [outfile]\n\n";
    print "\tRemove lines with the specified regular expression\n\n";
    exit(1);
}

use Util;

my($tmp) = "/tmp/.__rmLines_tmp__out.txt";

# read data from the file
open IN, "<$ARGV[0]" || die $!;
my($re) = $ARGV[1];

my $out = $ARGV[0];

if(scalar(@ARGV) == 3) {
  $out = $ARGV[2];
}

open TMP, "+>$tmp" || die $!;

my $count = 0;

while($line = <IN>) {
    chomp($line);
#    $line = Util::trim($line);

    if(!($line =~ /$re/)) {
	print TMP "$line\n";
    }
    else {
	$count++;
    }
}

close IN;

close TMP;

Util::run("mv $tmp $out", 1);

print "Removed $count lines\n";
