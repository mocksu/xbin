#!/usr/bin/perl -w

if(scalar(@ARGV) < 2) {
    print "Usage: ~ <in.csv> <out.csv> [<fldNum1> ... <fldNumn>]\n";
    print "If no fldNums specified, all fields will be trimmed\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new(shift @ARGV, 1);
my($out) = shift @ARGV;
open OUT, "+>$out.tmp" or die $!;

my(@fnames) = $in->getFieldNames();
my(@data) = $in->getDataArray();

my(@flds);

if(scalar(@ARGV) > 0) {
    @flds = map { $in->getFieldIndex($_); } @ARGV;
}
else {
    my $c = 0;
    @flds = map { $c++; } @fnames;
}

print OUT join("\t", map { $fnames[$_] =~ s/^\s+|\s+$//; $fnames[$_]; } @flds), "\n";

for(my($i) = 0; $i < scalar(@data); $i++) {
    map {$data[$i][$_] =~ s/^\s+|\s+$//} @flds;
    print OUT Flat::dataRowToString(@{$data[$i]}), "\n";
}

close OUT;

`mv $out.tmp $out`;
