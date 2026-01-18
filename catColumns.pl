#!/usr/bin/perl -w

if((@ARGV) < 2) {
    print "Usage: ~ [-o] <file1.csv> <file2.csv> ... <filen.csv> <out.csv>\n\n";
    print "-o\trewrite the output file if exists\n";
    print "Merge the data files line by line, assuming each line in a file corresponds to the same line in any other file\n\n";
    exit(1);
}

use Flat;
use Getopt::Std;

my(%options);
getopts("o", \%options);

my $out = pop @ARGV;

if(!(exists $options{"o"})&&(-e $out)) {
    die "$out exists already\n";
}

my(@fileNames) = @ARGV;

if(scalar(@fileNames) == 1) {
    `cp $fileNames[0] $out`;
    exit(0);
}

my(@files, @fieldNames);

for(my($i) = 0; $i < (@fileNames); $i++) {
    $files[$i] = Flat->new1($fileNames[$i]);
    my @flds;

    if($files[$i]->hasHeader()) {
      @flds = $files[$i]->getFieldNames();
    }
    else {
      @flds = map { "FIELD$_"; } (1..$files[$i]->getNumOfFields());
    }

    push @fieldNames, @flds;
}

open OUT, "+>$out" or die "Cannot open $out\n";

# print field names
# print OUT join("\t", map { $orig = $_; $orig =~ s/\s//g; $orig}  @fieldNames), "\n";
print OUT join("\t", @fieldNames), "\n";

# print data lines

while($row = $files[0]->readNextRow()) {
  my @rowData = @{$row};

  for(my($i) = 1; $i < scalar(@files); $i++) {
    push @rowData, @{$files[$i]->readNextRow()};
  }

#  print OUT join("\t", map { $orig = $_; $orig =~ s/\s//g; $orig}  @rowData), "\n";
  print OUT join("\t", @rowData), "\n";
}

close OUT;
