#!/usr/bin/perl -w

sub printUsage() {
    print "Usage: ~ <title> <in.csv> <yfield> <xfield> <out.jpeg>\n";
    exit(1);
}

if(scalar(@ARGV) != 5) {
    printUsage();
}

use Flat;

my $title = shift @ARGV;
my $inFile = shift @ARGV;
my $yfld = shift @ARGV;
my $xfld = shift @ARGV;
my $out = pop @ARGV;

my $rscript = "$out.r";

open R, "+>$rscript" or die $!;

print R "png(\"$out\")\n";

print R "d<-read.table(\"$inFile\", header=TRUE)\n";
print R "boxplot($yfld ~ $xfld, data=d, ylab=\"$yfld\", xlab=\"$xfld\")\n";

print R "dev.off()\n";

close R;

`R --no-save < $rscript`;
#`xview $out`;
