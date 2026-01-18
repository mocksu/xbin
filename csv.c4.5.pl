#!/usr/bin/perl -w

if(scalar(@ARGV) < 4) {
    print "Usage: ~ <train_pct> <input.csv> <label_field_index> <predictor_field1_index> ... <predictor_fieldn_index>\n";
    exit(1);
}

use Util;
use AI::DecisionTree::c45;

my($fstem, $treeAcc, $trnAcc, $tstAcc) = c45::getTrainTestAccuracies(@ARGV);

print "Tree Accuracy: $treeAcc\nTrain Accuracy: $trnAcc\nTest Accuracy: $tstAcc\n";
