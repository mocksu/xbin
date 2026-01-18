#!/usr/bin/perl -w

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> [<out.csv>]\n";
    exit(1);
}

use Flat;
use Util;

my($in) = Flat->new(shift @ARGV, 1);
my($out);

my(@fnames) = $in->getFieldNames();
my($inFile) = $in->getFileName();

if(scalar(@ARGV) > 0) {
    $out = shift @ARGV;
}
else {
    $out = $inFile;
}

undef $in;

my(%fldCounted);
my(@uniFlds);

my $rmCount = 0;

for(my($i) = 0; $i < scalar(@fnames); $i++) {
    if(exists $fldCounted{$fnames[$i]}) {
	print "Duplicated field $i: $fnames[$i]\n";
	$rmCount++;
	next;
    }
    else {
	push @uniFlds, $i;
	$fldCounted{$fnames[$i]} = 1;
    }
}

if($rmCount == 0) {
    print "There is no duplicated fields.\n";
}
else {
# run extractColumns.pl
    my($reFlds) = join("|", @uniFlds);
    
    Util::run("extractColumns.pl $inFile '$reFlds' $out.tmp", 1);
    Util::run("mv $out.tmp $out", 0);
    print "removed $rmCount fields\n";
}
