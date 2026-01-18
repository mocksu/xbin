#!/usr/bin/perl -w

use Flat;
use Util;
use Spreadsheet::Read;
use Spreadsheet::WriteExcel;
use Data::Dumper;
use DNA;
use ExcelUtil;
use Encode;

if(scalar(@ARGV) < 3) {
  print "Randomize the specified fields together\n\n";
  print "Usage: ~ <in.xls> <fld1> ... <fldN> <out.xls>\n\n";
  print "See Also: randomizeXLS.pl\n";
  exit(1);
}

my $inFile = shift @ARGV;
my $outFile = pop @ARGV;
my @flds = @ARGV;
my %fld2rand = ();
map { $fld2rand{$_} = 1; } @flds;

my $inSheet = ReadData($inFile)->[1];
my $outBook = Spreadsheet::WriteExcel->new("$outFile");
my $out = $outBook->add_worksheet();

## determine the number of columns by the first row
my $lastCol;

foreach $c (A..Z) {
  my $f = "$c"."1";
  my $v = ExcelUtil::evalField($inSheet->{"$f"});
#  print "c = $c, v = $v\n";

  if($v) {
    $lastCol = $c;
  }
  else {
    last;
  }
}

# print "lastCol = $lastCol\n";

## read data of the specified columns
my(%col2data);
my @fvals;
my $fstr;
my $sep = "__X,X__";

for(my($i) = 2; $i <= $inSheet->{"maxrow"}; $i++) {
  @fvals =  map { $inSheet->{"$_$i"}; } @flds;
  $fstr = join($sep, @fvals);
  $col2data{$fstr} = [@fvals];
}

## randomize the specified data
my(%col2rdata);
my @rows = math::util::randomize(values %col2data);
my $c = 0;

foreach $k (keys %col2data) {
  $col2data{$k} = $rows[$c++];
}

## write the column names
$out->write_row(0, 0, [map { $inSheet->{"$_"."1"}; } (A..$lastCol)]);

## write the data
my @newFvals;

for(my($i) = 2; $i <= $inSheet->{"maxrow"}; $i++) {
  @fvals =  map { $inSheet->{"$_$i"}; } @flds;
  $fstr = join($sep, @fvals);
  @newFvals = @{$col2data{$fstr}};
  print "fvals = @fvals, newfvals = @newFvals\n";

  my @row = map { if(exists $fld2rand{$_}) { shift @newFvals; } else { $inSheet->{"$_$i"};} } (A..$lastCol);

#  print "i = $i, row = @row\n";

  $out->write_row($i-1, 0, [@row]);
}

$outBook->close();  
