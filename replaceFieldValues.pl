#!/usr/bin/perl -w

# replace a regular expression string with another string

if(scalar(@ARGV) < 5) {
    print "\nUsage: ~ <input.csv> <regular_expression> <replace_string> <out.csv> <field_no1> ... <filed_non>\n\n";
    exit(1);
}

use Flat;
use Util;

my($in) = Flat->new1(shift @ARGV);
my($restr) = shift @ARGV; # the regular expression string to be replaced
my($str) = shift @ARGV; # the string to replace $restr
my($out) = shift @ARGV;
my(@fldIndice) = $in->getFieldIndice([@ARGV], 1);

my(@fldNames) = $in->getFieldNames();
my(@data) = $in->getDataArray();

open OUT, "+>$out" || die $!;

# print field names
if($in->hasHeader()) {
    print OUT Flat::dataRowToString(@fldNames), "\n";
}

my $count = 0;

for(my($i) = 0; $i < scalar(@data); $i++) {
    foreach $fldIndex (@fldIndice) {
	if($data[$i][$fldIndex] =~ s/$restr/$str/g) {
	    $count++;
	}
    }

    print OUT Flat::dataRowToString(@{$data[$i]}), "\n";
}

close OUT;

print "$count rows have been modified\n";
