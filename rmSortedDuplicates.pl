#!/usr/bin/perl -w

if(scalar(@ARGV) < 2) {
    print "\Remove duplicated rows. Assuming the input file is sorted on the dup_fld's\n\n";
    print "\nUsage: ~ [-s <stat_fld_index> <max|min|median|first|mean|mix|sum|sd|VALUE_RE|!~ /VALUE_RE/>] <input.csv> [<dup_fld_index1> ... <dup_fld_indexn>] <out.csv>\n\n";
    print "\tfld_index is 0 based\n";
    print "\tVALUE -- keep the entry with the specified value; keep all if none is found\n\n";
    exit(1);
}

# read data from the file
use Flat;

use Getopt::Std;
my(%options);
getopts("s:", \%options);
my($statFld) = $options{"s"};
my($stat, $statFldNo);

if($statFld) {
    $stat = shift @ARGV;
}
else {
    $stat = "first";
}

my($in) = Flat->new1(shift @ARGV);

if($statFld) {
    $statFldNo = $in->getFieldIndex($statFld);
}
else {
    $statFldNo = -1;
}

my($numFlds) = $in->getNumOfFields();

my($out) = pop @ARGV;
open OUT, "+>$out" || die $!;

my(@dupFldNums);

if(scalar(@ARGV) == 0) {
    my($maxIndex) = $numFlds - 1;
    @dupFldNums = $in->getFieldIndice(["0-$maxIndex"], 1);
}
else {
    @dupFldNums = $in->getFieldIndice([@ARGV], 1);
}

my(@fldNames) = $in->getFieldNames();
my(%key2rows);

# read the first row
my($row) = $in->getNextRow();
my $keyVals = join(",", map { $row->[$_] } @dupFldNums);
push @{$key2rows{$keyVals}}, $row;

while($row = $in->getNextRow()) {
    $keyVals = join(",", map { $row->[$_] } @dupFldNums);
    
    if(exists $key2rows{$keyVals}) {
	push @{$key2rows{$keyVals}}, $row;
    }
    else { # previous key done, process them
	my @rows = values %key2rows;
	my @fdata = map { $_->[$statFldNo] } @rows;
	
	if($stat eq 'min' || $stat eq 'max' || $stat eq 'first' || $stat eq 'median') { # pick one entry 
	    my($sindex, $sval);

	    if($stat eq 'first') {
		$sindex = 0;
	    
		@rowData = @{$rows[0]};
	    }
	    else { # numeric handling
		# get numeric data only
		my(@ndata, @nindice);
	    
		for(my($k) = 0; $k < scalar(@fdata); $k++) {
		    if(!math::util::NaN($fdata[$k])) {
			push @ndata, $fdata[$k];
			push @nindice, $indice[$k];
		    }
		}
		
		if($stat eq 'min') {
		    $sindex = math::util::getMinIndex(@ndata);
		    $sval = $ndata[$sindex];
		}
		elsif($stat eq 'max') {
		    $sindex = math::util::getMaxIndex(@ndata);
		    $sval = $ndata[$sindex];
		}
		elsif($stat eq 'median') {
		    $sindex = math::util::getMedianIndex(@ndata);
		    $sval = $ndata[$sindex];
		}
		
		@rowData = @{$rows[$nindice[$sindex]]};
		$rowData[$statFldNo] = $sval;
	    }
	}
	else { # VALUE option, multiple entries may be kept
	    my($matching) = 1;
	    my($stat1) = $stat;

	    if($stat =~ /^\!~/) { # not pattern
		$matching = 0;
		($stat1) = ($stat =~ /^\!\~\s+(.+)/);
	    }

	    my($valFound) = 0;

	    for(my($s) = 0; $s < scalar(@{$dupRows[0]}); $s++) {
		if(($matching && $dupRows[$statFldNo][$s] =~ /$stat1/) ||
		   (!$matching && $dupRows[$statFldNo][$s] !~ /$stat1/)) {
		    if(scalar(@indice) > 1) {
#			print "found for dval: $dval of size ", scalar(@indice), ": ", @{$dupRows[$statFldNo]}, "\n";
		    }

		    $valFound = 1;
		    print OUT Flat::dataRowToString(@{$data[$indice[$s]]}), "\n";
		}
	    }

	    if(!$valFound) { # not found, print out every entry
		foreach $ind (@indice) {
		    print OUT Flat::dataRowToString(@{$data[$ind]}), "\n";
		}
	    }

	    next; # skip the following printing
	}
    }
    else { # either aggregate statistics or dynamic index for each column, the stat field is not used
	for(my($i) = 0; $i < $numFlds; $i++) {
	    my($isNumeric) = 1;

	    map { if(math::util::isVirtuallyNaN($_)) { $isNumeric = 0;}} @{$dupRows[$i]};

	    if($stat eq 'first') {
		$rowData[$i] = $dupRows[$i][0];
	    }
	    elsif($stat eq 'mix' || !$in->fieldIsNumeric($i) || !$isNumeric) {
		$rowData[$i] = $dupRows[$i][0];

		for(my($j) = 1; $j < scalar(@indice); $j++) {
		    $rowData[$i] .= ",$dupRows[$i][$j]";
		}
	    }
	    elsif($stat eq 'mean') {
		$rowData[$i] = math::util::getMean(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'sum') { # sum
		$rowData[$i] = math::util::getSum(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'sd') { # sd
		$rowData[$i] = math::util::getSD(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'min') {
		$rowData[$i] = math::util::getMin(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'max') {
		$rowData[$i] = math::util::getMax(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'median') {
		$rowData[$i] = math::util::getMedian(@{$dupRows[$i]});
	    }
	    else {
		die "Unknown stats: $stat\n";
	    }
	}
    }

    print OUT Flat::dataRowToString(@rowData), "\n";
}

close OUT;
