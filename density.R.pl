#!/usr/bin/perl -w

sub printUsage() {
    print "Usage: ~ [-o opColumn.pl operation] <title> <in1.csv> <fld1> <color1> <name1>... <inN.csv> <fldN> <colorN> <nameN> <out.png>\n";
    exit(1);
}

if(scalar(@ARGV) < 6) {
    printUsage();
}

use Flat;

use Getopt::Std;

my(%options);
getopts("o:", \%options);
my $op = (exists $options{"o"})?$options{"o"}:"";

my $title = shift @ARGV;
my $out = pop @ARGV;

if(scalar(@ARGV) % 4 != 0) {
    printUsage();
}

my $rscript = "$out.r";

open R, "+>$rscript" or die $!;

print R "jpeg(\"$out\")\n";

my @mins;
my @maxs;
my $range = '';
my(@fldFiles);

# prepare range, ylim, title, etc.
for(my($i) = 0; $i < scalar(@ARGV); $i += 4) {
    my $fname = $ARGV[$i];
    my $file = Flat->new1($fname);
    my $fldName = $ARGV[$i + 1];
    my $fld = $file->getFieldIndex($fldName);
    my $color = $ARGV[$i + 2];
    my $fldLabel = $ARGV[$i + 3];

    my $fout = "$fname.$fld";

    if($op) { 
	Util::run("opColumns.pl $fname '$op' $fldName $fldName.op $fout", 1);
	  Util::run("extractColumns.pl $fout '$fldName.op:$fldName' $fout", 1);  
    }
    else {
	Util::run("extractColumns.pl $fname $fld $fout", 1);
      }

    my @fvals = Flat->new1($fout)->getFieldValues($fldName);

    my $numOfRows = scalar(math::util::removeNaN(@fvals));
    push @mins, math::util::getMin(@fvals);
    push @maxs, math::util::getMax(@fvals);

    push @fldFiles, $fout;

    print R "x$i<-as.matrix(read.table(\"$fout\", header=TRUE))\n";

    $title .= "\\\n$fldLabel ($color, $numOfRows)";

    if($i == 0) {
	$range = "ran<-range(density(x$i, na.rm=TRUE)\$y";
    }
    else {
	$range .= ",density(x$i, na.rm=TRUE)\$y";
    }
}

$range .= ")";
my $ylim = "c(min(ran), max(ran))";

print R "$range\n";

my $min = math::util::getMin(@mins);
my $max = math::util::getMax(@maxs);

# plot it
for(my($i) = 0; $i < scalar(@ARGV); $i += 4) {
    my $fname = $ARGV[$i];
    my $file = Flat->new1($fname);
    my $fld = $file->getFieldIndex($ARGV[$i + 1]);
    my $color = $ARGV[$i + 2];

    if($i == 0) {
	print R "plot(density(x$i, from=$min, to=$max, na.rm=TRUE), ylim=$ylim, col=\"$color\", main=\"$title\")\n";
    }
    else {
	print R "lines(density(x$i, from=$min, to=$max, na.rm=TRUE), col=\"$color\")\n";
    }
}

print R "dev.off()\n";

close R;

`R --no-save < $rscript`;
#`xview $out`;
`rm $rscript`;
map { `rm $_`; } @fldFiles;
