#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("ar", \%options);
my $APPEND = exists $options{"a"};
my $RM = exists $options{"r"};

if(scalar(@ARGV) < 5) {
    print "Usage: ~ [-a] [-r] <in1.csv> <...> <in_n.csv> <dir_field_num> <hash_fld_num> <num_of_files> <out_stem>\n";
    print "       num_of_files\tmaximum number of files to partition into\n";
    print "       -a\tto append results to existing results (if any)\n";
    print "       -r\tto remove the specified field in the output file\n\n";
    exit(1);
}

use Util;
use Flat;
use math;
use Fcntl ':flock';

my $in = Flat->new1($ARGV[0]);
my($stem) = pop @ARGV;
my $numOfFiles = pop @ARGV;
my($hashFldNo) = $in->getFieldIndex(pop @ARGV);
my($dirFldNo) = $in->getFieldIndex(pop @ARGV);

my(@fieldNames) = $in->getFieldNames();
my(%uniqueVal);

my(%val2outfile);

while(scalar(@ARGV) > 0) {
  undef $in;
  
  my $fname = shift @ARGV;
  print "randomPartion.pl: processing $fname at ", `date`;

  if($fname =~ /(.+)\.gz$/) {      
      Util::run("gunzip $fname", 1);
	$fname = $1;
    }

  my $in = Flat->new1($fname);
  
  # lock the files for exclusive access
  
  while($row = $in->readNextRow()) {
      my $dir = $row->[$dirFldNo];
      my $fval = math::util::hashStringToInteger($row->[$hashFldNo], 100);
      my $path = "$dir/$fval";
      my $fh;
    
      if(exists $val2outfile{$path}) {
	  $fh = $val2outfile{$path};
      }
      else { # file does not exist yet
	  $fh = "OUT$dir.$fval";
	  my @fldNames = @fieldNames;
	  
	  if(!(-d "$stem/$dir")) {
	      Util::mkdir("$stem/$dir", 0);
	  }

	  if($APPEND) {
	      open $fh, ">>$stem/$dir/$fval.csv" or die $!;
	  }
	  else {
	      open $fh, "+>$stem/$dir/$fval.csv" or die $!;
	  }
	  
#disable lock for now:      flock($fh, LOCK_EX);
	  
	  if($in->hasHeader()) {
	      if($RM) {
		  splice @fldNames, $dirFldNo, 1;	      
	      }
	      
	      print $fh Flat::dataRowToString(@fldNames), "\n";
	  }
	  
	  $val2outfile{$fval} = $fh;
      }
      
      if($RM) {
	  splice @{$row}, $dirFldNo, 1;
      }
      
      print $fh Flat::dataRowToString(@{$row}), "\n";
  }

  # unlock the output files
  foreach $fh (values %val2outfile) {
# disable lock for now:      flock($fh, LOCK_UN);
      close $fh;
  }

  %val2outfile = ();

  Util::run("gzip $fname", 1);
}

print "DONE partition.pl at ", `date`;
