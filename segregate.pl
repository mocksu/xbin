#!/usr/bin/perl -w

use Util;
use Getopt::Std;

my $cmdLine = Util::getCmdLine();

my(%options);
getopts("a", \%options);
my $APPEND = exists $options{"a"};

if(scalar(@ARGV) != 6 && scalar(@ARGV) != 4) {
    print "Usage: ~ <in.csv> \"fld1|...|fldn\" <specification.csv> \"fld1|...|fldn\" [<specified.csv> <unspecified.csv>]\n";
    print "       split <in.csv> into two files, one with field values specified by <specification.csv>, the other without\n\n";
    exit(1);
}

use Flat;
use math;

my $in = Flat->new1(shift @ARGV);
my @inFlds = $in->getFieldIndice([split(/\|/, shift @ARGV)]);
my $spec = Flat->new1(shift @ARGV);
my @specFlds = $spec->getFieldIndice([split(/\|/, shift @ARGV)]);

my($out1, $out2);

if(scalar(@ARGV) == 2) {
    $out1 = shift @ARGV;
    $out2 = shift @ARGV;
}
else {
    $out1 = "/dev/null";
    $out2 = "/dev/null";
}

my $inName = $in->getFileName();

my(%specified) = $spec->getIndiceOfFieldValues(@specFlds);

my $tmpOut1;
my $tmpOut2;

if($out1 eq $in->getFileName() || 
   $out1 eq $spec->getFileName()) {
    $tmpOut1 = "$out1.tmp";
}
else {
    $tmpOut1 = "$out1";
}

if($out2 eq $in->getFileName() || 
   $out2 eq $spec->getFileName()) {
    $tmpOut2 = "$out2.tmp";
}
else {
    $tmpOut2 = "$out2";
}

open SPEC, "+>$tmpOut1" or die $!;
open UNSPEC, "+>$tmpOut2" or die $!;
print SPEC "# $cmdLine; specified\n";
print UNSPEC "# $cmdLine; unspecified\n";

if($in->hasHeader()) {
    print SPEC join("\t", $in->getFieldNames()), "\n";
    print UNSPEC join("\t", $in->getFieldNames()), "\n";
}

my $nspec = 0;
my $nunspec = 0;
my %uniqueSpecified;
my %uniqueUnspecified;

while($row = $in->readNextRow()) {
    my $fvals = join(",", map { $row->[$_] } @inFlds);
    
    if(exists $specified{$fvals}) {
	print SPEC Flat::dataRowToString(@{$row}), "\n";
	$uniqueSpecified{$fvals}++;
	$nspec++;
    }
    else {
	print UNSPEC Flat::dataRowToString(@{$row}), "\n";
	$uniqueUnspecified{$fvals}++;
	$nunspec++;
    }
}

close SPEC;
close UNSPEC;

if($tmpOut1 ne $out1) {
    Util::run("mv $tmpOut1 $out1", 0);
  }

if($tmpOut2 ne $out2) {
    Util::run("mv $tmpOut2 $out2", 0);
  }

print "DONE segregate.pl:\n$nspec entries (", scalar(keys %uniqueSpecified), " unique) specified, $nunspec entries (", scalar(keys %uniqueUnspecified), " unique) unspecified\n", scalar(keys %specified) - scalar(keys %uniqueSpecified), " uniuqe specifications not in '$inName'\n";
