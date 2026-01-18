#!/usr/bin/perl -w

# convert csv format to bed format
if((@ARGV) != 2 && scalar(@ARGV) != 1) {
    print "Usage: ~ <in.txt> [<out.txt>]\n";
    print "\tconvert everything into lower case\n";
    exit(1);
}

# add a column after the first column
my($in) = $ARGV[0];
my($out);

if(scalar(@ARGV) == 2) {
    $out = $in;
}
else {
    $out = $in;
    $out .= ".uc";
}

open IN, "<$in" || die $!;
open OUT, ">$out" || die $!;

while($line = <IN>) {
    print OUT uc($line);
}

close IN;
close OUT;

if(scalar(@ARGV) == 1) {
    `mv $out $in`;
}
