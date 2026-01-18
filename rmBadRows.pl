#!/usr/bin/perl -w

use Flat;

if(scalar(@ARGV) != 3 && scalar(@ARGV) != 2) {
    print "Usage: ~ <in.csv> <out.csv> [with_header]\n";
    exit(1);
}

my($in);

if(scalar(@ARGV) == 3) {
    $in = Flat->new($ARGV[0], $ARGV[1]);
}
else { # == 1
    $in = Flat->new1($ARGV[0]);
}

my $out = $ARGV[1];

open OUT, "+>$out.tmp" or die $!;
print OUT "# rmBadRows.pl ", join(" ", @ARGV), "\n";

if($in->hasHeader()) {
  print OUT join("\t", $in->getFieldNames()), "\n";
}

my $warn = 0;

while(($err, $row) = @{$in->readNextRow(0,1)}) {
  if($err) { # if warning generated
    $warn++;
    # do not print out
  }
  else {
    print OUT join("\t", @{$row}), "\n";
  }
}

close OUT;

`mv $out.tmp $out`;

print "$warn rows removed\n";
