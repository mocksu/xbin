#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    die " ~ <in.csv> <fld_no> <num_categories>\n";
}

my($in) = $ARGV[0];
my($fld) = $ARGV[1];
my($cat) = $ARGV[2];
my($fldName, $fldNum);

use math;
use Flat;

my($inFile) = Flat->new($in, 1);

if(math::util::isNaN($fld)) {
    $fldName = $fld;
    $fldNum = $inFile->getFieldIndex($fldName);
}
else {
    $fldName = $inFile->getFieldName($fld);
    $fldNum = $fld;
}

my($out) = "/tmp/t$fld.$cat.csv";
my($upin) = "/tmp/t$fld.$cat"."up.csv"; # unique (no duplicates) output
my($usin) = "/tmp/t$fld.$cat"."us.csv"; # unique (no duplicates) output

# discretize
if($cat != -1) {
    `discretize.pl $in $fldNum $cat $out`;
# average discretized field
    $uout = "/tmp/t$fld"."u.csv"; # unique (no duplicates) output
    `rmDuplicates.pl -s -1 mean $out $fldNum $upin`;
    `rmDuplicates.pl -s -1 median $out $fldNum $usin`;
}
else {
    `cp $in $uout`;
}

# covar.pl
my($sout) = "/tmp/t$fld.$cat.s.csv";
my($pout) = "/tmp/t$fld.$cat.p.csv";
print `covar.pl s $usin $sout`;
print `covar.pl p $upin $pout`;

my($s) = Flat->new($sout, 1);
my($p) = Flat->new($pout, 1);

my(@sfnames) = $s->getFieldNames();
my(@sfldData) = $s->getFieldData($s->getFieldIndex($fldName));
my(@pfldData) = $p->getFieldData($p->getFieldIndex($fldName));

print "$fldName\tSPEARMAN\tPEARSON\n";

for(my($i) = 0; $i < scalar(@sfldData); $i++) {
    print $sfnames[$i + 1], "\t$sfldData[$i]\t$pfldData[$i]\n";
}

    

