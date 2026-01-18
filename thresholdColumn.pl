#!/usr/bin/perl -w

if(scalar(@ARGV) != 4 && scalar(@ARGV) != 6) {
    print "Threshold the specified field which has multi-values separated by comma.\n\n";
    print "Usage: ~ <in.csv> <min|max|median|mean|sum> <field_num> <threshold> [<above.csv> <below.csv>]\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($stats) = $ARGV[1];
my($fldNo) = $ARGV[2];
my($thold) = $ARGV[3];

my($above, $below);

if(scalar(@ARGV) == 6) {
    $above = $ARGV[4];
    $below = $ARGV[5];
}
else {
    my($stem) = $ARGV[0];
    $stem =~ s/\.csv$//;

    $above = "$stem.above.csv";
    $below = "$stem.below.csv";
}

open ABOVE, "+>$above" || die $!;
open BELOW, "+>$below" || die $!;

my(@data) = $in->getDataArray();
my($numOfFlds) = $in->getNumOfFields();
my(@fldNames) = $in->getFieldNames();

# print out fld names
print ABOVE Flat::dataRowToString(@fldNames), "\n";
print BELOW Flat::dataRowToString(@fldNames), "\n";

for(my($i) = 0; $i < scalar(@data); $i++) {
    my(@rowData) = @{$data[$i]};

    my(@fldVals) = split(/,/, $rowData[$fldNo]);
    my($statVal);

    if($stats eq 'min') {
	$statVal = math::util::getMin(@fldVals);
    }
    elsif($stats eq 'max') {
	$statVal = math::util::getMax(@fldVals);
    }
    elsif($stats eq 'median') {
	$statVal = math::util::getMedian(@fldVals);
    }
    elsif($stats eq 'sum') {
	$statVal = math::util::getSum(@fldVals);
    }
    else {
	die "statsColumn.pl: statistics not implemented: $stats\n";
    }

    if($statVal >= $thold) {
	print ABOVE Flat::dataRowToString(@rowData), "\n";
    }
    else {
	print BELOW Flat::dataRowToString(@rowData), "\n";
    }
}

close ABOVE;
close BELOW;

