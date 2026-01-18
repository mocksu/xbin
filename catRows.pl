#!/usr/bin/perl -w

sub printUsage {
    print "Usage: ~ [-o] <in1.csv> ... <inn.csv> <out.csv>\n";
    print "         o\tOverwrite tbe output file\n";
    exit(1);
}

use Getopt::Std;

my(%options);
getopts("o", \%options);

if(scalar(@ARGV) < 2) {
    printUsage();
}

use Flat;
use math;

my $cmdLine = Util::getCmdLine();
my $out = pop @ARGV;

if(!(exists $options{"o"}) && (-e $out)) {
    print "Output file exists.\n";
    printUsage();
}

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

my(@fldNames) = Flat->new($ARGV[0], 1)->getFieldNames();

for(my($i) = 1; $i < scalar(@ARGV); $i++) {
    @fnames = Flat->new($ARGV[$i], 1)->getFieldNames();

    if(scalar(@fldNames) != scalar(@fnames)) {
	die "'$ARGV[0]' has ".scalar(@fldNames)." fields, '$ARGV[$i]' has ".scalar(@fnames)." fields\n";
    }

    for($j = 0; $j < scalar(@fldNames); $j++) {
	if($fldNames[$j] ne $fnames[$j]) {
	    die "'$fldNames[$j]' in '$ARGV[0]' does not match '$fnames[$i]' in '$ARGV[$i]'\n";
	}
    }
}

print OUT "# $cmdLine > <this_file>\n";
print OUT join("\t", @fldNames), "\n";

for(my($i) = 0; $i < scalar(@ARGV); $i++) {
    my $in = Flat->new1($ARGV[$i]);

    while($row = $in->readNextRow()) {
	print OUT join("\t", @{$row}), "\n";
    }

    undef $in;
}

close OUT;

`mv $out.tmp $out`;
