#!/usr/bin/perl -w

use Flat;

use DBI;
my $dbh = DBI->connect('DBI:mysql:database=hg18;host=hg', 'moxu', 'Genome')
    or die "Couldn't connect to database: " . DBI->errstr;

# prepare statement 
my $reg_sth = $dbh->prepare("select name, chrom, chromStart, chromEnd from snp126 where name = ?");

my $in = Flat->new1("data/LRAP.CAMP_mRNA_pVal.csv");

while($row = $in->readNextRow()) {
    my $rsNum = $row->[1];
# run query
    $reg_sth->execute("$rsNum");

# get results
    if(@drow = $reg_sth->fetchrow_array()) { 
	print join("\t", @drow), "\n";
    }
}



    
