#!/usr/bin/perl -w

# replace a regular expression string with another string

if(scalar(@ARGV) < 5) {
    print "\nUsage: ~ <input.csv> <regular_expression> <replace_string> <out.csv> <field_no1> ... <filed_non>\n\n";
    exit(1);
}

use Flat;
use Util;

my $cmdLine = Util::getCmdLine();
my($in) = Flat->new1(shift @ARGV);
my($restr) = shift @ARGV; # the regular expression string to be replaced
my($str) = shift @ARGV; # the string to replace $restr
my($out) = shift @ARGV;
my(@fldIndice) = $in->getFieldIndice([@ARGV], 1);

my(@fldNames) = $in->getFieldNames();

open OUT, "+>$out.tmp" || die $!;
print OUT "# $cmdLine\n";
print OUT $in->getComments();

# print field names
if($in->hasHeader()) {
    print OUT Flat::dataRowToString(@fldNames), "\n";
}

while($row = $in->readNextRow()) {
    foreach $fldIndex (@fldIndice) {
	$row->[$fldIndex] =~ s/$restr/$str/;
    }

    print OUT join("\t", @{$row}), "\n";
}

close OUT;

`mv $out.tmp $out`;
