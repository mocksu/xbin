#!/usr/bin/perl -w

if(scalar(@ARGV) != 4) {
    print "Remove the possible version from the refseq id values\n";
    print "Usage: ~ <in.csv> <rid_fld> <new_rid_name> <out.csv>\n";
    exit(1);
}

use Flat;
use Util;

my $cmdLine = Util::getCmdLine();

my($in) = Flat->new1(shift @ARGV);
my $ridFld = $in->getFieldIndex(shift @ARGV);
my $newRidName = shift @ARGV;
my($out) = shift @ARGV;

open OUT, "+>$out.tmp" or die $!;
print OUT "# $cmdLine\n";

if($in->hasHeader()) {
    my(@fnames) = $in->getFieldNames();
    print OUT join("\t", @fnames, $newRidName), "\n";
}

while($row = $in->readNextRow()) {
    my $rid = $row->[$ridFld];

    if($rid =~ /\./) {
	my($short, $suf) = split(/\./, $rid);
	
	print OUT join("\t", @{$row}, $short), "\n";
    }
    else {
	print OUT join("\t", @{$row}, $rid), "\n";
    }
}

close OUT;

`mv $out.tmp $out`;

