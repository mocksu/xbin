#!/usr/bin/perl -w

if((@ARGV) != 2 && (@ARGV) != 3) {
    print "\nUsage: ~ <input_file> <field1|field2|...> [<result>]\n\n";
    exit(1);
}

use Flat;
use math;
use Util;

my $cmdLine = Util::getCmdLine();

my($in) = Flat->new1(shift @ARGV);
my($fldRE) = shift @ARGV;
my($out);

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in->getFileName();
}

my(@indice) = $in->getFieldIndice([split(/\|/, $fldRE)]);
#die "indice = @indice\n";

#my $tmp = Util::shortenName($out.join("_", @indice), 80);
my $tmp = "$out.tmp";

open OUT, "+>$tmp" or die $!;
print OUT "# $cmdLine\n";
my $cmts = $in->getComments();
print OUT $cmts;

my(%index2rm);
map { $index2rm{$_} = 1; } @indice;
my @indice2keep;

my $numOfFlds = $in->getNumOfFields();

my @fldNames;
my @newFnames;

if($in->hasHeader()) {
    @fldNames = $in->getFieldNames();
}

for(my($i) = 0; $i < $numOfFlds; $i++) {
    if(!$index2rm{$i}) {
	if($in->hasHeader()) {
	    push @newFnames, $fldNames[$i];
	}

	push @indice2keep, $i;
    }
}

if($in->hasHeader()) {
    print OUT join("\t", @newFnames), "\n";
}

my $numFlds2keep = scalar(@indice2keep);

while($row = $in->readNextRow()) {
    my(@newRow);

    for(my($i) = 0; $i < $numFlds2keep; $i++) {
	$newRow[$i] = $row->[$indice2keep[$i]];
    }

    print OUT join("\t", @newRow), "\n";
    undef @newRow;
    undef $row;
}

close OUT;

`mv $tmp $out`;
