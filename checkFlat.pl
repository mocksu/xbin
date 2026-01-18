#!/usr/bin/perl -w

use Flat;

if(scalar(@ARGV) != 2 && scalar(@ARGV) != 1) {
    print "Usage: ~ <file.csv> [with_header]\n";
    exit(1);
}

my($in);

if(scalar(@ARGV) == 2) {
    $in = Flat->new($ARGV[0], $ARGV[1]);
}
else { # == 1
    $in = Flat->new1($ARGV[0]);
}

while($in->readNextRow(1)) {
}

my($nrow) = $in->getNumOfRows();
my($ncol) = $in->getNumOfFields();
my $del = $in->getDelimiterStr();

print "# of columns = $ncol, # of rows = $nrow, delimiter=$del\n";
