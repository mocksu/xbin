#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "Create Borad Institute .gct and .cls files from the input file in per sample per row format\n\n";
    print "Usage: ~ <data.csv> <classFld> <sampleIDFld> <pred1> ... <predN> <outStem>\n";
    exit(1);
}

# add a column after the first column

use Flat;

my($in) = Flat->new(shift @ARGV, 1);
my $cFld = $in->getFieldIndex(shift @ARGV);
my $sFld = $in->getFieldIndex(shift @ARGV);

my($outStem) = pop @ARGV;
my(@predIndice) = $in->getFieldIndice([@ARGV]);

my @fnames = $in->getFieldNames();
my @sampleNames = $in->getColumnData($sFld);

# create .cls file
my $cls = "$outStem.cls";
open CLS, "+>$cls" or die "Cannot open $cls\n";
my @cVals = $in->getColumnData($cFld);
my @ucVals = sort $in->getUniqueValues($cFld);
print CLS join("\t", scalar(@sampleNames), scalar(@ucVals), 1), "\n";
print CLS join(" ", "#", @ucVals), "\n";
my @ncVals; # numeric class values
map {  
    my $found = 0;

   for(my($i) = 0; $i < scalar(@ucVals); $i++) {
	if($_ eq $ucVals[$i]) {
	    $found = 1;
	    push @ncVals, $i;
	}
	# else check next
    }

    if(!$found) {
	die "Cannot find class $_: ucVals = @ucVals\n";
    }
} @cVals;

print CLS join(" ", @ncVals), "\n";

close CLS;

# create .gct file
my $gct = "$outStem.gct";
open GCT, "+>$gct" or die "Cannot open $gct\n";

print GCT "#1.2\n";
print GCT scalar(@predIndice), "\t", $in->getNumOfRows(), "\n";
print GCT join("\t", "NAME", "Description", @sampleNames), "\n";

for(my($i) = 0; $i < scalar(@predIndice); $i++) {
    my $pindex = $predIndice[$i];
    my @colData = $in->getColumnData($pindex);
    
    print GCT join("\t", $fnames[$pindex], $fnames[$pindex], @colData), "\n";
}

close GCT;
