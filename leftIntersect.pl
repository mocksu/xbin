#!/usr/bin/perl -w

if((@ARGV) != 5) {
    print "Usage: ~ <file1.csv> <\"field1 field2 ... fieldn\"> <file2.csv> <\"Field1 Field2 ... Fieldn\"> <out.csv>\n\n";
    print "Keep rows in <file1.csv> that have matching rows in <file2.csv> with the specified fields\n";
    print "Fields in <file2.csv> are not recorded in the <out.csv>\n\n";
    exit(1);
}

use Flat;

my($file1) = Flat->new($ARGV[0], 1);
my(@fldNames1) = split(/\s+/, $ARGV[1]);
my(@fldIndice1) = $file1->getFieldIndice([@fldNames1]);
my($file2) = Flat->new($ARGV[2], 1);
my(@fldNames2) = split(/\s+/, $ARGV[3]);
my(@fldIndice2) = $file2->getFieldIndice([@fldNames2]);
my(@fieldNames2) = map { $file2->getFieldName($_) } (@fldIndice2); # real names

my($out) = $ARGV[4];

my(@fnames1) = $file1->getFieldNames();
my(@data1) = $file1->getDataArray();

# read map filed2 => file2 entries
my(%fld2indice) = $file2->getIndiceOfFieldValues(@fldIndice2);
# remove $fld2 so that it won't be printed
map { $file2->removeFieldByName($_); } @fieldNames2;

my(@data2) = $file2->getDataArray();
my(@fnames2) = $file2->getFieldNames();

my(@keys) = keys %fld2indice;

open OUT, "+> $out" || die $!;

# write field names
my($dir1, $stem1, $suffix1) = Util::getDirStemSuffix($file1->getFileName());
my($dir2, $stem2, $suffix2) = Util::getDirStemSuffix($file2->getFileName());

print OUT Flat::dataRowToString(@fnames1), "\n";

# write data entries
for(my($i) = 0; $i < scalar(@data1); $i++) {
    my ($keyVal) = join(",", map { $data1[$i][$_] } @fldIndice1);

    # figure out which entry to use based on the "stat"
    my(@entries) = ();

    if(exists $fld2indice{$keyVal}) {
	my(@indice) = @{$fld2indice{$keyVal}};
	@entries = map { $data2[$_]; } @indice;
    }

    if(scalar(@entries) == 0) { # if no matching rows in the 2nd file
	# skip the rows
    }
    else {
	print OUT Flat::dataRowToString(@{$data1[$i]}), "\n";;
    }
}

close OUT;
