#!/usr/bin/perl -w

my($file1) = "test/sp1_10.csv";
my($file2) = "test/sp3_10.csv";
my($out) = "/tmp/mergeTest.out";

use math;
use XTest;

my(@arr) = ("test/sp1_10.csv:chr", "test/sp1_10.csv:start", "test/sp1_10.csv:end", "test/sp1_10.csv:sp1_hct116", "test/sp1_10.csv:max", "test/sp1_10.csv:#_in_cluster", "test/sp1_10.csv:test/sp3_10.csv:length_overlap", "test/sp1_10.csv:test/sp3_10.csv:intensity_overlap");

testCovar(@arr);

XTest::reportTestResults();

sub testCovar {
    my(@original) = @_;
    

    XTest::assertFalse($same);
}
