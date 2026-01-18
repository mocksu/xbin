#!/usr/bin/perl -w

if(scalar(@ARGV) != 4) {
    print "Make each of the specified field numerical by converting the regulation expressions into the specified values\n\n";
    print "The matched $1 in the regular expression will be replaced by the corresponding val\n";
    print "Usage: ~ <in.csv> \"re1:val1|...|ren:valn\" \"fld1|...|fldn\" <out.csv>\n";
    print "e.g.   ~ /tmp/t.csv '^\\d+(\\-)\\d+\$:\\.|^(\\.)\$:NA|^(\\s*)\$:NA' 0-120 /tmp/t1.csv\n\n";
    exit(1);
}

use Flat;
use Util;

my($in) = Flat->new(shift @ARGV, 1);
my(@replaces) = split(/\|/, shift @ARGV);
my(@findice) = $in->getFieldIndice([split(/\|/, shift @ARGV)]);
my($out) = shift @ARGV;

my(@res, @vals);

for(my($i) = 0; $i < scalar(@replaces); $i++) {
    ($res[$i], $vals[$i]) = split(/\:/, $replaces[$i]);
}

open OUT, "+>$out.tmp" or die "Cannot open $out";

my(@fnames) = $in->getFieldNames();

print OUT join("\t", @fnames), "\n";

while($row = $in->readNextRow()) {
    my @rdata = @{$row};

    foreach $fi (@findice) {
	for(my($i) = 0; $i < scalar(@res); $i++) {
#	    print "res[$i] = $res[$i]\n";
	    if($rdata[$fi] =~ /$res[$i]/) {
#		print "matched: $rdata[$fi]\n";
		$rdata[$fi] =~ s/$1/$vals[$i]/;
	    }
	    # else no change
	}
    }

    print OUT join("\t", @rdata), "\n";
}

close OUT;

Util::run("mv $out.tmp $out", 0);
