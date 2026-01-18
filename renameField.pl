#!/usr/bin/perl -w

if(scalar(@ARGV) != 4 && scalar(@ARGV)!= 3) {
    print "Usage: ~ <in.csv> <FieldName> <NewFieldName> [<out.csv>]\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1($ARGV[0]);
my($fldIndex) = $in->getFieldIndex($ARGV[1]);

if($fldIndex == -1) {
    die "Field '$ARGV[1]' not found in '$ARGV[0]'\n";
}

my($out);

if(scalar(@ARGV) == 4) {
    $out = $ARGV[3];
}
else {
    $out = $ARGV[0];
}

my($tmp) = "$out.tmp";

my @fnames = $in->getFieldNames();
$fnames[$fldIndex] = $ARGV[2];

open OUT, "+>$tmp" or die "Cannot open $tmp\n";

print OUT join("\t", @fnames), "\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}), "\n";
}

close OUT;

`mv $tmp $out`;

