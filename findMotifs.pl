#!/usr/bin/perl -w

if(scalar(@ARGV) != 6 || ($ARGV[4] ne 'eric' && $ARGV[4] ne 'mo')) {
    print "Usage: ~ <hash_dir> <region.fa> <bin_size> <pattern> <eric|mo> <out_dir>\n";
    die "e.g. ~ human human_promters.fa 20 ^AA eric\n";
}

my($hashDir) = $ARGV[0];
my($region) = $ARGV[1];
my($binSize) = $ARGV[2];
my($ptn) = $ARGV[3];
my($prg) = $ARGV[4];
my($OUT_DIR) = $ARGV[5];

use Peak;

my($T_THRESHOLD) = 3;
my($T_DIFF_THRESHOLD) = 3;
my($COUNT_THRESHOLD) = 20;

my(@all_motifs) = getAllMotifs(8);

my(@motifs);

foreach $m (@all_motifs) {
    if($m =~ /$ptn/) {
	push @motifs, $m;
    }
}

findMotifs($hashDir, $region, $binSize, \@motifs);

# get all possible motifs of certain length (> 1)
sub getAllMotifs {
    my($size) = @_;

    if($size < 2) {
	die "Why do you want me to do so simple stuff?\n";
    }

    my(@result) = ('A', 'T', 'G', 'C');

    for(my($i) = 2; $i <= $size; $i++) {
	my(@seeds) = @result;
	@result = ();

	foreach $seed (@seeds) {
	    push @result, $seed.'A', $seed.'T', $seed.'G', $seed.'C';
	}
    }

    return @result;
}

use Util;
	
sub findMotifs {
    my($hashDir, $region, $binSize, $mtfs) = @_;
    my(@motifs) = @{$mtfs};

    open MOTIFS, ">>$OUT_DIR/sum$ptn.motifs" || die $!;
    open GROVES, ">>$OUT_DIR/dip$ptn.motifs" || die $!;

    foreach $m (@motifs) {
	print "processing motif $m\n";

# get the positive & negative freq distribution
	my($tmp_file, $tmp_out, $hash, $promoters);

	$tmp_file = "$OUT_DIR/$m.txt";
	$tmp_out = "$OUT_DIR/$m.$binSize";

	if($prg eq 'eric') {
	    `perl FindTssOffsets.pl $m $hashDir $region $binSize > $tmp_file`;
	}
	else {
	# count motifs
	    Util::run("countPosMotif.pl $hashDir $m > $tmp_out");
	    Util::run("binIt.pl $tmp_out 0 $binSize 0 > $tmp_file");
	}

#	my($tmp_sum) = "$OUT_DIR/$organism/$m.sum.txt";
	
	open COUNT, "<$tmp_file" || die $!;
#	open SUM, "+>$tmp_sum" || die $!;

	while($line = <COUNT>) {
	    chomp($line);
	    if(!($line =~ /\#/)) {
		last;
	    }
	}
	
	my(@coords, @neg_counts, @sum_counts);

	my($i) = 0;
	
	while($line) {
	    # trim the leading & heading white spaces
	    $line =~ s/^\s+//;
	    $line =~ s/\s+$//;
	    
	    my(@data) = split(/\s+/, $line);
	    $coords[$i] = $data[0];
	    $sum_counts[$i] = $data[1];
	    $neg_counts[$i] = 1000 -$sum_counts[$i]; # negate it to see groves
#	    print SUM "$data[0]\t$data[1]\n";
	    
	    $line = <COUNT>;
	    $i++;
	}
	
	close COUNT;
 
#	close SUM;
	
# find peaks
#    my($out_coords, $out_counts) = getPeakData($tmp_pos);
	my(@sumPeaks) = getPeakScores(\@coords, \@sum_counts, $T_THRESHOLD, $COUNT_THRESHOLD);
	my(@groves) = getPeakScores(\@coords, \@neg_counts, $T_THRESHOLD, $COUNT_THRESHOLD);
#	my($sumMaxScore) = scalar(@sumPeaks) > 0?$sumPeaks[0]->[1]:0;
#	print "sumMaxScore = $sumMaxScore\n";

	my($foundPeak) = 0;

	for(my($i) = 0; $i < scalar(@sumPeaks); $i++) {
	    print MOTIFS "$m\t$coords[$sumPeaks[$i]->[0]->[0]]\t$coords[$sumPeaks[$i]->[0]->[1]]\t$coords[$sumPeaks[$i]->[0]->[2]]\t$sumPeaks[$i]->[1]\n";
	    $foundPeak = 1;
	}

	if($foundPeak) {
	    print MOTIFS "\n";
	}

	my($foundValley) = 0;

	for(my($i) = 0; $i < scalar(@groves); $i++) {
	    print GROVES "$m\t$coords[$groves[$i]->[0]->[0]]\t$coords[$groves[$i]->[0]->[1]]\t$coords[$groves[$i]->[0]->[2]]\t$groves[$i]->[1]\n";
		$foundValley = 1;
	}

	if($foundValley) {
	    print GROVES "\n";
	}

	if(!$foundPeak && !$foundValley) {
#	    `rm $tmp_file`;
	}

	`rm $tmp_out`;
    }
    
    close MOTIFS;
    close GROVES;
}
