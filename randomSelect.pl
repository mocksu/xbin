#!/usr/bin/perl -w

sub printUsage() {
    print "Usage:\n\n";    
    print "~ [-h|H] [-n <num_of_rows>] <in.csv> <firstportion> <firstFile> <secondFile>\n\n";
    print "-h\t<in.csv> has no header row\n";
    print "-H\t<in.csv> has header row\n\n";
    print "e.g. ~ all.csv 0.33[25] test.csv train.csv\n\n";
    print "e.g. ~ -n 3325 all.csv 0.33[25] test.csv train.csv\n\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("n:hH", \%options);
my($numOfRows) = -1;

if(exists $options{"n"}) {
    $numOfRows = $options{"n"};
}

if((@ARGV) != 4) {
    printUsage();
}

use Flat;

my $in;

if(exists $options{"h"}) { # no header
    $in = Flat->new($ARGV[0], 0); 
}
elsif(exists $options{"H"}) { # with header row
    $in = Flat->new($ARGV[0], 1);
}
else { # let the file speaks for itself
    $in = Flat->new1($ARGV[0]);
}

my($firstPortion) = $ARGV[1];
open FIRST, "+>$ARGV[2]" || die $!;
open SECOND, "+>$ARGV[3]" || die $!;

my(@fnames) = ();

if($in->hasHeader()) {
    @fnames = $in->getFieldNames();
}

if($numOfRows == -1) {
    $numOfRows = $in->getNumOfRows();
}

my($firstNum) = $firstPortion;

if($firstPortion < 1) {
    $firstNum = $firstPortion * $numOfRows;
}

if($firstNum > $numOfRows) {
    die "The \# of rows $firstNum for the first file exceeds the total \# of rows\n";
}

if(scalar(@fnames) > 0) {
    print FIRST Flat::dataRowToString(@fnames), "\n";
    print SECOND Flat::dataRowToString(@fnames), "\n";
}

my($count) = 0;
my(%firstIndice);

while($count < $firstNum) {
    my($ind) = int(rand($numOfRows));

    if(exists $firstIndice{$ind}) {
	next;
    }
    else {
	$count++;
	$firstIndice{$ind} = 1;
    }
}

my $i = 0;

while($row = $in->readNextRow()) {
    if(exists $firstIndice{$i}) {
	print FIRST join("\t", @{$row}), "\n";
    }
    else {
	print SECOND join("\t", @{$row}), "\n";
    }

    $i++;
}

close FIRST;
close SECOND;
