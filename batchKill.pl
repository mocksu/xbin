#!/usr/bin/perl -w

if(scalar(@ARGV) == 0) {
    print "Usage: ~ <grepRE1> ... <grepREN>\n";
    exit(1);
}

use Util;

my $grepRE = join("|", map { "grep $_"; } @ARGV);
my $jobsRE = "ps -ef|$grepRE";

print "jobsRE = $jobsRE\n";

my @jobs = split(/\n/, `$jobsRE`);

foreach $j (@jobs) {
  chomp($j);
  $j = Util::trim($j);
  @arr = split(/\s+/, $j);

  print "killing job $j\n";
  `kill -9 $arr[1]`;
}
