#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "Usage: ~ <in.csv> <out.csv> <fld1> ... <fldN>\n";
    exit(1);
}

use Flat;
use Util;

my($in) = Flat->new(shift @ARGV, 1);
my($out) = shift @ARGV;
my @flds2guess = $in->getFieldIndice([@ARGV]);

my(@fnames) = $in->getFieldNames();
my %fldVal2count;

while($row = $in->readNextRow()) {
    map {$fldVal2count{$_}{$row->[$_]}++; } @flds2guess;
}

my (%fld2vals, %fld2probs);
my %flds2rm; # fields to remove for lack of real data

foreach $f (@flds2guess) {
    # remove "NA" values
    delete $fldVal2count{$f}{"NA"};

    # get the field values and the probs
    @{$fld2vals{$f}} = keys %{$fldVal2count{$f}};

    if(scalar@{$fld2vals{$f}} == 0) {
	$flds2rm{$f} = 1;
	print "fld $fnames[$f] has no real data\n";
    }

    @counts = map { $fldVal2count{$f}{$_}; } @{$fld2vals{$f}};
    $total = math::util::getSum(@counts);
    @{$fld2probs{$f}} = map { $_ / $total; } @counts;
}

my @flds2retain = map { if(exists $flds2rm{$_}) {;} else { $_; } } (0..(scalar(@fnames)-1));

$in->reset();

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";
print OUT join("\t", map { $fnames[$_]; } @flds2retain), "\n";

while($row=$in->readNextRow()) {
    map { 
	if($row->[$_] eq "NA") { 
#	    print "fld = $_, fld2vals = @{$fld2vals{$_}}, fld2probs=@{$fld2probs{$_}}\n"; 
	    
	    if(scalar(@{$fld2vals{$_}}) != 0) {
#		print "replacing $row->[$_] to ";
		$row->[$_] = math::util::getRandomElementWithProbs($fld2vals{$_}, $fld2probs{$_}); # random guess
		print "$row->[$_]\n";
	    } 
	}
    } @flds2guess;

    print OUT join("\t", map { $row->[$_]; } @flds2retain), "\n";
}

close OUT;

`mv $out.tmp $out`;
