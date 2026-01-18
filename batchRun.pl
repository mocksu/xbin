#!/usr/bin/perl -w

if(scalar(@ARGV) < 2) {
    print "Usage: ~ [-p number_of_processes] [-r replaceString] -c 'cluster_cmd' '<cmd with _str_>' <str1> ... <strN>\n";
    print "e.g.   ~ 'head _str_' /tmp/*.csv\n";
    print "       _serial_ will be replaced by an automatically assigned serial ID starting from 0\n";
    print "       ~ -p run in parallel. Default is to run serially (number of processes is 1)\n";
    print "       ~ -r the string to be replaced. Default is '_str_'\n";
    print "       ~ -c 'runbuqsub.pl partition long' 'partition.pl _str_ REGION /tmp/region' /tmp/chr*.geneRegion.csv\n";
    print "         each /tmp/chr?.geneRegion.csv will be run as 'runbuqsub.pl partition.chr?.geneRegion long partition _str_ REGION /tmp/region\n\n";
    exit(1);
}

use Flat;
use Util;
use Getopt::Std;
use Parallel::ForkManager;
use Term::ProgressBar;

my(%options);
getopts("p:r:c:", \%options);
my $cluster = (exists $options{"c"})?$options{"c"}:"";
my $rstr = (exists $options{"r"})?$options{"r"}:"_str_";

my $cmd = shift @ARGV;
my @strs = expandIndice(@ARGV);

my $count = 0;
my($pm); # process manager
my(@pids) = ();

if(exists $options{"p"}) {
    $pm =  new Parallel::ForkManager($options{"p"});
}
else {
    $pm =  new Parallel::ForkManager(1);
}

my($num) = scalar(@strs);
my $progress_bar = Term::ProgressBar->new($num);

foreach $s (@strs) {
    $count++;

    my $c = $cmd;
    $c =~ s/$rstr/$s/g;
    $c =~ s/_serial_/$count/g;

    if($cluster) {
	my($dir, $stem, $suf) = Util::getDirStemSuffix($s);
	my @args = split(/\s+/, $cluster);
	$args[1] .= $stem;
	$c = join(" ", @args, $c);
    }

    # https://stackoverflow.com/questions/16538708/how-to-limit-the-child-process-in-perl
    $pm->start and next;
    system( $c );
    $progress_bar->update($count);
    $pm->finish;    
}

print "_____________________________DONE_____________________________\n";

sub expandIndice {
    my(@arr) = @_;

    my(@results) = ();

    foreach $a (@arr) {
	if($a =~ /\-\-/) {
	    my($start, $end) = split(/\-\-/, $a);
	    print "start = $start, end = $end\n";

	    map { push @results, $_; } ($start .. $end);
	}
	else {
	    push @results, $a;
	}
    }

    return @results;
}
