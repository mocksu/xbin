#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Convert precision/recall into sensitivity and specificity\n\n";
    print "Usage: ~ <precision> <recall> <accuracy>\n\n";
    exit(1);
}

use Flat;

my $prec = shift @ARGV;
my $rec = shift @ARGV;
my $acc = shift @ARGV;

# precision = tp / (tp + fp)
# recall = tp / (tp + fn) = sensitivity
# accuracy = (tp + tn) / (tp + tn + fp + fn)

my $spec = math::util::precall2specificity($prec, $rec, $acc);

print "spec = $spec, sens = $rec, enrich = ", $rec/(1-$spec), "\n";


