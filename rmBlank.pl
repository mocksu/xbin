#!/usr/bin/perl -w

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "\nUsage: ~ <input_file> [<out_file>]\n\n";
    print "\tRemove blank lines\n\n";
    exit(1);
}

use Util;

my($tmp) = "$ARGV[0]";
$tmp =~ s/\//\./g;
$tmp = "/tmp/.__rmBlank.$tmp";

# read data from the file
open IN, "$ARGV[0]" || die $!;
open TMP, "+>$tmp" || die $!;

my $out = $ARGV[0];

if(scalar(@ARGV) == 2) {
  $out = $ARGV[1];
}

while($line = <IN>) {
    chomp($line);
 #   $line = Util::trim($line);

    if($line) {
	print TMP "$line\n";
    }
}

close IN;

close TMP;

Util::run("mv $tmp $out", 1);
