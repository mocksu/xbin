#!/usr/bin/perl -w

use Util;
use Flat;

my $cmdLine = Util::getCmdLine();

if(scalar(@ARGV) != 2 && scalar(@ARGV) != 3) {
    print "Add comments from the specified file to the input file\n";
    print "Usage: ~ <in.csv> 'comments' [<out.csv>]\n";
    print "e.g.   ~ /tmp/t.csv 'this is a tmp file\\nused for testing' /tmp/t1.csv\n";
    print "       Please note the embedded newline char\n\n";
    exit(1);
}

my($in) = Flat->new(shift @ARGV, 1);
my($comments) = shift @ARGV;
my(@clines) = split(/\\n/, $comments);

my($out);

if(scalar(@ARGV) == 1) {
    $out = shift @ARGV;
}
else {
    $out = $in->getFileName();
}

my($otmp) = "$out.addComments.tmp";
open OUT, "+>$otmp" or die "Cannot open $otmp\n";

print OUT $in->getComments();
print OUT map { "# $_\n"; } @clines;

my(@fnames) = $in->getFieldNames();
print OUT join("\t", @fnames), "\n";

while($row = $in->readNextRow()) {
    print OUT join("\t", @{$row}), "\n";
}

close OUT;

`mv $otmp $out`;
