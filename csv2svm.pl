#!/usr/bin/perl -w

use Getopt::Std;
my(%options);
getopts("r:", \%options);
my(%sym2num);

if(exists $options{"r"}) {
  map { my($sym, $num) = split(/:/, $_); $sym2num{$sym} = $num; } split(/\s+/, $options{"r"});
}

if(scalar(@ARGV) < 4) {
    print "Usage: ~ [-r \"labelVal1:numVal1 labelVal2:numVal2 ...\"] <in.csv> <out.csv> <label_fld> <predictor_fld1> ... <predictor_fldn>\n";
    exit(1);
}

use Flat;
use math;

my($in) = Flat->new1(shift @ARGV);
my($out) = shift @ARGV;

my($lfld) = $in->getFieldIndex(shift @ARGV);
my(@pflds) = map { $in->getFieldIndex($_) } @ARGV;

#check to see if all fields specified are numeric 
foreach $f ($lfld, @pflds) {
    if($in->fieldIsNumeric($f)) {
	next;
    }
    else {
	warn "converting field $f (", $in->getFieldName($f), ") from non numeric to be numeric\n";
	$in->digitizeField($f, \%sym2num);
    }
}

my(@data) = $in->getDataArray();

open OUT, "+>$out" or die $!;

for(my($i) = 0; $i < scalar(@data); $i++) {
    # skip rows containing non numeric values
    my $skip = 0;
    foreach $f ($lfld, @pflds) {
	if(math::util::isNaN($data[$i][$f])) {
	    $skip = 1;
	    last;
	}
    }

    if($skip) {
	next;
    }

    print OUT $data[$i][$lfld];

    for(my($j) = 0; $j < scalar(@pflds); $j++) {
	print OUT " ", $j + 1, ":$data[$i][$pflds[$j]]";
    }

    print OUT "\n";
}

close OUT;
