#!/usr/bin/perl -w

use Flat;
use Util;
use Getopt::Std;

sub printUsage {
    print "Usage: ~ [-s] -c columnName [-f \"fld1|...|fldN\"] <in.csv> <withFields.csv> <out.csv>\n";
    print "\t-s skip checking data integrity of the input file. Default is to check\n";
    print "\t-c the column name in 'withFields.csv' whose values specify columns to be extracted.\n";
    print "\t   otherwise the field names in 'withFields.csv' are used to specify columns\n";
    print "\t-f manually specified field names to extract\n";
    exit(1);
}

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("f:c:s", \%options);

my $skipCheck = exists $options{"s"};

if(!(exists $options{"c"})) {
    print "Please specifiy -c\n";
    printUsage();
}

if(scalar(@ARGV) != 3) {
    printUsage();
}

my $inFile = shift @ARGV;
my($in) = Flat->new($inFile, 1,"\t",1);
my $fieldsFile = Flat->new(shift @ARGV, 1);
my($out) = shift @ARGV;

my(@fnames) = $in->getFieldNames();
my %fldExist;
map { $fldExist{$_} = 1; } @fnames;

my @fldsSpecified;

if(exists $options{"f"}) {
    @fldsSpecified = split(/\|/, $options{"f"});
}

if(exists $options{"c"}) {
    push @fldsSpecified, $fieldsFile->getColumnData($fieldsFile->getFieldIndex($options{"c"}));
}
else {
    push @fldsSpecified, $fieldsFile->getFieldNames();
}

my @flds2extract;
my @fldsNotFound;

map { if(exists $fldExist{$_}) { push @flds2extract, $_; } else { push @fldsNotFound, $_; } } @fldsSpecified;

if(scalar(@fldsNotFound) > 0) {
    warn "Fields not exist in the input file: @fldsNotFound\n";
}

my $skip = "";

my @fldIndice2extract = map { $in->getFieldIndex($_); } @flds2extract;
#die "fldIndice2extract = @fldIndice2extract\n";
open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";
print OUT join("\t", @flds2extract), "\n";

while($row = $in->readNextRow($skipCheck)) {
    if($in->getRowIndex() % 50 == 1) {
	print "Extracting row ", $in->getRowIndex(), "\n";
    }

    print OUT join("\t", map { $row->[$_] } @fldIndice2extract), "\n";
}

close OUT;

`mv $out.tmp $out`;

print "Done extractColumnsInFile.pl\n";
