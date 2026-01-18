#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "\nMap the input file with the specified mapping rules and output the new data in the specified output file\n\n";
    print "Usage: ~ <in.csv> <map.csv> <out.csv>\n";
    exit(1);
}

use Flat;

my($in) = Flat->new($ARGV[0], 1);
my($map) = $ARGV[1];
my($out) = $ARGV[2];

my(@data) = $in->getDataArray();

my(%out2inIndex, %f2val, @fnames);
open MAP, "<$map" || die $!;

while($line = <MAP>) {
    chomp($line);

    my(@row) = split(/\t/, $line);
    push @fnames, $row[0];

    if(scalar(@row) > 2) {
	die "Wrong format for field mapping: $line\n";
    }
    elsif(scalar(@row) == 2) {
	if($row[1] =~ /^\'(.*?)\'$/) {
	    $f2val{$row[0]} = $1;
	}
	else {
	    @{$out2inIndex{$row[0]}} = map {$in->getFieldIndex($_); } split(/\:/, $row[1]);
	}
    }
    elsif(scalar(@row) == 1) {
	push @{$out2inIndex{$row[0]}}, $in->getFieldIndex($row[0]);
    }
    # else empty line, ignore
}

close MAP;

open OUT, "+>$out" || die $!;
print OUT Flat::dataRowToString(@fnames), "\n";

for(my($i) = 0; $i < scalar(@data); $i++) {
    my(@rdata);

    foreach $fname (@fnames) {
	if(exists $f2val{$fname}) {
	    push @rdata, $f2val{$fname};
	}
	else {
	    my(@findice) = @{$out2inIndex{$fname}};

	    my($fval);

	    if(scalar(@findice) == 0 || (scalar(@findice) == 1 && $findice[0] == -1)) {
		$fval = "NA";
	    }
	    else {
		$fval = $data[$i][$findice[0]];

		for(my($j) = 1; $j < scalar(@findice); $j++) {
		    $fval .= ":$data[$i][$findice[$j]]";
		}
	    }

	    push @rdata, $fval;
	}
    }

    print OUT Flat::dataRowToString(@rdata), "\n";
}

close OUT;
