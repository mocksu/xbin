#!/usr/bin/perl -w

if((@ARGV) != 3) {
    print "Get the rows with values in the specified field that are closest to the specified point\n";
    print "\nUsage: ~ <input_file>( <fld_index> <number>\n";
    print "         fld_index\ta numeric field of interest\n";
    print "         number\tthe point of interest\n\n";
    exit(1);
}

use Flat;
use Util;

my $cmdLine = Util::getCmdLine();

# read data from the file
my($in) = Flat->new1(shift @ARGV);
my $fld = $in->getFieldIndex(shift @ARGV);
my $num = shift @ARGV;

print "# $cmdLine > <this_file>\n";

my $cmt = $in->getComments();

if($cmt) {
    print "$cmt";
}

print join("\t", $in->getFieldNames()), "\n";

my @minRows = ();

my $row = $in->readNextRow();

my $minDist;

if($row) {
    $minDist = abs($num - $row->[$fld]);
    @minRows = ($row);
}

while($row = $in->readNextRow()) {
    $dist = abs($num - $row->[$fld]);

    if($dist < $minDist) {
	@minRows = ($row);
	$minDist = $dist;
    }
    elsif($dist == $minDist) {
	push @minRows, $row;
    }
    # else $dist > $minDist, skip
}

foreach $r (@minRows) {
    print join("\t", @{$r}), "\n";
}
