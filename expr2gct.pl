#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "Create Borad Institute .gct and .cls files from the input expression file in per sample per row format\n\n";
    print "Usage: ~ <expr.csv> <pheno.csv> <outStem> [class0name ... classNname]\n";
    print "<expr.csv> header example:\n";
    print <<EG;
probeset_id	B1N	B5N	B8T	B10T	B14T	B16T	B17T	B1NR	B20T	B51NR	L26N	L38T	N285BODY	X102	X116_02	N257ANTR	L30T	L31G280	B6T	B15T	B21T	B29T	B31T	B32T
1000_at	36.795	33.187	33.469	32.985	36.259	34.027	48.701	39.762	35.245	34.229	112.114	34.375	34.552	44.223	28.452	55.556	34.764	33.491	33.416	34.087	34.302	37.32	44.925	43.76	55.117
EG

print "<pheno.csv> has its first column being the Sample names matching those in <expr.csv> and the 2nd column being the phenotypes. The header is expected.\n";
    exit(1);
}

# add a column after the first column

use Flat;
use math;
use Util;

my($expr) = Flat->new(shift @ARGV, 1);
my $pheno = Flat->new(shift @ARGV, 1);

my($outStem) = shift @ARGV;
my @classNames = @ARGV;

# get the phenotypes
my %sample2pheno;

while($row = $pheno->readNextRow()) {
    $sample2pheno{$row->[0]} = $row->[1];
}

$pheno->destroy();

my @classes =  sort { $a <=> $b } math::util::getUniqueElements(values %sample2pheno);

if(scalar(@classNames) == 0) { # class name not specified
    @classNames = map { "class$_"; } @classes;
}

# get the samples in the <expr.csv>
my(@samples) = $expr->getFieldNames();
shift @samples; # skip "probest_id"
my(@phenos);
# check if the phenos of the samples exist for all of them
map { if(!(exists $sample2pheno{$_})) { die "Phenotype for $_ is not defined\n"; } else { push @phenos, $sample2pheno{$_};} } @samples;

### write the "cls" file
open CLS, "+>$outStem.cls" or die "Cannot open $outStem.cls\n";
# first line: <sampleSize> <NumOfClasses> 1
print CLS join(" ", scalar(@samples), scalar(@classes), 1), "\n";
# second line: <class0name> ... <classNname>\n";
print CLS join(" ", "#", @classNames), "\n";
# third line: sample classes
print CLS join(" ", @phenos), "\n";
close CLS;

# create .gct file
my $gct = "$outStem.gct";
open GCT, "+>$gct" or die "Cannot open $gct\n";

# line 1:
print GCT "#1.2\n";
# line 2: <numOfRows> <numOfSamples>
print GCT join("\t", $expr->getNumOfRows(), scalar(@samples)), "\n";
# line 3: NAME Description <sample1> ... <sampleN>
print GCT join("\t", "NAME", "Description", @samples), "\n";

while($row = $expr->readNextRow()) {
    @rdata = @{$row};
    print GCT join("\t", $row->[0], @rdata), "\n";
}

close GCT;
