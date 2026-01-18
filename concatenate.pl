#!/usr/bin/perl -w

if((@ARGV) <= 2) {
    print "Usage: ~ <file1.csv> <file2.csv> ... <filen.csv> <out.csv>\n\n";
    print "Merge the data files line by line, assuming each line in a file corresponds to the same line in any other file\n\n";
    exit(1);
}

use Flat;

my $out = pop @ARGV;

if(-e $out) {
    die "$out exists already\n";
}

my(@fileNames) = @ARGV;

my(@files, @fieldNamesArrays);

for(my($i) = 0; $i < (@fileNames); $i++) {
    $files[$i] = Flat->new1($fileNames[$i]);
    @{$fieldNamesArrays[$i]} = $files[$i]->getFieldNames();
}

open OUT, "+>$out" or die "Cannot open $out\n";

# print field names
print OUT $fieldNamesArrays[0][0];

for(my($j) = 1; $j < (@{$fieldNamesArrays[0]}); $j++) {
    print OUT "\t$fieldNamesArrays[0][$j]";
}

for(my($i) = 1; $i < (@fileNames); $i++) {   
    for(my($j) = 0; $j < (@{$fieldNamesArrays[$i]}); $j++) {
	print OUT "\t$fieldNamesArrays[$i][$j]";
    }
}

print OUT "\n";

# print data lines
my @row;
while($row0 = $files[0]->readNextRow()) {
    push @row, @{$row0};

    for(my($j) = 1; $j < scalar(@files); $j++) {
	$rowj = $files[$j]->readNextRow();
	push @row, @{$rowj};
    }
    
    print OUT join("\t", @row), "\n";
    
    @row = ();
}

close OUT;
