#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Getopt::Long;

use Data::Dumper;

sub root2hex(\$) {
    my $color = $_[0];

    if ( $color == 2 ) {
	return '#FF0000'; # Red
    } elsif ( $color == 3 ) {
	return '#00FF00'; # Green
    } elsif ( $color == 4 ) {
	return '#0000FF'; # Blue
    } elsif ( $color == 1 ) {
	return '#000000'; # Black
    } elsif ( $color == 10 ) {
	return '#FFFFFF'; # White
    } elsif ( $color == 5 ) {
	return '#FFFF00'; # Yellow
    } elsif ( $color == 6 ) {
	return '#FF00FF'; # Purple
    } else {
	return '';        # No color
    }
    return;
}

my $path;
my $printURL    = 0;
my $printArrays = 0;

Getopt::Long::Configure ('no_ignore_case');
GetOptions(
    'path|p=s'  => \$path,
    'url|u'     => \$printURL,
    'arrays|a'  => \$printArrays
    );

open(URL, "<$path");
my $url = <URL>;

my @temp = split(/\?/,$url);
$url = $temp[0];
my $index = index($url, "cgi");
$url = substr($url, 0, $index);

my $encoded = $temp[1];
my @varlist = split(/;/,$encoded);

my @leafID;
my @color;
my @opts;
my @triggers;
my @holders;

my $size = "";
my $width;
my $height;

for ( my $i=0; $i<=$#varlist; $i++ ) {
    my @temp = split(/=/,$varlist[$i]);
    my $var = $temp[0];
    my $val = $temp[1];
    if ( $val ) {
	chomp($val);
    }

    if ( $var eq "dataset" ) {
	$url .= "ogre.php?dataset=$val&restore";

    } elsif ( $var eq "leaf" ) {
	push(@leafID,"'leaf" . $val . "'");

    } elsif ( $var eq "color" ) {
	push(@color, "'" . &root2hex($val) . "'");

    } elsif ( $var eq "gWidth" ) {
	$width = $val;

    } elsif ( $var eq "gHeight" ) {
	$height = $val;

    } elsif ( $var eq "logx" ) {
	push(@opts, "'logx'");

    } elsif ( $var eq "logy" ) {
	push(@opts,"'logy'");

    } elsif ( $var eq "gcut" ) {
	push(@opts, "'gcut'");

    } elsif ( $var eq "savedata" ) {
	push(@opts, "'savedata'");

    } elsif ( $var eq "type" ) {
	push(@opts, "'type'");
	push(@opts, "'$val'");

    } elsif ( $var eq "triggers" ) {
	push(@triggers, "'" . CGI::unescape($val) . "'");

    } elsif ( $var eq "holders" ) {
	push(@holders, "'$val'");
    }
}

$size = $width . "x" . $height;
push(@opts, "'size'");
push(@opts, "'$size'");

if ( $printURL ) {
    print $url, "\n";
}
if ( $printArrays ) {
    print "  var triggers = new Array( " . join(",", @triggers) . " );\n";
    print "  var holder   = new Array( " . join(",",@holders)   . " );\n";
    print "  var plots    = new Array( " . join(",",@leafID)    . " );\n";
    print "  var color    = new Array( " . join(",", @color)    . " );\n";
    print "  var opts     = new Array( " . join(",", @opts)     . " );\n";
}
exit 0;
