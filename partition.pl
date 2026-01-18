#!/usr/bin/perl -w

use Util;
my $cmdLine = Util::getCmdLine();

use Getopt::Std;
my(%options);
getopts("ar", \%options);
my $APPEND = exists $options{"a"};
my $RM = exists $options{"r"};

if(scalar(@ARGV) < 3) {
    print "Partition by the value of the specified field\n";
    print "Usage: ~ [-a] [-r] <in1.csv> <...> <in_n.csv> <field_num> <out_stem>\n";
    print "       -a\tto append results to existing results (if any)\n";
    print "       -r\tto remove the specified field in the output file\n\n";
    exit(1);
}

use Flat;
use math;
use Fcntl ':flock';

my $in = Flat->new1($ARGV[0]);
my($stem) = pop @ARGV;
my($fldNo) = $in->getFieldIndex(pop @ARGV);

my(@fieldNames) = $in->getFieldNames();
my(%uniqueVal);

my(%val2outfile);

while(scalar(@ARGV) > 0) {
  undef $in;
  
  my $fname = shift @ARGV;
  print "partion.pl: processing $fname at ", `date`;

  if($fname =~ /(.+)\.gz$/) {      
      Util::run("gunzip $fname", 1);
	$fname = $1;
    }

  my $in = Flat->new1($fname);
  
  # lock the files for exclusive access
  
  while($row = $in->readNextRow()) {
    my $fval = $row->[$fldNo];
    my $fh;
    
    if(exists $val2outfile{$fval}) {
      $fh = $val2outfile{$fval};
    }
    else { # file does not exist yet
      $fh = "OUT$fval";
      my @fldNames = @fieldNames;

      if($APPEND) {
	  open $fh, ">>$stem.$fval.csv" or die $!;
      }
      else {
	  open $fh, "+>$stem.$fval.csv" or die $!;
	  print $fh "# $cmdLine\n";
      }
      
#disable lock for now:      flock($fh, LOCK_EX);
      
      if($in->hasHeader()) {
	  if($RM) {
	      splice @fldNames, $fldNo, 1;	      
	  }
	  
	  print $fh Flat::dataRowToString(@fldNames), "\n";
      }
      
      $val2outfile{$fval} = $fh;
  }
    
    if($RM) {
	splice @{$row}, $fldNo, 1;
    }
    
    print $fh Flat::dataRowToString(@{$row}), "\n";
}

  # unlock the output files
  foreach $fh (values %val2outfile) {
# disable lock for now:      flock($fh, LOCK_UN);
  }

#  Util::run("gzip $fname", 1);
}

# close files
foreach $fh (values %val2outfile) {
    close $fh;
}

print "DONE partition.pl at ", `date`;
