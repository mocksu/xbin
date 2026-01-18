#!/usr/bin/perl -w

if((@ARGV) != 2) {
    print "Usage: ~ <coords.csv> <result.genes>\n";
    print "e.g.: ~ c12t2.58-.csv c12t2.58-.genes\n";
    exit;
}

my($urlstem) = "http://genome.ucsc.edu/cgi-bin";
my($javacmd) = "/usr/local/j2sdk/bin/java mxu.html.HTTPUtil";

my(%gene2url, %gene2title, %gene2coord);

open F, "<$ARGV[0]" || die $!;
open OUT, "+>$ARGV[1]" || die $!;

while($line = <F>) {
    chomp($line);

    @data = split(/\s+/, $line);
    $chr = $data[0];
    $start = $data[1];
    $end = $data[2];

    my($g2u, $g2t, $g2c) = &getKnownGenes($chr, $start, $end);

    if(scalar(keys %{$g2u}) > 0) {
	map {
	    $gene2url{$_} = $g2u->{$_}; 
	    $gene2title{$_} = $g2t->{$_}; 
	    $gene2coord{$_} = $line; #$g2c->{$_};
	    my($desc, $refseqsum, $pwname, $pwexp) = extractGeneInfo($gene2url{$_});
	    print OUT "$line\t$gene2title{$_}\t$desc\t$refseqsum\t$pwname\t$pwexp\n";	
	} keys %{$g2u};
	
	if(++$count % 5 == 0) {
	    print "checking region $count\n";
#	last;
	}
    }
    else { # no genes found
	print OUT "$line\t \t \t \t \t \n";	
    }
}

close F;
close OUT;

#foreach $g (keys %gene2url) {
#    my $coord = $gene2coord{$g};
#    print OUT "$coord\t$gene2title{$g}\t$desc\t$refseqsum\t$pwname\t$pwexp\n";
#    print OUT $coord->[0], "\t", $coord->[1], "\t", $coord->[2], "\t$g\t$gene2title{$g}\t$desc\t$refseqsum\t$pwname\t$pwexp\n";
#}

#close OUT;

sub extractGeneInfo {
    my($url) = @_;

#    print "extractGeneInfo: url = $url\n";

    my $content = `$javacmd \"$url\"`;
#    print "content = ($content)\n";

    #<B>Description:</B> tumor-suppressing subtransferable candidate 6<BR><B>
    my $desc = '';
    if($content =~ /<B>Description:<\/B>(.+?)<BR><B>/s) {
	$desc = $1;
    }

    print "desc = $desc\n";

    my $refseqsum = '';
    if($content =~ /<B>RefSeq Summary:<\/B>(.+?)<BR>/s) {
	$refseqsum = $1;
    }

    my $pwname = '';
    my $pwexp = '';
    
    if($content =~ /Biochemical and Signalling Pathways.+?TARGET=_blank>(.+?)<\/A>(.+?)<BR>/s) {
	$pwname = $1;
	$pwexp = $2;
    }

    print "pwname = $pwname, pwexp = $pwexp\n";

    return ($desc, $refseqsum, $pwname, $pwexp);
}

sub getKnownGenes {
    my($chr, $start, $end) = @_;
    
#    print "chr = $chr, start = $start, end = $end\n";
#http://genome.ucsc.edu/cgi-bin/hgTracks?clade=vertebrate&org=Human&db=hg16&position=chr4%3A56%2C214%2C201-56%2C291%2C736&pix=480&hgsid=59151588&Submit=submit
    my($cmd) = "$javacmd \"$urlstem/hgTracks?clade=vertebrate&org=Human&db=hg17&position=chr$chr%3A$start-$end&pix=480&hgsid=59151588&Submit=submit\"";

#    print "cmd = $cmd\n";

    my $html = `$cmd`;

#    print "html = $html\n";

    my(@lines) = split(/\n/, $html);

    my(%gene2url, %gene2title, %gene2coord);

    foreach $l (@lines) {
#HREF="../cgi-bin/hgGene?hgsid=59136659&db=hg17&hgg_gene=NM_002817&hgg_chrom=chr11&hgg_start=226976&hgg_end=242981&hgg_type=knownGene"  TITLE="PSMD13"
	if($l =~ /HREF=\"(.+?hgg_gene=(.+?)\&.+?hgg_type=knownGene)\"  TITLE=\"(.+?)\"/) {
	    print "match found: gene = $2, title = $3\n";
	    $gene2url{$2} = "$urlstem/$1";
	    $gene2title{$2} = $3;
	    $gene2coord{$2} = [$chr, $start, $end];
	    $gene2url{$2} =~ s/cgi\-bin\/\.\.\/cgi\-bin/cgi\-bin/;
	}
    }

    return (\%gene2url, \%gene2title, \%gene2coord);
}
    
