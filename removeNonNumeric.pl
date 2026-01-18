#!/usr/bin/perl -w

if((@ARGV) != 1) {
    print "\nUsage: ~ <input_file>\n\n";
    exit(1);
}

# read data from the file
open IN, "$ARGV[0]" || die $!;

my $line = <IN>; # read the 1st line with field names
print $line;

use math;

while($line = <IN>) {
    chomp($line);

    my(@ldata) = split(/\t/, $line);
    my($numeric) = 1;

    foreach $d (@ldata) {
	if(math::util::NaN($d)) {
	    $numeric = 0;
	    last;
	}
    }

    if($numeric) {
	print $line, "\n";
    }
    # else ignore
}

close IN;
