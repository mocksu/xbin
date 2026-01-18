#!/usr/bin/perl -w

use Util;
use math;
use Flat;

sub printUsage {
    print "Partition the fields in 'in.csv' into multiple fields with the specified common fields and 'nonCommonFldsPerPart' of fields\n";
    print "specified in 'orderedFieldsToPartition.csv'\n\n";
    print "  <in.csv> 'RE_common_flds' <orderedFieldsToPartition.csv> <fldsFld> <nonCommonFldsPerPart> <partStem>\n\n";
    print "  orderedSNPsToPartition.csv: does not contain header\n";
    print "  fldsFld: the name of the field in 'orderedFieldsToPartition.csv' that specifies ordered fields to partition\n";
    print "  nonCommonFldsPerPart: the number of fields from 'orderedFieldsToPartition.csv' per paritioned file\n\n";
    exit(1);
}

my $cmdLine = Util::getCmdLine();

if(scalar(@ARGV) != 6) {
    printUsage();
}

my $inFile = shift @ARGV;
my $in = Flat->new($inFile, 1);
my @commonFlds = @{$in->getFieldIndiceByRE(shift @ARGV)};
my $numOfFlds = $in->getNumOfColumns();
my @attrs = Flat->new(shift @ARGV, 1)->getColumnData(shift @ARGV);

my $partSize = shift @ARGV;
my $outStem = shift @ARGV;

# assign fields into part numbers
my %fld2part;
my $acount = 0;

foreach $a (@attrs) {
    my $i = $in->getFieldIndex($a);

    if($i == -1) {
	warn "$a does not exist in '$inFile'\n";
	next;
    }

    my $part = int($acount++/$partSize);
    $fld2part{$i} = $part;
    push @{$part2flds[$part]}, $i;
}

my $numOfParts = scalar(@part2flds);

my(%partNum2out);
map { $partNum2out{$_} = "OUT$_"; } (0..$numOfParts);
print "numOfParts = $numOfParts\n";

# create the partition files
for(my($i) = 0; $i < $numOfParts; $i++) {
    my $f = $partNum2out{$i};

    open $f, "+>$outStem.part$i.csv" or die "Cannot open $outStem.part$i.csv\n";
    print $f join("\t", map {$in->getFieldName($_) } (@commonFlds, @{$part2flds[$i]})), "\n";
}

# partition the data row by row
while($row = $in->readNextRow()) {
    my @commonData = map { $row->[$_]; } @commonFlds;

    for(my($i) = 0; $i < $numOfParts; $i++) {
	my @pdata = map { $row->[$_]; } @{$part2flds[$i]};
	my $f = $partNum2out{$i};
	print $f join("\t", @commonData, @pdata), "\n";
    }
}

# close the part files
for(my($i) = 0; $i < $numOfParts; $i++) {
    close $partNum2out{$i};
}
