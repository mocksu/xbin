#!/usr/bin/perl -w

if(scalar(@ARGV) < 4) {
    print "For each numeric field in the specified file excluding the categorical field, compute the specified statistics\n\n";
    print "Usage: ~ <in.csv> <'catFld1|...|catFldN'> <min|max|mean|median|sum|std|ci> <out.csv>\n\n";
    print "\tci: 95% confidence interval (half interval)\n";
    print "\tstatistics can be a combination of different attributes such as mean and std\n\n";
    exit(1);
}

use Flat;
use math;

my $in = Flat->new1(shift @ARGV);
my @catFlds = $in->getFieldIndice([split(/\|/, shift @ARGV)]);
my($out) = pop @ARGV;
my @stats = @ARGV;

my %isNumeric; # numeric fields
my @fldIndice = $in->getFieldIndice();

my @fldNames = $in->getVirtualFieldNames();

foreach $f (@fldIndice) {
    if($in->fieldIsNumeric($f)) {
	$isNumeric{$in->getFieldIndex($f)} = 1;
    }
}

my %catFlds2fldVals; # category + fld index => fld values
$in->reset();

while($row = $in->readNextRow()) {
    my $keyVal = join(",", map { $row->[$_]; } @catFlds);

    map { push @{$catFlds2fldVals{$keyVal}{$_}}, $row->[$_];} @fldIndice;
}

undef $in;

open OUT, "+>$out" or die $!;

my @newFldNames;

foreach $s (@stats) {
    foreach $fn (@fldNames) {
	push @newFldNames, "$fn.$s";
    }
}

print OUT join("\t", "SAMPLE_SIZE", @newFldNames), "\n";

my $sortOpt = "\$a <=> \$b";

map { if(math::util::isNaN($_)) { $sortOpt = "\$a cmp \$b"; } } keys %catFlds2fldVals;

foreach $cat (sort { eval($sortOpt) }  keys %catFlds2fldVals) {
    my @newFldVals;

    push @newFldVals, scalar(@{$catFlds2fldVals{$cat}{0}});

    foreach $s (@stats) {
	for(my($i) = 0; $i < scalar(@fldIndice); $i++) {
	    my(@fldVals) = @{$catFlds2fldVals{$cat}{$i}};
	    my $isCatFld = 0;
	    map { if($i == $_) { $isCatFld = 1; } } @catFlds;

	    if($isCatFld) {
		push @newFldVals, $fldVals[0];
	    }
	    elsif(math::util::isArrayNumeric(@fldVals)) { # if it's a numeric field
		@fldVals = math::util::rmNaN(@fldVals);
		my $statVal;
		
		if($s eq "min") {
		    $statVal = math::util::getMin(@fldVals);
		}
		elsif($s eq "max") {
		    $statVal = math::util::getMax(@fldVals);
		}
		elsif($s eq "mean") {
		    $statVal = math::util::getMean(@fldVals);
		}
		elsif($s eq "median") {
		    $statVal = math::util::getMedian(@fldVals);
		}
		elsif($s eq "std") {
		    $statVal = math::util::getStandardDeviation(@fldVals);
		}
		elsif($s eq "ci") {
		    $statVal = math::util::getConfidenceInterval(@fldVals);
		}
		elsif($s eq "sum") {
		    $statVal = math::util::getSum(@fldVals);
		}
		else {
		    Util::dieIt("Unknown statistics '$s'\n");
		  }
		
		push @newFldVals, $statVal;
	    }
	    else { # a non-numeric field, use it directly
		push @newFldVals, join(",", Util::getUniqueElements(@fldVals));
	    }
	}
    }

    print OUT join("\t", @newFldVals), "\n";
}

close OUT;
