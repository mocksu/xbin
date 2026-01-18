#!/usr/bin/perl -w

if(scalar(@ARGV) != 2 && scalar(@ARGV) != 1) {
    print "Convert the specified flat file into html table\n";
    die "Usage: ~ <in.csv> [with_header]\n";
}

use Flat;

my($file);

if(scalar(@ARGV) == 2) {
    $file = Flat->new($ARGV[0], $ARGV[1]);
}
else {
    $file = Flat->new1($ARGV[0]);
}

print "<table border=1>\n";

if($file->hasHeader()) {
    my(@fldNames) = $file->getFieldNames();

    print "<tr>";

    foreach $fn (@fldNames) {
	print "<th>$fn</th>";
    }

    print "</tr>\n";
}

my(@data) = $file->getDataArray();
my($numOfCols) = $file->getNumOfColumns();

for(my($i) = 0; $i < scalar(@data); $i++) {
    print "<tr>";

    for(my($j) = 0; $j < $numOfCols; $j++) {
	print "<td>$data[$i][$j]</td>";
    }

    print "</tr>\n";
}

print "</table>\n";
