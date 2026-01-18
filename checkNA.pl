#!/usr/bin/perl -w

if(scalar(@ARGV) != 4) {
    print "Usage: ~ <in.csv> <idFld> <row NA limit> <col NA limit>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new(shift @ARGV, 1);
my(@fnames) = $in->getFieldNames();
my $idFld = $in->getFieldIndex(shift @ARGV);
my $rlimit = shift @ARGV;
my $climit = shift @ARGV;

my($out) = shift @ARGV;

# check the number of NA per row

my(@data) = $in->getDataArray();

my(%rowNA, %colNA);

for(my($i) = 0; $i < scalar(@data); $i++) {
    my $na = 0;

    for(my($j) = 0; $j < scalar(@fnames); $j++) {
	if($data[$i][$j] =~ /NA/i) {
	    $rowNA{$i}++;
	    $colNA{$j}++;
	}
    }
}

foreach $r (sort { $rowNA{$b} <=> $rowNA{$a} } keys %rowNA) {
    if($rowNA{$r} >= $rlimit) {
	print "row $data[$r][$idFld]: $rowNA{$r}\n";
    }
}

foreach $c (sort { $colNA{$b} <=> $colNA{$a} } keys %colNA) {
    if($colNA{$c} >= $climit) {
	print "col $fnames[$c]: $colNA{$c}\n";
    }
}
