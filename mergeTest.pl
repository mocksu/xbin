#!/usr/bin/perl -w

my($file1) = "test/sp1_10.csv";
my($file2) = "test/sp3_10.csv";
my($out) = "/tmp/mergeTest.out";

use Flat;
use Util;

my($cmd) = "merge.pl $file1 $file2 $out";
Util::run($cmd);

my($outFile) = Flat->new($out, 1);

my(@fldNames) = $outFile->getFieldNames();

my(@data) = $outFile->getDataArray();

use XTest;
my(@expected) = ("test/sp1_10.csv:chr", "test/sp1_10.csv:start", "test/sp1_10.csv:end", "test/sp1_10.csv:sp1_hct116", "test/sp1_10.csv:max", "test/sp1_10.csv:#_in_cluster", "test/sp1_10.csv:test/sp3_10.csv:length_overlap", "test/sp1_10.csv:test/sp3_10.csv:intensity_overlap");

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $fldNames[$i]);
}

@expected = (1, 148387335, 148387499, 22.6823, 6.7894, 4, 0, 0);

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $data[0][$i]);
}

@expected = (1, 148388057, 148388145, 24.1739, 17.1239, 2, 89, 21.1542);

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $data[1][$i]);
}

@expected = (1,	148388171, 148388297, 26.0742, 12.7328, 3, 127, 30.8621886699507);

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $data[2][$i]);
}

@expected = (1, 148443727, 148443815, 13.7579, 8.8216, 2, 89, 9.5474);

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $data[3][$i]);
}

# the last row of the 
@expected = (1, 148470873, 148471099, 17.9184, 6.5256, 3, 169, 29.7169414255959);

for(my($i) = 0; $i < (@expected); $i++) {
    XTest::assertEquals($expected[$i], $data[8][$i]);
}

XTest::reportTestResults();
