#!/usr/bin/perl -w

if(scalar(@ARGV) != 1) {
  print "Convert a text file in dos format to mac/unix format\n\n";

    print "Usage: ~ <in.dosfile.txt>\n";
  print "\n";

    exit(1);
}

my $in = shift @ARGV;


`tr '\r' '\n' < $in > $in.tmp`;

`mv $in.tmp $in`;
