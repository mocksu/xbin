#!/usr/bin/perl -w

if((@ARGV) != 3) {
    print "Usage: ~ <file1.csv> <file2.csv> <out.csv>\n\n";
    print "Get the overlap portion of <file2.csv> with <file1.csv> and put the results in <out.csv>\n";
    print "It is more like \"left join\" in SQL\n";
    print "Each line in <filen.csv> is formatted as:\n\n";
    print "<chr_n> <start> <end> <val>\n\n";
    print "<filen.csv> does not have to be sorted\n";
    exit(1);
}

use Flat;
use sequence::SeqUtil;

my($file1) = Flat->new1($ARGV[0]);
my(@fnames1) = $file1->getFieldNames();
my(@data1) = sort sequence::SeqUtil::byCoords $file1->getDataArray();
my($file2) = Flat->new1($ARGV[1]);
my(@data2) = sort sequence::SeqUtil::byCoords $file2->getDataArray();
my(@intersect) = sequence::SeqUtil::intersect(\@data1, \@data2);

open OUT, "+> $ARGV[2]" || die $!;

for(my($i) = 0; $i < (@fnames1); $i++) {
    print OUT $file1->getFileName(), ":$fnames1[$i]\t";
}

print OUT $file1->getFileName(), ":", $file2->getFileName(), ":length_overlap\t",
    $file1->getFileName(), ":", $file2->getFileName(), ":intensity_overlap\n";

for(my($i) = 0; $i < scalar(@intersect); $i++) {
    for(my($j) = 0; $j < (@{$data1[$i]}); $j++) {
	print OUT $data1[$i][$j], "\t";
    }

    print OUT $intersect[$i][0], "\t$intersect[$i][1]\n";
}

close OUT;

sub intersect_deprecated {
    my($data1, $data2) = @_;

    my(@d1) = @{$data1}; 
    my(@d2) = @{$data2};
    my(@result);

    my($sindex) = 0; # start index of the sorted @data2

    for(my($i) = 0; $i < scalar(@d1); $i++) {
	$result[$i][0] = 0;
	$result[$i][1] = 0;

	my($met) = 0;

	if($i % 100 == 0) {
	    print "checking $i...\n";
	}

	for(my($j) = $sindex; $j < scalar(@d2); $j++) {
	    if($overlap = sequence::SeqUtil::getOverlap($d1[$i], $d2[$j])) {
		if(!$met) {
		    $sindex = $j;
		    $met = 1;
		}

		$result[$i][0] += $d2[$j]->[3] * $overlap/($d2[$j][2] - $d2[$j][1] + 1);
		$result[$i][1] += $overlap;
	    }
	    elsif($met) {
#		print "overlap ended at $j\n";
		last;
	    }
	}
    }

    return @result;
}
