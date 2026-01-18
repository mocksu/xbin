#!/usr/bin/perl -w

sub printUsage() {
    print "Usage: ~ <title> <in1.csv> <fld1.1> <name1.1> <fld1.2> <name1.2> <color1>... <inN.csv> <fldN.1> <nameN.1> <fldN.2> <nameN.2> <colorN> <out.jpeg>\n";
    exit(1);
}

if(scalar(@ARGV) < 7) {
    printUsage();
}

use Flat;

my $title = shift @ARGV;
my $out = pop @ARGV;

if(scalar(@ARGV) % 6 != 0) {
    printUsage();
}

my $rscript = "$out.r";

open R, "+>$rscript" or die $!;

print R "png(\"$out\")\n";

my @mins;
my @maxs;
my $range = '';

# prepare range, ylim, title, etc.
for(my($i) = 0; $i < scalar(@ARGV); $i += 6) {
    my $fname = $ARGV[$i];
    my $file = Flat->new1($fname);
    my $fld1 = $file->getFieldIndex($ARGV[$i + 1]);
    my $fldName1 = $ARGV[$i + 2];
    my $fld2 = $file->getFieldIndex($ARGV[$i + 3]);
    my $fldName2 = $ARGV[$i + 4];
    my $color = $ARGV[$i + 5];
#    my @fvals1 = $file->getFieldValues($fld1);
    my $numOfRows = $file->getNumOfRows();
#    push @mins, math::util::getMin(@fvals);
#    push @maxs, math::util::getMax(@fvals);

    my $fout = "$fname.$fld1.$fld2";
    Util::run("extractColumns.pl $fname '$fld1|$fld2' $fout", 1);

    print R "x$i<-as.matrix(read.table(\"$fout\", header=TRUE))\n";

#    $title .= "\\\n$fldName2 ~ $fldName1 ($color, $numOfRows)";

    if($i == 0) {
#	$range = "ran<-range(density(x$i)\$y";
    }
    else {
#	$range .= ",density(x$i)\$y";
    }
}

#$range .= ")";
#my $ylim = "c(min(ran), max(ran))";

#print R "$range\n";

# plot it
for(my($i) = 0; $i < scalar(@ARGV); $i += 6) {
    my $fname = $ARGV[$i];
    my $file = Flat->new1($fname);
    my $fld1 = $file->getFieldIndex($ARGV[$i + 1]);
    my $fldName1 = $ARGV[$i + 2];
    my $fld2 = $file->getFieldIndex($ARGV[$i + 3]);
    my $fldName2 = $ARGV[$i + 4];
    my $color = $ARGV[$i + 5];

    if($i == 0) {
#	my $min = math::util::getMin(@mins);
#	my $max = math::util::getMax(@maxs);
	print R "plot(x$i\[,1], x$i\[,2], col=\"$color\", xlab=\"$fldName1\", ylab=\"$fldName2\", main=\"$title\")\n";
    }
    else {
	print R "points(x$i\[,1], x$i\[,2], col=\"$color\")\n";
    }
}

print R "dev.off()\n";

close R;

`R --no-save < $rscript`;
#`xview $out`;
