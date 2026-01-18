#!/usr/bin/perl -w

use Flat;
use Text;
use Util;

my $in = Text->new($ARGV[0], "<tr>");

my(@entries) = $in->readEntries();

shift @entries; # throw away the first "entry"

foreach $e (@entries) {
#    print "e = -----$e", "-----\n";

    my(@cells) = split(/\<td/, $e, -1);

    shift @cells; # throw away the first "cell"

    my(@row);

    foreach $c (@cells) {
#	print "0 c = -----$c", "-----\n";
	$c = "<td".$c;

	# throw away <...>
	$c =~ s/<.+?>//sg;
#	print "1 c = -----$c", "-----\n";

	$c = Util::trim($c);

	push @row, $c;
    }

    print Flat::dataRowToString(@row), "\n";

#    die;
}
    
	
    

