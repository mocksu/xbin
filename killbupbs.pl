#!/usr/bin/perl

if(scalar(@ARGV) != 1) {    
    die "Usage: ~ <re>\n";
}

my($re) = $ARGV[0];

my(@jobs) = split(/\n/, `qstat |grep moxu`);

#print scalar(@jobs), " jobs = @jobs\n";

foreach $j (@jobs) {
    if($j =~ /$re/) {
	my(@pieces) = split(/\s+/, $j);

	print "killing $j\n";
	`qdel $pieces[0]`;
    }
}
