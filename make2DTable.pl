#!/usr/bin/perl -w

if(scalar(@ARGV) != 6) {
    print "Usage: ~ <in.csv> <field1|fldname1> <num_category1> <field2|fldname2> <num_category2> <out.csv>\n";
    exit(1);
}

use Flat;

my $in = shift @ARGV;
my $inFile = Flat->new1($in);

my $fld1 = $inFile->getFieldIndex(shift @ARGV);
my $num1 = shift @ARGV;
my $fld2 = $inFile->getFieldIndex(shift @ARGV);
my $num2 = shift @ARGV;
my $out = shift @ARGV;

`discreteCovar.pl $in $fld1 $num1`;

# the temp file generated for the above
my $tmp1 = "/tmp/t$fld1.$num1.csv";

`discreteCovar.pl $tmp1 $fld2 $num2`;

my $tmp2 = "/tmp/t$fld2.$num2.csv";

my $result = Flat->new1($tmp2);
my @data = $result->getDataArray();

my(%fld1tofld2);

for(my($i) = 0; $i < scalar(@data); $i++) {
    $fld1tofld2{$data[$i][$fld1]}{$data[$i][$fld2]}++;
}


open OUT, "+>$out" or die "Cannot open $out\n";

my(@fldNames) = "fields";

for(my($i) = 0; $i < $num2; $i++) {
    push @fldNames, $i;
}

print OUT Flat::dataRowToString(@fldNames), "\n";

foreach $fval1 (sort {$a <=> $b} keys %fld1tofld2) {
    my(@row);

    foreach $fval2 (sort {$a <=> $b} keys %{$fld1tofld2{$fval1}}) {
	push @row, $fld1tofld2{$fval1}{$fval2};
    }

    print OUT Flat::dataRowToString("row.$fval1", @row), "\n";
}

close OUT;
