#!/usr/bin/perl -w

use FASTA;
use DNA;

my($fa) = FASTA->new($ARGV[0]);
my(@entries) = $fa->getEntries();

foreach $e (@entries) {
    my($dna) = DNA->new($e->[1]);
    
    my($GorC) = $dna->getGCCount();
    my(%di) = $dna->getDinucleotideCounts();
    my($CG) = $di{'CG'};
    my($GC) = $di{'GC'};
    my($normCpG) = (($CG + $GC) / (2 * 2999)) / (($GorC / (2 * 3000)) ** 2);

    print "$GorC\t$CG\t$GC\t$normCpG\n";
}
