#!/usr/bin/perl

use Util;
use Getopt::Std;
my(%options);
getopts("M:", \%options);
my($email) = "";

if(exists $options{"M"}) {
    $email = $options{"M"};
}

if(scalar(@ARGV) < 3) {    
    print "Usage: ~ [-M email\@address] <process_name> <long|medium|short|zodiac> <command>\n";
    print "-m\tsend mail after finish\n\n";
    exit(1);
}

my($name) = shift @ARGV;

# fix the length of $name if it's too long
$name = Util::shortenName($name, 11);

my($pbs) = "$name.pbs";
my($ls) = shift @ARGV;
open PBS, "+>$pbs" || die $!;

# copy specified input files to /scr
my(@oriInputs);

my($cmd);
my(@copied);

$cmd = $ARGV[0];

for(my($i) = 1; $i < scalar(@ARGV); $i++) {
    my $a = $ARGV[$i];

    if($ARGV[$i] =~ /copy:(.+)/) {
	my($dir, $file) = Util::getDirFile($1);
	$file .= ".arg$i";

	push @oriInputs, $1;

	$a = "/scr/\$PBS_JOBID/$file";
	push @copied, $a;
    }

    if($a !~ '^-') {
# if an argument is a file name, quote it
	my @paths = Util::getFilePaths($a);
	
	foreach $p (@paths) {
	    if(-e $p) {
		$a = "'$a'";
		last;
	    }
	}
    }
    
    $cmd .= " $a";    
}

my($dir) = `pwd`;
chomp($dir);

print PBS <<SCRIPT1;
#!/bin/bash
# script for submitting jobs to the bioinfo linux cluster
# This is a simple script that print some diagnostic
# info and runs a command
#PBS -N $name
# request 1 node
#PBS -l nodes=1
SCRIPT1

if($email) {
    print PBS "#PBS -m e\n";
    print PBS "#PBS -M $email\n";
}

print PBS <<SCRIPT2;
# cd into the working directory
cd $dir
# print out some diagnostic stuff
echo Running on host `hostname`
echo
echo Directory is $dir
echo
rm /scr/\$PBS_JOBID/*
echo Start time is `date`
echo
echo copying input files to /scr/\$PBS_JOBID
SCRIPT2

for(my($i) = 0; $i < scalar(@oriInputs); $i++) {
    my $date = `date`;
    print PBS "echo $date";
    print PBS "cp $oriInputs[$i] $copied[$i]\n";
}

print PBS <<SCRIPT;
# run my commands
$cmd
# print out some diagnostic stuff
echo Stop time is `date`
echo

SCRIPT

close PBS;

# run it
my $query = "qsub -q $ls $pbs";
Util::run($query);
