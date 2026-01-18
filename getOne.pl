#!/usr/bin/perl -w

if(scalar(@ARGV) != 3) {
    print "Usage: ~ <url> <level> <dir>\n";
    exit(1);
}

my($url) = $ARGV[0];
my($level) = $ARGV[1];
my($dir) = $ARGV[2];

`wget -k -p -H -nc -c -x -r -np -A BBS*interest*,*ID=[0-9]*,html,htm,.jpg,.jpeg,.JPG,.Jpg,.gif,.GIF,.Gif -l $level -P $dir $url`;
