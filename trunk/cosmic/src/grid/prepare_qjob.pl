#!/usr/bin/perl

use File::Copy;

my %inputs = ();

my $dax_file = $ARGV[0];
$dir = `dirname $dax_file`;
chomp $dir;
open DAX, $dax_file;
open (NEWDAX, ">$dax_file.tmp");
while (<DAX>) {
    s#/usr/local/quarknet-test/portal/cosmic/\d{1,3}/##g;
    #if (/\"(.*\/)(.*thresh)/) {
    #    #if (! defined $threshes{$2}) {
    #    #    $threshes{$2} = 1;
    #    #    copy($1 . $2, $dir . "/" . $2) or die "can't copy thresholdtimes file";
    #    #}
    #    print NEWDAX $` . "\"" . $2 . $';
    #}
    if (/\"((\d{1,})\..*)\" link=\"input\"/) {
        if (! defined $inputs{$1}) {
            $inputs{$1} = 1;
            copy("/usr/local/quarknet-test/portal/cosmic/$2/$1", ".") or die "can't copy split data file";
        }
        print NEWDAX;
    }
    else {
        print NEWDAX;
    }
}
`mv $dax_file.tmp $dax_file`;
