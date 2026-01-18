#!/usr/bin/perl -w

if(scalar(@ARGV) < 3) {
    print "Usage: ~ <in.csv> <fname1> <newFnameN> ...<fnameN> <newFnameN> [<out.csv>]\n\n";
    exit(1);
}

use Flat;

my($in) = Flat->new1(shift @ARGV);

my $out;

if(scalar(@ARGV) % 2 == 1) {
    $out = pop @ARGV;

    if(-e $out) {
	die "The output file $out exists\n";
    }
}
else { # not output file specified
    $out = $in->getFileName();
}

while(scalar(@ARGV) > 0) {
    my($fldIndex) = $in->getFieldIndex(shift @ARGV);
    my $newFldName = shift @ARGV;
    $in->setFieldName($fldIndex, $newFldName);
}

my($tmp) = "$out.tmp";
$in->writeToFile($tmp);
`mv $tmp $out`;

