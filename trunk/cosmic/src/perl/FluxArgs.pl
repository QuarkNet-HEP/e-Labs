#!/usr/bin/perl

use Getopt::Long;

if($#ARGV < 2){
	print "usage: $0 -in [input-file1] -in [input-file2 ...] -id [board-ID1] -id [board-ID2 ...]";
	print "-pre [output filenames prefix] \n";
	exit 1;
}

my %h = ();
my $result = GetOptions(\%h, 'in=s@', 'id=i@', 'pre=s');

use constant RUNTIME => eval "use Time::SoFar qw( runinterval )" || !$@;

#manualy change these if you wish...
$channel = 1;
$binwidth = 60;

#threshold files will be infile1.thresh infile2.thresh...
@infile = @{$h{'in'}};
@serialNumber = @{$h{'id'}};
$prefix = $h{'pre'};
foreach $k (@infile){
	push @ofile, $k.".thresh";
}
@combine = @ofile;

#rest of the derived files will be $prefix.TR1.TR2.TR3...
$combine_out = $prefix.".combine";
$singlechan_out = $combine_out.".singlechan";
$sort_out = $singlechan_out.".sort";
$flux_out = $sort_out.".flux";
$plot_param = $flux_out.".param";
$plot_png = $flux_out.".png";

while($infile=shift(@infile)){
	$ofile=shift (@ofile);
	$serialNumber=shift (@serialNumber);
	
	#ONLY CALCULATE THRESHOLD FILES IF THEY DONT EXIST
	if(! -e $ofile){
		$TR = "getopt_ThresholdTimes.pl -in $infile -out $ofile -id $serialNumber";
		print "Running: $TR\n";
		`perl $TR`;
		print "ret: $?\n";
        die "Error!\n" if(($? & 256) or ($? & 512));
		if(RUNTIME){
			my $t = runinterval();
			print "Runtime: $t\n";
		}
	}
}
$combineTR = "getopt_Combine.pl ";
foreach $f (@combine){
	$combineTR .= "-in $f ";
}

@TRs = (
"$combineTR-out $combine_out",
"getopt_SingleChannel.pl -in $combine_out -out $singlechan_out -chan $channel",
"getopt_Sort.pl -in $combine_out -out $sort_out -col1 2 -col2 3",
"getopt_Flux.pl -in $sort_out -out $flux_out -bin $binwidth -geo .",
"getopt_Plot.pl -in $flux_out -param $plot_param -svg $plot_png -type 1 -lowx \"06/03/2005 13:46\" -highx \"06/06/2005 13:43\""
);

#loop through all TRs and execute
while($TR = shift(@TRs)){
	print "Running: $TR\n";
	`perl -w $TR`;
	print "ret: $?\n";
	die "Error!\n" if(($? & 256) or ($? & 512));
	if(RUNTIME){
		my $t = runinterval();
		print "Runtime: $t\n";
	}
}
