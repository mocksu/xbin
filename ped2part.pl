#!/usr/bin/perl -w

if(scalar(@ARGV) < 5) {
    print "Usage: ~ <samples.csv> <in.ped> <in.map> <out.csv> <fld1> ... <fldN>\n";
    print "       fldx\tfield index not including the first 6 fields in the .ped file\n";
    exit(1);
}

use Flat;

my $s = shift @ARGV;
my $ped = shift @ARGV;
my $map = Flat->new(shift @ARGV, 0);
my $out = shift @ARGV;
my @flds = @ARGV;
my $fldStr = join("|",1, map { 6 + $_*2, 6+$_*2+1} @flds);
my %fldExists; map { $fldExists{$_} = 1; } @flds;
my @snps;

while($row = $map->readNextRow()) {
    if(exists $fldExists{$map->getRowIndex() - 1}) {
	push @snps, "$row->[1].1", "$row->[1].2";
    }
}

Util::run("extractColumns.pl $ped '$fldStr' $out.ped", 1);
Util::run("addFieldNames.pl $out.ped $out.csv PID @snps", 1);
`rm $out.ped`;
Util::run("leftJoins.pl $s 0 $out.csv 0 $out", 1);
`rm $out.csv`;
Util::run("two2one.pl $out $out.additive", 1);
