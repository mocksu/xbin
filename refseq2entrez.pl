#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <in.csv> <refseq_field> <out.csv>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1(shift @ARGV);
my $rfld = shift @ARGV;
my($out) = shift @ARGV;

my(@fnames) = $in->getFieldNames();
my(%rIDExists);
map { $rIDExists{$_} = 1; } $in->getFieldValues($rfld);

my $mapFile = "/udd/remxx/xlib/perl/sequence/db/gene2entrez.csv";
open MAP, "<$mapFile" or die $!;
my($grIDFld) = 3;

open OUT, "+>$out" or die "Cannot open $out\n";
print OUT "REFSEQ_ID";

my $line = <MAP>;
$line = <MAP>;

print OUT "\t$line";

while($line = <MAP>) {
    chomp($line);

    my @row = split(/\t/, $line, 13);

    my ($grID, $version) = (split(/\./, $row[$grIDFld]));

    if(exists $rIDExists{$grID}) {
	print OUT Flat::dataRowToString($grID, $line), "\n";
    }

    if($c++ % 10000 == 0) {
	print "processing $c\n";
    }
}

close MAP;
close OUT;
    
