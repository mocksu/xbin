#!/usr/bin/perl -w

if(scalar(@ARGV) != 1) {
    print "Run in sequence the commands specified in the input file\n";
    print "Each line of the file: <name_of_job> <command>\n\n";
    print "e.g.\n\n";
    print "cmd1 ls -ltr /tmp\n";
    print "cmd2 cp file1 file2\n\n";
    print "Usage: ~ <commands.file.txt>\n\n";
    exit(1);
}

my(%name2cmds);

open IN, "<$ARGV[0]" or die "Cannot open $ARGV[0]\n";

my $lastName = "";

while($line = <IN>) {
    chomp($line);
    my($name, $cmd) = split(/\s/, $line, 2);
#    print "name = $name, cmd = $cmd\n";
    
    # kill existing job with the name
    `killpbs.pl $name`;
    
    # run it
    if($lastName eq "") { # if the first job
	`runqsub.pl $line`;
	$lastName = $name;
    }
    else { # 
	# get the job id of the last command
	my $jidFile = ".__runseq.jid";
	my $jidLine = `qstat|grep $lastName`;
	chomp($jidLine);

#	print "jidLine = $jidLine\n";

	my ($jid) = split(/\s+/, $jidLine);

#	print "jid = $jid\n";

	`runqsub.pl -j $jid $line`;
	
	$lastName = $name;
    }
}

close IN;


	
