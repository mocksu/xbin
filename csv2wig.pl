#!/usr/bin/perl -w

if(scalar(@ARGV) < 7) {
    print "Convert csv to bed formated wiggle file like:\n";
    print "chrom chromStart chromEnd dataValue\n\n";
    print "Usage: ~ <in.csv> <chrFld> <startFld> <endFld> <valFld> name=<name> <parameter1=val1> ... <parameterN=valN> <out.wig>\n\n";

print<<OUT;
All options are placed in a single line separated by spaces:

  track type=wiggle_0 name=track_label description=center_label
        visibility=display_mode color=r,g,b altColor=r,g,b
        priority=priority autoScale=on|off
        gridDefault=on|off maxHeightPixels=max:default:min
        graphType=bar|points viewLimits=lower:upper
        yLineMark=real-value yLineOnOff=on|off
        windowingFunction=maximum|mean|minimum smoothingWindow=off|2-16

(Note if you copy/paste the above example, you have to remove the carriage returns.)
The track type with version is REQUIRED, and it currently must be wiggle_0:

  type wiggle_0

The remaining values are OPTIONAL:

  name              trackLabel           # default is "User Track"
  description       centerlabel          # default is "User Supplied Track"
  visibility        full|dense|hide      # default is hide (will also take numeric values 2|1|0)
  color             RRR,GGG,BBB          # default is 255,255,255
  altColor          RRR,GGG,BBB          # default is 128,128,128
  priority          N                    # default is 100
  autoScale         on|off               # default is off
  gridDefault       on|off               # default is off
  maxHeightPixels   max:default:min      # default is 128:128:11
  graphType         bar|points           # default is bar
  viewLimits        lower:upper          # default is range found in data
  yLineMark         real-value           # default is 0.0
  yLineOnOff        on|off               # default is off
  windowingFunction maximum|mean|minimum # default is maximum
  smoothingWindow   off|[2-16]           # default is off
OUT
    exit(1);
}

use Util;
use Flat;

my($in) = Flat->new1(shift @ARGV);
my $chrIndex = $in->getFieldIndex(shift @ARGV);
my $startIndex = $in->getFieldIndex(shift @ARGV);
my $endIndex = $in->getFieldIndex(shift @ARGV);
my $valIndex = $in->getFieldIndex(shift @ARGV);
my $name = shift @ARGV;
my($out) = pop @ARGV;
my @para = @ARGV;

open OUT, "+>$out" or die $!;

print OUT "track type=wiggle_0 $name @para\n";

my($chr, $span);

while($row = $in->readNextRow()) {
    print OUT join("\t", $row->[$chrIndex], $row->[$startIndex], $row->[$endIndex], $row->[$valIndex]), "\n";
}

close OUT;
