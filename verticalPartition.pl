#!/usr/bin/perl -w

use Util;
use Flat;
use Flat;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("f:", \%options);
my($fldsFile) = exists $options{"f"}?$options{"f"}:"";

if(scalar(@ARGV) != 3) {
    print "Partition the specified fields 'in.csv' into 'numOfParts' files\n";
    print "  together with unspecified fields.\n\n";
    print "Usage: ~ [-f <fieldsInOrder.csv>] <in.csv> <partSize> <outStem>\n\n";
    print "\t-f: fields to partition. Default is to partition all fields\n";
    exit(1);
}

my($in) = Flat->new(shift @ARGV, 1);
my $partSize = shift @ARGV;
my($outStem) = shift @ARGV;

my @fieldNames = $in->getFieldNames();

my %fldExists;
map { $fldExists{$_} = 1; } @fieldNames;

my %spec;
my @specIndice = ();
my @unspecIndice = ();

if($fldsFile) {
    map { 
	if($fldExists{$_}) {
	    $spec{$_} = 1; 
	    push @specIndice, $in->getFieldIndex($_);
	} 
    } Flat->new($fldsFile, 0)->getColumnData(0);
}
else {
    map { $spec{$_} = 1; } @fieldNames;
    my $lastIndex = scalar(@fieldNames) - 1;
    @specIndice = (0 .. $lastIndex);
}

map { if(!(exists $spec{$_})) { push @unspecIndice, $in->getFieldIndex($_); } } @fieldNames;

my $numParts = int(scalar(@specIndice) / $partSize) + 1 ;

# create file handles
my @fhs = ();
my %fh2fldIndice;

# allocate unspec fields to part files
for(my($i) = 0; $i < $numParts; $i++) {
    my $fh = "OUT$i";	
    open $fh, "+>$outStem.$i.csv" or die $!;
    push @fhs, $fh;
    push @{$fh2fldIndice{$i}}, @unspecIndice;
}

# allocate specified to part files
my %fh2specFldIndice = ();

for(my($i) = 0; $i < scalar(@specIndice); $i++) {
    my $outFileIndex = int($i / $partSize);

    push @{$fh2fldIndice{$outFileIndex}}, $specIndice[$i];
}

# print field names
for(my($i) = 0; $i < $numParts; $i++) {
    my $fh = $fhs[$i];
    print $fh "# $cmdLine\n";
    print $fh join("\t", map { $fieldNames[$_]; } @{$fh2fldIndice{$i}}), "\n";
}

while($row = $in->readNextRow()) {
    # print non-snp fields first
    if($in->getRowIndex() % 50 == 1) {
	print "Processing row ", $in->getRowIndex(), " ", `date`;
    }

    for(my($i) = 0; $i < $numParts; $i++) {
	my $fh = $fhs[$i];
	print $fh join("\t", map { $row->[$_]; } @{$fh2fldIndice{$i}}), "\n";
    }
}

# close file handles
for(my($i) = 0; $i < $numParts; $i++) {
    close $fhs[$i];
}

print "Done\n";
