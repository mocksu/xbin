#!/usr/bin/perl -w

sub printUsage {
    my($msg) = @_;
    print "$msg\n";
    print "Usage: ~ [-M email\@address] <process_name> <long|normal|short|priority> <max_num_of_jobs> <command>\n";
    print "-m\tsend mail after finish\n\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("M:", \%options);
my($email) = "";

if(exists $options{"M"}) {
    $email = $options{"M"};
}

if(scalar(@ARGV) < 4) {
    printUsage("");
}

use math;

my($name) = shift @ARGV;
my($lsf) = "$name.lsf";
my($ls) = shift @ARGV;
my $num_jobs = shift @ARGV;
my($cmd) = join(" ", @ARGV);

if($num_jobs !~ /^\d+$/) {
    printUsage("<max_num_of_jobs> should be an integer, but is $num_jobs");
}

my($dir) = `pwd`;
chomp($dir);

open LSF, "+>$lsf" or die $!;
print LSF <<SCRIPT;
#!/bin/bash

# Here is to define the job array, here I have 20 jobs
#BSUB -J $name
#BSUB -q $ls
#BSUB -o %J.out
#BSUB -e %J.err

# how many CPU for each job element
#BSUB -n 1
#BSUB -u $email
#BSUB -N

# getting to the working dir
workdir=$dir
cd \$workdir

$cmd

# end of job script
SCRIPT

close LSF;

# run it
`bsub < $lsf`;



