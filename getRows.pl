#!/usr/bin/perl -w

if((@ARGV) < 2 || scalar(@ARGV) % 2 != 1) {
    print "\nUsage: ~ <input_file>( <fld_index> <re_ptn>)+\n\n";
    print "         fld_index is 0 based\n\n";
    exit(1);
}

use Flat;
use Util;

my $cmdLine = Util::getCmdLine();

# read data from the file
my($in) = $ARGV[0];
my($inFile) = Flat->new1($in);

my(%fld2ptn);

for(my($i) = 1; $i < scalar(@ARGV); $i += 2) {
    $fld2ptn{$inFile->getFieldIndex($ARGV[$i], 1)} = $ARGV[$i + 1];
}

my(@fldIndex) = sort keys %fld2ptn;

print "# $cmdLine > <this_file>\n";

my $cmt = $inFile->getComments();

if($cmt) {
    print "$cmt";
}

print join("\t", $inFile->getFieldNames()), "\n";

while($line = $inFile->readNextRow()) {
    my @row = @{$line};
    my($match) = 1;

    for(my($i) = 0; $i < scalar(@fldIndex); $i++) {
	if($row[$fldIndex[$i]] !~ $fld2ptn{$fldIndex[$i]}) {
	    $match = 0;
	    last;
	}
    }

    if($match) {
	print join("\t", @row), "\n";
    }
    # else ignore
}

