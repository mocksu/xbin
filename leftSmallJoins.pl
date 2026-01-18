#!/usr/bin/perl -w

use Util;
my $cmdLine = Util::getCmdLine();

use Getopt::Std;
my(%options);
getopts("uo", \%options);
my($overlapOnly) = $options{"o"};

my($unique) = 0;

if(exists $options{"u"}) {
    $unique = 1;
}

if(scalar(@ARGV) == 0 || scalar(@ARGV) < 5 || scalar(@ARGV) % 2 != 1) {
    print "       Like SQL left join. Duplicated entries on <file2.csv> will be all used in multiple rows\n\n";
    print "Usage: ~ [-u] -o <file1.csv> <\"fld1 ... fldn\"> <file2.csv> <\"Fld1 ... Fldn\"> ... <fileN> <\"fld1 ... fldn\"> <out.csv>\n\n";
    print "       -u\tThe entries in each file specified by the fields are unique [NOT IMPLEMENTED YET!!!]\n";
    print "       -o\tOverlap only. Entries in <file1.csv> that do not have matches in <file2.csv> will be ignored\n";
    print "       Note: in case of big files, put the bigger file in the second position will reduce memory usage\n";

    exit(1);
}

use Flat;

my($out) = pop @ARGV;
my($file1) = Flat->new1(shift @ARGV);
my $file1name = $file1->getFileName();
my(@fldNames1) = split(/\s+/, shift @ARGV);
my(@fldIndice1) = $file1->getFieldIndice([@fldNames1]);

while(scalar(@ARGV) > 0) {
    my @fldVals1 = $file1->getUniqueValues(@fldIndice1);
    my($file2) = Flat->new1(shift @ARGV);
    my $file2name = $file2->getFileName();
    my(@fldNames2) = split(/\s+/, shift @ARGV);
    my(@fldIndice2) = $file2->getFieldIndice([@fldNames2]);
    my(@fieldNames2) = map { $file2->getFieldName($_) } (@fldIndice2); # real names

    my(@fnames1);

    if($file1->hasHeader()) {
	@fnames1 = $file1->getFieldNames();
    }
    else {
	@fnames1 = map { "FIELD$_"; } (1..$file1->getNumOfFields());
    }
    
    print "processing file ", $file1->getFileName(), " and ", $file2->getFileName(), "\n";
    
# remove $fld2 so that it won't be printed
    my @allIndice2 = $file2->getFieldIndice();
    my %fldIndice2exists; map { $fldIndice2exists{$_} = 1; } @fldIndice2;
    my @newFldIndice2 = map { if(exists $fldIndice2exists{$_}) {;} else { $_; }} @allIndice2;

# read map filed2 => file2 entries
    my(%fld2entries) = $file2->getEntriesOfFieldValues([@fldIndice2],[@fldVals1]);

    my(@fnames2);

    if($file2->hasHeader()) {
	@fnames2 = map { $file2->getFieldName($_); } @newFldIndice2;
    }
    else {
	@fnames2 = map { "FIELD$_"; } (1..scalar(@newFldIndice2));
    }    
    
    open OUT, "+> $out.tmp" || die $!;
    print OUT "# $cmdLine\n";
    print OUT "# $file1name comments:\n";
    print OUT $file1->getComments();
    print OUT "# $file2name comments:\n";
    print OUT $file2->getComments();

# write field names
    my($dir1, $stem1, $suffix1) = Util::getDirStemSuffix($file1->getFileName());
    my($dir2, $stem2, $suffix2) = Util::getDirStemSuffix($file2->getFileName());
    
    print OUT join("\t", @fnames1, @fnames2), "\n";

    my $ocount = 0; # overlap count
    my $tcount = 0;
    my @entries = ();

    $file1->reset();

# write data entries
    while($row = $file1->readNextRow()) {
	$tcount++;
	my ($keyVal) = join(",", map { $row->[$_] } @fldIndice1);

	# figure out which entry to use based on the "stat"
	@entries = @{$fld2entries{$keyVal}};

	if(scalar(@entries) == 0) {
	    if(!$overlapOnly) {
		print OUT join("\t", @{$row});
		
		for(my($j) = 0; $j < scalar(@fnames2); $j++) {
		    print OUT "\tNA";
		}
		
		print OUT "\n";
	    }
	    # else overlap only, skip non-overlap entries
	}
	else {
	    $ocount++;

	    foreach $entry (@entries) {
		print OUT join("\t", @{$row}, map { $entry->[$_] } @newFldIndice2), "\n";;
	    }
	}
    }
    
    close OUT;
    
    Util::run("mv $out.tmp $out", 0);
 
    print "$ocount out of $tcount overlap found in $file2name\n";

    if(scalar(@ARGV) > 0) {
	$file1 = Flat->new($out, 1);
    }
}
