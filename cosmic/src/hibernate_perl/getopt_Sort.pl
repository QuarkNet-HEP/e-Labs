#!/usr/bin/perl

#this script is used to sort numerical data files

use Getopt::Long;

if($#ARGV < 2){
	die "usage: $0 -in [input-file] -out [output-file] -col1 [1st column sorting for (start at #1)] -col2 [2nd column sorting for]\n";
}

my %h = ();
my $result = GetOptions(\%h, 'in=s', 'out=s', 'col1=i', 'col2=i');

use Digest::MD5 qw(md5_hex);

#md5 input/output file comparison
my $infile = $h{'in'};
my $ofile = $h{'out'};
my $arg_str = join " ", @ARGV[0..$#ARGV];
my $mtime1 = (stat($0))[9];         #this script's timestamp
my $mtime2 = (stat($infile))[9];    #input file's timestamp
$arg_str = "$mtime1 $mtime2 $arg_str";
my $md5 = md5_hex($arg_str);
if(-e $ofile){
    $outmd5 = `head -n 1 $ofile`;
    $outmd5 = substr($outmd5, 1);
    chomp $outmd5;
    print "md5s COMPUTED:$md5 FROMFILE:$outmd5\n";
    if($md5 eq $outmd5){
        print "input argument md5's match, not re-calculating output file: $ofile\n";
        exit;
    }
}


if(defined($h{'col2'})){
	$col2 = " -k $h{'col2'},$h{'col2'} ";
}
else{
	$col2 = "";
}

$fileinput = $h{'in'};
$outputfile = $h{'out'};
$column1 = $h{'col1'};

if(-x "/opt/sort/sort-2.0/bin/sort"){
    $sort_file = "/opt/sort/sort-2.0/bin/sort";
}
else{
    $sort_file = "sort";
}
`$sort_file -n -k $column1,$column1 $col2 -o $outputfile $fileinput`;
#since sort removes comments, we have to re-add the md5 header
#3-21-05: removed since Tie::File doesn't work on blacknuss
#use Tie::File;
#tie my @file, "Tie::File", $outputfile;
#unshift @file, "#md5_hex($arg_str)\n";
#unshift @file, "#$md5\n";
