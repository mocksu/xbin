#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("s:", \%options);
my($statFld);

if(exists  $options{"s"}) {
    $statFld = $options{"s"};
}
else {
    printUsage();
}

if(scalar(@ARGV) != 4) {
    printUsage();
}

sub printUsage {
print "\nUsage: ~ -s <stat_fld_index> <max|min|median|first|mean|mix|sum|sd|VALUE_RE|!~ /VALUE_RE/> <input.csv> \"<dup_fld_index1>|...|<dup_fld_indexn>\" <out.csv>\n\n";
    print "\tfld_index is 0 based\n";
    print "\tVALUE -- keep the entry with the specified value; keep all if none is found\n\n";
    exit(1);
}

my($stat) = shift @ARGV;

# read data from the file
use Flat;

my($in) = Flat->new1(shift @ARGV);
my $statFldNo;

if($statFld) {
    $statFldNo = $in->getFieldIndex($statFld);
}
else {
    $statFldNo = -1;
}

my(@dupFldNums) = $in->getFieldIndice([split(/\|/, shift @ARGV)]);

my($out) = pop @ARGV;

my $numFlds = $in->getNumOfFields();
my(@fldNames) = $in->getFieldNames();
my(@data) = $in->getDataArray();

open OUT, "+>$out.tmp" || die $!;

if($in->hasHeader()) {
    my @fnames = @fldNames;
    
    if($statFldNo != -1) {
	$fnames[$statFldNo] = uc($stat)."_".$fldNames[$statFldNo];
    }

    print OUT Flat::dataRowToString(@fnames), "\n";
}

my(%dval2indice) = $in->getIndiceOfFieldValues(@dupFldNums);

foreach $dval (sort {$dval2indice{$a}->[0] <=> $dval2indice{$b}->[0]} keys %dval2indice) {
    my(@indice) = @{$dval2indice{$dval}};
    my(@dupRows);

    for(my($i) = 0; $i < $numFlds; $i++) {
	for(my($j) = 0; $j < scalar(@indice); $j++) {
	    $dupRows[$i][$j] = $data[$indice[$j]][$i];
	}
    }

    my(@rowData);

    if($statFldNo != -1) { # stat applying to a specific field
	if($stat eq 'min' || $stat eq 'max' || $stat eq 'first' || $stat eq 'median') { # pick one entry 
	    my($sindex, $sval);

	    if($stat eq 'first') {
		$sindex = 0;
	    
		@rowData = @{$data[$indice[$sindex]]};
	    }
	    else { # numeric handling
		my(@fdata) = @{$dupRows[$statFldNo]};

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
		else {
		    die "$stat not handled\n";
		}

		@rowData = @{$data[$nindice[$sindex]]};
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
		my @colData = math::util::getUniqueElements(@{$dupRows[$i]});
		$rowData[$i] = $colData[0];

		for(my($j) = 1; $j < scalar(@colData); $j++) {
		    $rowData[$i] .= ",$colData[$j]";
		}
	    }
	    elsif($stat eq 'mean') {
		$rowData[$i] = math::util::getMean(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'sum') { # sum
		$rowData[$i] = math::util::getSum(@{$dupRows[$i]});
	    }
	    elsif($stat eq 'sd') { # sd
		$rowData[$i] = math::util::getStandardDeviation(@{$dupRows[$i]});
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

`mv $out.tmp $out`;
