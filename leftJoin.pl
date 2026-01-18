#!/usr/bin/perl -w

if((@ARGV) != 7) {
    print "Usage: ~ <file1.csv> <field1_no> <file2.csv> <field2_no> <stat_field_no> <min|max|mean|mix|first|all> <out.csv>\n\n";
    print "Like SQL left join. Duplicates are handled by <min|max|mean|mix|all> on field <stat_field_no> of <file2.csv>\n\n";
    exit(1);
}

use Flat;

my($file1) = Flat->new($ARGV[0], 1);
my($fld1) = $file1->getFieldIndex($ARGV[1]);
my($file2) = Flat->new($ARGV[2], 1);
my($fld2) = $file2->getFieldIndex($ARGV[3]);
my($statFld) = $file2->getFieldIndex($ARGV[4]);
my($stat) = $ARGV[5];
my($out) = $ARGV[6];

my(@fnames1) = $file1->getFieldNames();
my(@data1) = $file1->getDataArray();

# read map filed2 => file2 entries
my(%fld2indice) = $file2->getIndiceOfFieldValues($fld2);
# remove $fld2 so that it won't be printed
$file2->removeFieldByName($fld2);
my(@data2) = $file2->getDataArray();
my(@fnames2) = $file2->getFieldNames();

# check which fields are numeric
my(%fld2IsNumeric);
for(my($i) = 0; $i < scalar(@fnames2); $i++) {
    $fld2IsNumeric{$i} = $file2->fieldIsNumeric($i);
}

my(@keys) = keys %fld2indice;

open OUT, "+> $out" || die $!;

# write field names
my($dir1, $stem1, $suffix1) = Util::getDirStemSuffix($file1->getFileName());
my($dir2, $stem2, $suffix2) = Util::getDirStemSuffix($file2->getFileName());

print OUT Flat::dataRowToString(@fnames1, @fnames2), "\n";

# write data entries
for(my($i) = 0; $i < scalar(@data1); $i++) {
    # figure out which entry to use based on the "stat"
    my(@entries) = ();

    if(exists $fld2indice{$data1[$i][$fld1]}) {
	my(@indice) = @{$fld2indice{$data1[$i][$fld1]}};
	@entries = map { $data2[$_]; } @indice;
    }

    if($stat eq 'all') {
	if(scalar(@entries) == 0) {
	    print OUT Flat::dataRowToString(@{$data1[$i]});

	    for(my($j) = 0; $j < scalar(@fnames2); $j++) {
		print OUT "\tNA";
	    }

	    print OUT "\n";
	}
	else {
	    foreach $entry (@entries) {
		print OUT Flat::dataRowToString(@{$data1[$i]}, @{$entry}), "\n";;
	    }
	}
    }
    else {
	print OUT Flat::dataRowToString(@{$data1[$i]});

	if(scalar(@entries) == 0) {
	    for(my($j) = 0; $j < scalar(@fnames2); $j++) {
		print OUT "\tNA";
	    }

	    print OUT "\n";
	}
	elsif($stat eq 'min' || $stat eq 'max' || $stat eq 'first') {
	    my(@statVals);    
	    map { push @statVals, $_->[$statFld]; } @entries;
	    my $index;

	    if($stat eq 'min') {
		$index = math::util::getMinIndex(@statVals);
	    }
	    elsif($stat eq 'max') { # 'max'
		$index = math::util::getMaxIndex(@statVals);
	    }
	    elsif($stat eq 'first') {
		$index = 0;
	    }
	    
	    print OUT "\t", Flat::dataRowToString(@{$entries[$index]}), "\n";
	}
	elsif($stat eq 'mean' || $stat eq 'mix') {
	    for(my($j) = 0; $j < (@fnames2); $j++) {
		my(@statVals);
		
		map { 
		    push @statVals, $_->[$j];
		} @entries;
		
		my($fdata);
		
		if($stat eq 'mix' || !$fld2IsNumeric{$j}) {
		    $fdata = $statVals[0];
		    
		    for(my($k) = 1; $k < scalar(@statVals); $k++) {
			$fdata .= ",$statVals[$k]";
		    }
		}
		elsif($stat eq 'mean' && $fld2IsNumeric{$j}) {
		    $fdata = math::util::getMean(@statVals);
		}
		else { # unknown stat method
		    Util::dieIt("Unknown stat: $stat. fldIsNumeric = $fld2IsNumeric{$j}\n");
		  }
		
		print OUT "\t$fdata";
	    }

	    print OUT "\n";
	}
	else {
	    Util::dieIt("Unknown stat: $stat.\n");
	  }
    }
}

close OUT;
