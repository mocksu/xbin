#!/usr/bin/perl -w

use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("p:a:B", \%options);

if(!(exists $options{"p"}) &&
   !(exists $options{"a"})) {
    printUsage();
}

sub printUsage {
    print "Usage: ~ [-p pct|-a absolute_value] [-B] <in.csv> <field> <above.csv> <below.csv>\n";
    print "\tfield_# 0 based field number. \n";
    print "\tB to put entries with value equal to the specified threshold into <below.csv>; otherwise into <above.csv>\n";
    print "e.g. ~ -p 0.1 /tmp/t.csv 0 /tmp/a.csv /tmp/b.csv\n";
    print "       is to threshold on percentage -- top 10% to <above.csv> (inclusive), rest to <below.csv>\n";
    print "     ~ -a 8 /tmp/t.csv 0 /tmp/a.csv /tmp/b.csv\n";
    print "       is to threshold on absolute value -- entries with 8 or more in field 0 to <above.csv>\n\n";
    exit(1);
}

if(scalar(@ARGV) != 4) {
    printUsage();
}

use Flat;
use Util;

my($infile) = Flat->new1(shift @ARGV);
my($fno) = $infile->getFieldIndex(shift @ARGV);
my $fname = $infile->getFieldName($fno);
my $above = shift @ARGV;
my $below = shift @ARGV;
my $aboveTmp = "$above.tmp";
my $belowTmp = "$below.tmp";

if($above eq "/dev/null") {
    $aboveTmp = "/dev/null";
}

if($below eq "/dev/null") {
    $belowTmp = "/dev/null";
}

open ABOVE, "+>$aboveTmp" or die $!;
open BELOW, "+>$belowTmp" or die $!;

print ABOVE "# $cmdLine\n# above\n";
print BELOW "# $cmdLine\n# below\n";

if($infile->hasHeader()) {
    my(@fieldNames) = $infile->getFieldNames();
    print ABOVE join("\t", @fieldNames), "\n";
    print BELOW join("\t", @fieldNames), "\n";
}

if(exists $options{"p"}) {
# sort the data in the specified field
    my(@fdata) = $infile->getFieldData($fno);
    my(@sfdata) = sort {$a <=> $b} @fdata;
    print "threshold row index = ", $infile->getRowIndex(), "\n";
    $thold = $sfdata[int((scalar(@sfdata) - 1) * (1 - $options{"p"}))];
}
else {
    $thold = $options{"a"};
}

my $TBELOW = 0; # equal threshold entries to <below.csv> or not; default into <above.csv>

if(exists $options{"B"}) {
    $TBELOW = 1;
}

my $acount = 0;
my $bcount = 0;

my $nanMet = 0;

while($row = $infile->readNextRow()) {
    if(math::util::isNaN($row->[$fno])) {
	$nanMet++;
	next;
    }

    if($row->[$fno] > $thold ||
       (!$TBELOW && $row->[$fno] == $thold)) {
	print ABOVE "$row->[0]";

	for(my($j) = 1; $j < (@{$row}); $j++) {
	    print ABOVE "\t$row->[$j]";
	}

	print ABOVE "\n";
	$acount++;
    }
    else {
	print BELOW "$row->[0]";

	for(my($j) = 1; $j < (@{$row}); $j++) {
	    print BELOW "\t$row->[$j]";
	}

	print BELOW "\n";
	$bcount++;
    }
}

close ABOVE;
close BELOW;

print "Threshold: $thold; ABOVE count: $acount; BELOW count: $bcount; NaN: $nanMet\n";

if($nanMet != 0) {
    warn "$nanMet entries with non-numeric field values are discarded\n";
}

if($aboveTmp ne "/dev/null") {
    Util::run("mv $aboveTmp $above", 1);
  }

if($belowTmp ne "/dev/null") {
    Util::run("mv $belowTmp $below", 1);
  }
