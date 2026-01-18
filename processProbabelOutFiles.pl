#!/usr/bin/perl

use strict;
use constant PI => 3.1415926536;
use constant SIGNIFICANT => 5;

sub precision {
	my ($x) = @_;
	return abs int(log10(abs $x) - SIGNIFICANT);
}

sub precision_string {
	my ($x) = @_;
	if ($x) {
		return sprintf "%." . precision($x) . "f", $x;
	} else {
		return "0";
	}
}
sub chisqrdistr { # Percentage points  X^2(x^2,n)
	my ($n, $p) = @_;
	if ($n <= 0 || abs($n) - abs(int($n)) != 0) {
		die "Invalid n: $n\n"; # degree of freedom
	}
	if ($p <= 0 || $p > 1) {
		die "Invalid p: $p\n"; 
	}
	return precision_string(_subchisqr($n, $p));
}

sub _subfprob {
	my ($n, $m, $x) = @_;
	my $p;

	if ($x<=0) {
		$p=1;
	} elsif ($m % 2 == 0) {
		my $z = $m / ($m + $n * $x);
		my $a = 1;
		for (my $i = $m - 2; $i >= 2; $i -= 2) {
			$a = 1 + ($n + $i - 2) / $i * $z * $a;
		}
		$p = 1 - ((1 - $z) ** ($n / 2) * $a);
	} elsif ($n % 2 == 0) {
		my $z = $n * $x / ($m + $n * $x);
		my $a = 1;
		for (my $i = $n - 2; $i >= 2; $i -= 2) {
			$a = 1 + ($m + $i - 2) / $i * $z * $a;
		}
		$p = (1 - $z) ** ($m / 2) * $a;
	} else {
		my $y = atan2(sqrt($n * $x / $m), 1);
		my $z = sin($y) ** 2;
		my $a = ($n == 1) ? 0 : 1;
		for (my $i = $n - 2; $i >= 3; $i -= 2) {
			$a = 1 + ($m + $i - 2) / $i * $z * $a;
		} 
		my $b = PI;
		for (my $i = 2; $i <= $m - 1; $i += 2) {
			$b *= ($i - 1) / $i;
		}
		my $p1 = 2 / $b * sin($y) * cos($y) ** $m * $a;

		$z = cos($y) ** 2;
		$a = ($m == 1) ? 0 : 1;
		for (my $i = $m-2; $i >= 3; $i -= 2) {
			$a = 1 + ($i - 1) / $i * $z * $a;
		}
		$p = max(0, $p1 + 1 - 2 * $y / PI
			- 2 / PI * sin($y) * cos($y) * $a);
	}
	return $p;
}
sub _subchisqrprob {
	my ($n,$x) = @_;
	my $p;

	if ($x <= 0) {
		$p = 1;
	} elsif ($n > 100) {
		$p = _subuprob((($x / $n) ** (1/3)
				- (1 - 2/9/$n)) / sqrt(2/9/$n));
	} elsif ($x > 400) {
		$p = 0;
	} else {   
		my ($a, $i, $i1);
		if (($n % 2) != 0) {
			$p = 2 * _subuprob(sqrt($x));
			$a = sqrt(2/PI) * exp(-$x/2) / sqrt($x);
			$i1 = 1;
		} else {
			$p = $a = exp(-$x/2);
			$i1 = 2;
		}

		for ($i = $i1; $i <= ($n-2); $i += 2) {
			$a *= $x / $i;
			$p += $a;
		}
	}
	return $p;
}sub _subuprob {
	my ($x) = @_;
	my $p = 0; # if ($absx > 100)
	my $absx = abs($x);

	if ($absx < 1.9) {
		$p = (1 +
			$absx * (.049867347
			  + $absx * (.0211410061
			  	+ $absx * (.0032776263
				  + $absx * (.0000380036
					+ $absx * (.0000488906
					  + $absx * .000005383)))))) ** -16/2;
	} elsif ($absx <= 100) {
		for (my $i = 18; $i >= 1; $i--) {
			$p = $i / ($absx + $p);
		}
		$p = exp(-.5 * $absx * $absx) 
			/ sqrt(2 * PI) / ($absx + $p);
	}

	$p = 1 - $p if ($x<0);
	return $p;
}
sub log10 {
	my $n = shift;
	return log($n) / log(10);
}
 
sub chisqrprob { # Upper probability   X^2(x^2,n)
	my ($n,$x) = @_;
	if (($n <= 0) || ((abs($n) - (abs(int($n)))) != 0)) {
		die "Invalid n: $n\n"; # degree of freedom
	}
	return precision_string(_subchisqrprob($n, $x));
}

if(@ARGV!=3){
    print "Usage: processProbabelOutFiles.pl directory fileNamesFile outFile\n"
		."directory: where ProbABEL output files live;\n"
		."fileNamesFile: a file contains ProbABEL files to be merged (per filename per low)\n"
		."outFile: merged result file (sorted by last column - P values)\n\n";
    exit(0);
}
my ($dir,$filename,$outfile)=@ARGV;
unless(-e $dir){
	print "$dir does not exists. EXIT!\n";
	exit(0);
}
$dir=~s/\/$//;
print "under $dir\n";
$filename=(split/\//,$filename)[-1];
open(FN,"< $dir/$filename") || die "$dir/$filename not found. EXIT!\n";
my @files=();
my $line="";
while($line=<FN>){
	chomp($line);
	$line=~s/\r//;
	unless(-e "$dir/$line"){
		print "$dir/$line not found. EXIT!\n";
		close(FN);
		exit(0);
	}
	push(@files,$line);
}
close(FN);
open(OUT,"> $outfile.tmp");
my $f=shift(@files);
print "merge $f\n";
open(FH,"< $dir/$f");
$line=<FH>;
chomp($line);
$line=~s/\r//;
my $pcol=(split/\s+/,$line)+1;
print OUT "$line P-value\n";
while($line=<FH>){
	chomp($line);
	$line=~s/\r//;
	my @tmp=split/\s+/,$line;
	if($tmp[-1] ne "nan"){
		my $chisq=chisqrprob(1,$tmp[-1]);
		if($chisq<0.0001){
			print OUT "$line ",sprintf("%.5e\n",$chisq);
		}else{
			print OUT "$line ",sprintf("%.5f\n",$chisq);
		}
	}
}
close(FH);
foreach my $f (@files){
	print "merge $f\n";
	open(FH,"< $dir/$f");
	$line=<FH>;
	while($line=<FH>){
		chomp($line);
		$line=~s/\r//;
		my @tmp=split/\s+/,$line;
		if($tmp[-1] ne "nan"){
			my $chisq=chisqrprob(1,$tmp[-1]);
			if($chisq<0.0001){
				print OUT "$line ",sprintf("%.5e\n",$chisq);
			}else{
				print OUT "$line ",sprintf("%.5f\n",$chisq);
			}
		}
	}
	close(FH);
}
close(OUT);
print "\nsort by P-values ($pcol"."th column)\n\n";
$line="sort -t \" \" -g -k".$pcol.",".$pcol." $outfile.tmp > $outfile";
system($line);
system("rm $outfile.tmp");
