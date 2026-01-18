#!/usr/bin/perl

if(scalar(@ARGV) != 4) {
    print "Usage: ~ <RE_FileNames> <field_index> <RE_FieldValues> <CheckOnly>\n\n";
    print "\tfield_index\t0 based\n";
    print "\tCheckOnly\t1 print out files to be removed;\n";
    print "\t         \t0 remove files\n";
    print "\tYou had ", scalar(@ARGV), " arguments: @ARGV\n\n";
    exit(1);
}

my($fldNames) = $ARGV[0];
my($fldIndex) = $ARGV[1];
my($valPtn) = $ARGV[2];
my($checkOnly) = $ARGV[3];

use Util;

my(@files) = `ls -l $fldNames`;

foreach $file (@files) {
    my(@fvals) = split(/\s+/, $file);

    if($fvals[$fldIndex] =~ /$valPtn/) {
	if($checkOnly) {
	    print "To be removed: $file";
	}
	else {
	    Util::run("rm -rf $fvals[8]", 1);
	  }
    }    
}
