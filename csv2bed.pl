#!/usr/bin/perl -w

# convert csv format to bed format
if((@ARGV) != 2 && scalar(@ARGV) != 1) {
    die "Usage: ~ <data.csv> [<out.bed>]\n";
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
my(@data) = $in->getDataArray();
my($numOfFlds) = $in->getNumOfFields();

my($out);

if(scalar(@ARGV) == 2) {
    $out = $ARGV[1];
}
else {
    $out = $ARGV[0];
    $out =~ s/\.csv$/\.bed/;
}

open OUT, "+>$out" || die $!;

for(my($j) = 0; $j < scalar(@data); $j++) {
    my $d = $data[$j];

    if($d->[0] =~ /^chr/) {
	# keep the original notation
    }
    elsif($d->[0] eq '23') {
	$d->[0] = "chrX";
    }
    elsif($d->[0] eq '24') {
	$d->[0] = "chrY";
    }
    else {
	$d->[0] = "chr$d->[0]";
    }

    # order start < end
    my($start, $end) = ($d->[1], $d->[2]);

    if($start > $end) {
	($start, $end) = ($end, $start);
    }

    # chr1 100 200 name score strand
    print OUT "$d->[0]\t$start\t$end\tname$j\t1\t$d->[3]";
    
    for(my($i) = 4; $i < $numOfFlds; $i++) {
	print OUT "\t$d->[$i]";
    }

    print OUT "\n";
}

close OUT;
