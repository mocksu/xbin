#!/usr/bin/perl -w

# bin the input data file on the specified field, sum or concatenate other fields
if(scalar(@ARGV) != 3 && scalar(@ARGV) != 4) {
    print "Usage: ~ <input.csv> <field_index> <num_categories> [output.csv]\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($fldIndex) = $in->getFieldIndex($ARGV[1]);
my($numOfCat) = $ARGV[2];
my($out);

if(scalar(@ARGV) == 4) {
    $out = $ARGV[3];
}
else {
    $out = $ARGV[0];
}

if(!$in->fieldIsNumeric($fldIndex)) {
    die "Cannot discretize a discrete field $fldIndex\n";
}


my(@fldData) = $in->getColumnData($fldIndex);

# remove NaN entries 
my(@nanIndice);

for(my($i) = 0; $i < scalar(@fldData); $i++) {
    if(math::util::NaN($fldData[$i])) {
	push @nanIndice, $i;
    }
}

$in->removeRowsByIndice(@nanIndice);
@fldData = $in->getColumnData($fldIndex);

my(@ranks) = @{math::util::getRanks([@fldData])};
my($section) = (scalar(@ranks) + 0.001) / $numOfCat; # the length of each category
print "fldData size = ", scalar(@fldData), " rank size = ", scalar(@ranks), "\n";

print "section = $section, rank[0] = min rank = ", math::util::getMin(@ranks), " max rank = ", math::util::getMax(@ranks), "\n";
my(@data) = $in->getDataArray();

open OUT, "+>$out" || die $!;

print OUT Flat::dataRowToString($in->getFieldNames()), "\n";

# discretize @fldData
for(my($i) = 0; $i < scalar(@data); $i++) {
    $data[$i][$fldIndex] = int($ranks[$i] / $section);

    print OUT Flat::dataRowToString(@{$data[$i]}), "\n";
}

close OUT;

