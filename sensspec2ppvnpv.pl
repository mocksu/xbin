#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "IT IS NOT IMPLEMENTED YET!!!\n";
    print "Convert precision/recall into sensitivity and specificity\n\n";
    print "Usage: ~ <sens> <spec> <proportion of cases>\n\n";
    print "e.g.   ~ 0.66 0.66 0.33\n\n";
    exit(1);
}

use Flat;

my $sens = shift @ARGV;
my $spec = shift @ARGV;
my $prev = shift @ARGV; # prevalence

# precision = tp / (tp + fp)
# recall = tp / (tp + fn) = sensitivity
# accuracy = (tp + tn) / (tp + tn + fp + fn)
# prev = (tp + fn) / (tp + tn + fp + fn)
# sens = tp / (tp + fn)
# spec = tn / (tn + fp)
# ppv = tp / (tp + fp) = sens * prev / (sens * prev + (1-spec)*(1-prev))
# npv = tn / (tn + fn) = spec * (1-prev) / (spec * (1-prev) + (1-sens)*prev);

my $ppv = $sens * $prev / ($sens * $prev + (1-$spec)*(1-$prev));
my $npv = $spec * (1-$prev) / ($spec * (1-$prev) + (1-$sens)*$prev);

print "sensitivity = $sens, specificity = $spec, prevalance = $prev\n";
print "PPV = $ppv, NPV = $npv\n\n";

