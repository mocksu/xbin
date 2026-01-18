#!/usr/bin/perl -w

sub printUsage {
    my $msg = shift;

    if($msg) {
	print "$msg\n\n";
    }

    print "\nUsage: ~ <-p|s addOn> <input.csv> [<output.csv>]\n";
    print "         Add prefix (\"p\") or suffix (\"s\") to each of the field names\n\n";
    exit(1);
}

use Getopt::Std;
my(%options);
getopts("p:s:", \%options);
my($fix, $label);

if(scalar(keys %options) > 1) {
    printUsage("Too many options");
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
    printUsage();
}

if((@ARGV) == 0) {
    printUsage("No arguments");
}

use Flat;

my($in) = Flat->new1($ARGV[0]);

my($out);

if(scalar(@ARGV) == 2) {
    $out = $ARGV[1];
}
else {
    $out = $ARGV[0];
}

my $tmpOut = "$out.tmp";

if(!$in->hasHeader()) {
    die "Input file $ARGV[0] does not have field names\n";
}

my(@fldNames) = $in->getFieldNames();

for(my($i) = 0; $i < scalar(@fldNames); $i++) {
    if("p" eq $fix) {
	if($fldNames[$i] !~ /^$label/) {
	    $fldNames[$i] = "$label".$fldNames[$i];
	}
    }
    else {
	if($fldNames[$i] !~ /$label$/) {
	    $fldNames[$i] .= "$label";
	}
    }
}

open OUT, "+>$tmpOut" or die "cannot open $tmpOut\n";

print OUT join("\t", @fldNames), "\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}), "\n";
}

$in->destroy();

close OUT;

`mv $tmpOut $out`;
