#!/usr/bin/perl -w

sub printUsage() {
    print "\nUsage: ~ [-p|s] <addOn> <input.csv> <fld> [<output.csv>]\n";
    print "         Add prefix (\"p\", default) or suffix (\"s\") to each of the field values\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("p:s:", \%options);
my($fix, $label);

if(scalar(keys %options) > 1) {
    printUsage();
}
elsif(exists $options{"p"}) {
    $fix = "p";
    $label = $options{"p"};
}
elsif(exists $options{"s"}) {
    $fix = "s";
    $label = $options{"s"};
}
else { # no specification
    $fix = "p";
    $label = shift @ARGV;
}

if((@ARGV) < 2) {
    printUsage();
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
my($fldIndex) = $in->getFieldIndex($ARGV[1]);

my($out);

if(scalar(@ARGV) == 3) {
    $out = $ARGV[2];
}
else {
    $out = $ARGV[0];
}

my $tmpOut = "$out.tmp";

open OUT, "+>$tmpOut" or die $!;

my(@fldNames) = $in->getFieldNames();

if(scalar(@fldNames) > 0) {
    print OUT Flat::dataRowToString(@fldNames), "\n";
}

while($row = $in->readNextRow()) {
    if($fix eq "p") {
	$row->[$fldIndex] = "$label$row->[$fldIndex]";
    }
    else { # suffix
	$row->[$fldIndex] = "$row->[$fldIndex]$label";
    }

    print OUT Flat::dataRowToString(@{$row}), "\n";
}

close OUT;
`mv $tmpOut $out`;
