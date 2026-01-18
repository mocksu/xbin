#!/usr/bin/perl -w

use Flat;
use Getopt::Std;

my(%options);
getopts("lf:", \%options);

if(scalar(@ARGV) < 4) {
    print "Usage: ~ [-l] [-f field] <in.csv> <windowSize> <statFld1> ... <statFldN> <out.csv>\n";
    print "       l\tnegative log transfer the stat fields. Default is to use the original\n";
    print "       f\tthe field the window size counting is used.\n";
    print "       windowSize\tthe number of entries or the absolute difference in the field specified by \"f\"\n";    
    exit(1);
}

use Flat;

my($in) = Flat->new(shift @ARGV, 1);
my $size = shift @ARGV;
my($out) = pop @ARGV;
my @sflds = map { $in->getFieldIndex($_); } @ARGV;

my $numFlds = $in->getNumOfFields();
my %isSfld; map { $isSfld{$_} = 1; } @sflds;
my $wfld = exists $options{"f"}?$in->getFieldIndex($options{"f"}):-1;
my $log = exists $options{"l"}?1:0;

my(@fnames) = $in->getFieldNames();
open OUT, "+>$out" or die "Cannot open $out\n";
print OUT join("\t", @fnames), "\n";

my @entries = ();

while($row = $in->readNextRow()) {
    ### check if the @entries contains enough entries

    # if it's the simple entry count window size
    if($wfld == -1) {
	if(scalar(@entries) == $size) { # enough size
	    # print this window out
	    _printWindow(@entries);

	    shift @entries; # slide the window by one
	}
	# not enough size, continue

	push @entries, $row;
    }
    else { # specified field difference window size
	if($row->[$wfld] - $entries[0][$wfld] > $size) { # adding $row to @entries would make the window too big
	    _printWindow(@entries);

	    shift @entries; # slide the window by one
	}
	# window is not overfit, add the $row

	push @entries, $row;
    }
}

# print the last window if it's not printed out yet
_printWindow(@entries);

sub _printWindow {
    my(@ents) = @_;

    # print this window out
    my $midEntry = $ents[int($size/2)];
    my @row = ();

    for(my($i) = 0; $i < $numFlds; $i++) {
	if(exists $isSfld{$i}) { # stat field
	    if($log) { # log transfer
		push @row, math::util::getMean(map { if(math::util::isNumeric($_->[$i])) { -log($_->[$i]);} else {"NA";}} @ents);
	    }
	    else { # original
		push @row, math::util::getMean(map { $_->[$i] } @ents);
	    }
	}
	else { # not a stat field, use the middle entry info
	    push @row, $midEntry->[$i];
	}
    }
    
    print OUT join("\t", @row), "\n";
}
