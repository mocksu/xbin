#!/usr/bin/perl -w

use Util;
use Flat;

if(scalar(@ARGV) != 4) {
    print "Usage: ~ <in.csv> '<keyFld1|...|keyFldN>' '<1valFld1|...|1valFldN>' <out.csv>\n";
    exit(1);
}

my $cmdLine = Util::getCmdLine();

my($in) = Flat->new(shift @ARGV, 1);
my @kflds = split(/\|/, shift @ARGV);
my @kfldIndice = $in->getFieldIndice([@kflds]);
my @vflds = split(/\|/, shift @ARGV);
my @vfldIndice = $in->getFieldIndice([@vflds]);
my($out) = shift @ARGV;

open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";

my $cmts = $in->getComments();

if($cmts) {
    print OUT $cmts;
}

print OUT "# $cmdLine\n";
print OUT join("\t", $in->getFieldNames()), "\n";

my %kvExists;

while($row = $in->readNextRow()) {
    my $keyVals = join(",", map { $row->[$_]; } @kfldIndice);
    my $valVals = join(",", map { $row->[$_]; } @vfldIndice);

    if(exists $kvExists{$keyVals}) { # already selected an entry for the keys
	if(exists $kvExists{$keyVals}{$valVals}) {
	    print OUT join("\t", @{$row}), "\n";
	}
	# else skip this entry because its keys were not selected
    }
    else { # first entry, select it
	$kvExists{$keyVals}{$valVals} = 1;
	print OUT join("\t", @{$row}), "\n";
    }
}

close OUT;

`mv $out.tmp $out`;
