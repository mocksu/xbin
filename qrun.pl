#!/usr/bin/perl -w

use Util;

if(scalar(@ARGV) < 1) {
    print "Usage: ~ <command to be executed>\n";
    exit(1);
}

my $noSpace = join("", @ARGV);
$noSpace =~ s/[^a-zA-Z0-9]//g;
my $name = Util::shortenName($noSpace, 11);
$name =~ s/^\d+//;

my $machine = `uname -n`;
chomp($machine);

my $time = "short";

if($machine =~ /user3/i) {
    $time = "zodiac";
}

Util::run("runbuqsub.pl $name $time '@ARGV'", 1);
