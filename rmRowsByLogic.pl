#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "Remove the rows which returns true for the specified operation\n";
    print "\nUsage: ~ <in.csv> <operation> <fld1> ... <fldn> <removed.csv> <retained.csv>\n\n";
    print "         e.g. ~ /tmp/t.csv '\"$arr[0]:$arr[1]\"' 9 10 /tmp/t1.csv\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $cmdLine = Util::getCmdLine();

my($inFile) = shift @ARGV;
my $retained = pop @ARGV;
my($removed) = pop @ARGV;
my($op) = shift @ARGV;
my $in = Flat->new1($inFile);

my(@flds) = $in->getFieldIndice([@ARGV], 1);

open REM, "+>$removed" or die "Cannot open $removed\n";
print REM "# $cmdLine; removed\n";
print REM join("\t", $in->getFieldNames()), "\n";

open RET, "+>$retained" or die $!;
print RET "# $cmdLine; retained\n";
print RET join("\t", $in->getFieldNames()), "\n";

my($single) = scalar(@flds) > 1? 0:1;

my($operation) = $op;

if($single) {
    $operation =~ s/__/\$arr[0]/g;
}
else { # multiple
    $operation =~ s/__/\@arr/g;
}

while($row = $in->readNextRow()) {
    my(@arr) = map { $row->[$_]; } @flds;

    if(eval($operation)) {
	print REM join("\t", @{$row}), "\n";
    }
    else {
	print RET join("\t", @{$row}), "\n";
    }
}

close REM;
close RET;

