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
  print "Randomize the specified fields\n\n";
  print "Usage: ~ <in.xls> <fld1> ... <fldN> <out.xls>\n\n";
  print "See Also: randomizeXLSinBlock.pl\n";
  exit(1);
}

my $inFile = shift @ARGV;
my $outFile = pop @ARGV;
my @flds = @ARGV;

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

for(my($i) = 2; $i <= $inSheet->{"maxrow"}; $i++) {
  foreach $f (@flds) {
#    print "f = $f, val = ", $inSheet->{"$f$i"}, "\n";
    push @{$col2data{$f}}, $inSheet->{"$f$i"};
  }
}

## randomize the specified data
my(%col2rdata);
foreach $f (@flds) {
  @{$col2rdata{$f}} = math::util::randomize(@{$col2data{$f}});
}

## randomize the specified data and write
# write the column names
$out->write_row(0, 0, [map { $inSheet->{"$_"."1"}; } (A..$lastCol)]);

# write the data
for(my($i) = 2; $i <= $inSheet->{"maxrow"}; $i++) {
  my @row = ();

  for $c (A..$lastCol) {
    if(exists $col2rdata{$c}) { # if to use randomized data
      push @row, $col2rdata{$c}->[$i-2];
    }
    else { # if to use unchanged data
      push @row, $inSheet->{"$c$i"};
    }
  }

#  print "i = $i, row = @row\n";

  $out->write_row($i-1, 0, [@row]);
}

$outBook->close();  
