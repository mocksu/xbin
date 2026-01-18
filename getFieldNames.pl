#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

my(%options);
getopts("s:n:x:", \%options);
my($stat) = $options{"s"};


if(scalar(@ARGV) != 1) {
    print "Usage: ~ <in.csv>\n";
    exit(1);
}

my($in) = Flat->new1(shift @ARGV);

if($in->hasHeader()) {
  my(@fnames) = $in->getFieldNames();
  
  for(my($i) = 0; $i < scalar(@fnames); $i++) {
    print "$i: '$fnames[$i]'\n";
  }
}
else {
  print "There is no header. The first data line is\n";
  my @rdata =  @{$in->readNextRow()};
  
  for(my($i) = 0; $i < scalar(@rdata); $i++) {
    print "$i: '$rdata[$i]'\n";
  }
}

$in->destroy();
