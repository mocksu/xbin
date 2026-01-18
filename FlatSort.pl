#!/usr/bin/perl -w

my $resort = "";

for(my($i) = 0; $i < scalar(@ARGV); $i++) {
    if($ARGV[$i] =~/\-r/) {
	$resort = "-r";
	splice @ARGV, $i, 1;
	last;
    }
}

if(scalar(@ARGV) != 3) {
    print "Usage: ~ [-r] <unix_sort_options> <in.csv> <out.csv>\n";
    print "       -r\tresort the input file\n";
    exit(1);
}

use Flat;

my($opt) = shift @ARGV;
my($in) = Flat->new1(shift @ARGV);
my($out) = shift @ARGV;

if(!$resort && (-e $out) && ($in->getNumOfRows() == Flat->new1($out)->getNumOfRows())) {
    print $in->getFileName(), " is sorted already. Do nothing.\n";
    exit(0);
}

if($in->hasHeader()) {
    my($inTmp) = $in->getFileName().".insort_tmp";
    my($outTmp) = "$out.outsort_tmp";
    
    open INTMP, "+>$inTmp" or die $!;
    
    # throw away header
    while($row = $in->readNextRow()) {
	print INTMP join("\t", @{$row}), "\n";
    }
    
    close INTMP;
    
    Util::run("sort -t \"	\" $opt $inTmp > $outTmp", 1);
    
    my(@fnames) = $in->getFieldNames();
    
    open OUT, "+>$out.tmp" or die $!;

    print OUT join("\t", @fnames), "\n";

    my $otmp = Flat->new($outTmp, 0);

    while($row = $otmp->readNextRow()) {
	print OUT join("\t", @{$row}), "\n";
    }

    close OUT;

    `rm $inTmp $outTmp`;
}
else {
    Util::run("sort $opt ".$in->getFileName()." > $out.tmp", 0);
  }

`mv $out.tmp $out`;
