#!/usr/bin/perl

if(scalar(@ARGV) < 2) {    
    print "\nUsage: [-j <jid>] <job_name> <command>\n\n";
    print "Run <command> [after job <jid> finishes]\n\n";
    exit(1);
}

my($jid);

if($ARGV[0] eq "-j") {
    shift @ARGV;
    $jid = shift @ARGV;
}

my($name) = $ARGV[0];
my($cmd) = $ARGV[1];

for(my($i) = 2; $i <= $#ARGV; $i++) {
    $cmd .= " $ARGV[$i]";
}

my($pbs) = "$name.pbs";
open PBS, "+>$pbs" || die $!;

print PBS <<SCRIPT;
# run my commands
echo Running "$pbs" with "$cmd"
$cmd
SCRIPT

close PBS;

# run it
my($job);

if($jid) {
    $job = "qsub -N $name -cwd -V -v PERL5LIB -l arch=glinux -hold_jid $jid $pbs";
}
else {
    $job = "qsub -N $name -cwd -V -v PERL5LIB -l arch=glinux $pbs";
}

print "runing:\n$job\n";

`$job`;
