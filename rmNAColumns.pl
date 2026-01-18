#!/usr/bin/perl -w

if(scalar(@ARGV) != 2) {
    print "Remove columns with only 'NA' values\n";
    print "Usage: ~ <in.csv> <out.csv>\n";
    exit(1);
}

use Flat;

my $inFile = shift @ARGV;
my($in) = Flat->new1($inFile);
my($out) = shift @ARGV;

my @rmFlds;
my $numFlds = $in->getNumOfFields();

for(my($i) = 0; $i < $numFlds; $i++) {
    $in->reset();

    @uvals = $in->getUniqueValues($i);

    if(scalar(@uvals) == 1 && $uvals[0] eq "NA") {
	push @rmFlds, $i;
	
	if($in->hasHeader()) {
	    print "removing ", $in->getFieldName($i), "\n";
	}
	else {
	    print "removing field $i\n";
	}
    }
    # else not a all "NA" field
}

if(scalar(@rmFlds) > 0) {
    Util::run("rmColumns.pl $inFile '".join("|", @rmFlds)."' $out", 1);
  }
else {
    print "No fields removed\n";
}
