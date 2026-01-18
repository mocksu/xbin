#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "Usage: ~ <in.csv> [<min|max|median|mean|sum|unique> <field_num>]+ <out.csv>\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1($ARGV[0]);
my($out) = $ARGV[scalar(@ARGV) - 1];

my(%fld2stat);

for(my($i) = 1; $i < scalar(@ARGV) - 1; $i += 2) {
    $fld2stat{$ARGV[$i + 1]} = $ARGV[$i];
}

open OUT, "+>$out" || die $!;

my(@data) = $in->getDataArray();
my($numOfFlds) = $in->getNumOfFields();
my(@fldNames) = $in->getFieldNames();

# print out fld names
if(scalar(@fldNames) > 0) {
    print OUT $fldNames[0];

    for(my($i) = 1; $i < scalar(@fldNames); $i++) {
	if(exists $fld2stat{$i}) {
	    print OUT "\t$fldNames[$i]".$fld2stat{$i};
	}
	else {
	    print OUT "\t$fldNames[$i]";
	}
    }

    print OUT "\n";
}

for(my($i) = 0; $i < scalar(@data); $i++) {
    my(@rowData) = @{$data[$i]};

    print OUT $rowData[0];

    # print stat data
    for(my($j) = 1; $j < $numOfFlds; $j++) {
	if(exists $fld2stat{$j}) {
	    my($stats) = $fld2stat{$j};
	    # get stat index
	    my(@fldVals) = split(/,/, $rowData[$j]);
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
	    elsif($stats eq 'unique') {
		my(%in);

		$statVal = $fldVals[0];
		$in{$fldVals[0]} = 1;

		for(my($i) = 1; $i < scalar(@fldVals); $i++) {
		    if(exists $in{$fldVals[$i]}) {
			# skip
		    }
		    else {
			$statVal .= ",$fldVals[$i]";
			$in{$fldVals[$i]} = 1;
		    }
		}
	    }
	    else {
		die "statsColumn.pl: statistics not implemented: $stats\n";
	    }

	    print OUT "\t$statVal";
	}
	else {
	    print OUT "\t$rowData[$j]";
	}
    }

    print OUT "\n";

}

close OUT;
