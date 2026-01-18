#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("sC", \%options);

my $skipCheck = exists $options{"s"};

if((@ARGV) != 3) {
    print "\nUsage: ~ [-C] -s <input_file> <column_name[:rename])s_separatedby|> <result>\n\n";
    print "\t-C do not add comments to the result file\n";
    print "\t-s skip checking data integrity of the input file. Default is to check\n";
    exit(1);
}

my($inFile) = shift @ARGV;
my($re) = shift @ARGV;
my($outFile) = shift @ARGV;

my($in) = Flat->new1($inFile);
my $comments = $in->getComments();

# if field list two long, break it up
my @fldsInOrder = ();

while(length($re) > 100 && ($ind = index($re, "|")) != -1) {
    my @flds = split(/\|/, substr($re, 0, $ind));
#    my @flds = $in->getFieldIndice([@fldNames]);
    push @fldsInOrder, @flds;
    $re = substr($re, $ind+1);
}

if(length($re) > 0) {
    my @flds = split(/\|/, $re);
#    my @flds = $in->getFieldIndice([@fldNames]);
    push @fldsInOrder, @flds;
}

# prepare new fld names
my(@newFldNames); 

for($i = 0; $i < scalar(@fldsInOrder); $i++) {
    if($fldsInOrder[$i] =~ /:/) {
	($o, $n) = split(/:/, $fldsInOrder[$i]);
	$newFldNames[$i] = $n;
	$fldsInOrder[$i] = $in->getFieldIndex($o);
    }
    else {
	$newFldNames[$i] = $in->getFieldName($fldsInOrder[$i]);
	$fldsInOrder[$i] = $in->getFieldIndex($fldsInOrder[$i]);
    }
}

### write to file
# do not use the following line because it's not efficient enough
#$in->writeToFile("$outFile.tmp", [@fldsInOrder], $cmdLine, $skipCheck);

open OUT, "+>$outFile.tmp" or die $!;

if(!(exists $options{"C"})) {
    print OUT "# $comments";
    print OUT "# $cmdLine\n";
}

if($in->hasHeader()) {
    print OUT join("\t", @newFldNames), "\n";
}

while($row = $in->readNextRow($skipCheck)) {
    print OUT join("\t", map { $row->[$_] } @fldsInOrder), "\n";
}

close OUT;

Util::run("mv $outFile.tmp $outFile", 0);
