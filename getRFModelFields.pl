#!/usr/bin/perl -w

if(scalar(@ARGV) != 1 && scalar(@ARGV) != 2) {
    print "Usage: ~ <RF.model> [out.csv]\n";
    exit(1);
}

use RF;

my $mdl = shift @ARGV;

my $out = shift @ARGV;

my(@mdlFldNames) = @{RF::getFieldNamesFromModel($mdl)};
print "Total ", scalar(@mdlFldNames), " predictors:\n";

if($out) {
  open OUT, "+>$out.tmp" or die "Cannot open $out.tmp\n";
  
  print OUT join("\n", @mdlFldNames), "\n";

  close OUT;

  `mv $out.tmp $out`;
}
else {
  print join(", ", @mdlFldNames), "\n";
}
