#!/usr/bin/perl -w

use Util;
use Flat;
use Getopt::Std;

my(%options);
getopts("n", \%options);

if(scalar(@ARGV) != 4 && scalar(@ARGV) != 5) {
    print "\nUsage: ~ [-n] <input_file> <field_index> <field_name> <field_val> [<out_file>]\n\n";
    print "         -n no field name is used. The specified field name is ignored.\n\n";
    exit(1);
}

my $cmdLine = Util::getCmdLine();

my($in) = Flat->new1(shift @ARGV);
my $fldIndex = shift @ARGV;
my $fldName = shift @ARGV;
my $cval = shift @ARGV;
my $out;

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in->getFileName();
}

my $otmp = "$out.addColumn.tmp";

open OUT, "+>$otmp" or die "Cannot open $otmp\n";

if(!(exists $options{"n"})) {
  my @fnames = $in->getFieldNames();
  splice @fnames, $fldIndex, 0, $fldName;
  
  print OUT join("\t", @fnames), "\n";
}

while($row = $in->readNextRow()) {
    @rdata = @{$row};
    splice @rdata, $fldIndex, 0, $cval;
    print OUT join("\t", @rdata), "\n";
}

close OUT;

`mv $otmp $out`;
