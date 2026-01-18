#!/usr/bin/perl

use Util;
use Getopt::Std;
my(%options);
getopts("M:", \%options);
my($email) = "";

if(exists $options{"M"}) {
    $email = "-M ".$options{"M"};
}

if(scalar(@ARGV) < 3) {    
    print "Usage: ~ [-M email\@address] <process_name> <long|medium|short|zodiac> <max_num_of_jobs> <command>\n";
    print "-M\tsend mail after finish\n";
    print "max_num_of_jobs\tlong: 80 or 20 (zodiac); medium: 100; short: 150\n\n";
    exit(1);
}

my($name) = shift @ARGV;
my($pbs) = "$name.pbs";
my($ls) = shift @ARGV;
my $num_jobs = shift @ARGV;

# if an argument is a file name, quote it
my(@args) = @ARGV;

foreach(my($i) = 1; $i < scalar(@args); $i++) {
    my @paths = Util::getFilePaths($args[$i]);

    foreach $p (@paths) {
	if(-e $p) {
#	    print "$args[$i] are files\n";
	    $args[$i] = "'$args[$i]'";
	    last;
	}
    }
}

my($cmd) = join(" ", @args);

# get number of jobs currently running
while(getNumOfJobs() >= $num_jobs) {
    sleep(60);
}

Util::run("runbuqsub.pl $email $name $ls $cmd", 1);

sub getNumOfJobs {
    my $stat = `qstat|grep moxu|wc`;
    chomp($stat);
    $stat =~ s/^\s*//g;
    my(@pieces) = split(/\s+/, $stat);
    
    return shift @pieces;
}
