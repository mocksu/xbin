#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <field> <value>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1(shift @ARGV);
my $fld = $in->getFieldIndex(shift @ARGV);
my $val = shift @ARGV;

my $found = 0;

while($row = $in->readNextRow()) {
    if($row->[$fld] eq $val) {
	print $in->getRowIndex() - 1,"-th (0 based) row:\n@{$row}\n";
	$found = 1;
	last;
    }
}

if(!$found) {
    print "Row not found for '$val' in field '$fld'\n";
}

$in->destroy();

