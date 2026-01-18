#!/usr/bin/perl

if(scalar(@ARGV) < 1) {    
    print "\nUsage: [-j <jid>] <my.pbs>\n\n";
    print "Run <my.pbs> [after job <jid> finishes]\n\n";
    exit(1);
}

my($jid);

if($ARGV[0] eq "-j") {
    shift @ARGV;
    $jid = shift @ARGV;
}

my($pbs) = shift @ARGV;
my($name) = "$pbs.pbs";

my($job);

if($jid) {
    $job = "qsub -N $name -cwd -V -v PERL5LIB -l arch=glinux -hold_jid $jid $pbs";
}
else {
    $job = "qsub -N $name -cwd -V -v PERL5LIB -l arch=glinux $pbs";
}

print "runing:\n$job\n";

`$job`;
