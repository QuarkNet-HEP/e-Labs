#!/usr/bin/perl

use Getopt::Long;

if($#ARGV < 2){
	print "usage: $0 -in [input-file1] -in [input-file2 ...] -id [board-ID1] -id [board-ID2 ...] ";
	print "-pre [output filenames prefix] \n";
	exit 1;
}

my %h = ();
my $result = GetOptions(\%h, 'in=s@', 'id=i@', 'pre=s');

use constant RUNTIME => eval "use Time::SoFar qw( runinterval )" || !$@;

#manualy change these if you wish...
$gate = 10000;
$event_coincidence = 2;
$detector_coincidence = 1;
$channel_coincidence = 1;
$eventnum = 1;

#threshold files will be infile1.thresh infile2.thresh...
@infile = @{$h{'in'}};
@serialNumber = @{$h{'id'}};
$prefix = $h{'pre'};
foreach $k (@infile){
	push @ofile, $k.".thresh";
}
@combine = @ofile;
$zzz = $serialNumber[0];

#rest of the derived files will be $prefix.TR1.TR2.TR3...
$combine_out = $prefix.".combine";
$sort_out = $combine_out.".sort";
$eventsearch_out = $sort_out.".search";
$eventchoice_out = $eventsearch_out.".choice";
$plot_param = $eventchoice_out.".param";
$plot_png = $eventchoice_out.".png";

while($infile=shift(@infile)){
	$ofile=shift (@ofile);
	$serialNumber=shift (@serialNumber);
	
	#ONLY CALCULATE THRESHOLD FILES IF THEY DONT EXIST
	if(! -e $ofile){
		$TR = "ThresholdTimes.pl $infile $ofile $serialNumber";
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

$combineTR = "getopt_Combine.pl";
foreach $f (@combine){
	$combineTR .= " -in $f";
}

@TRs = (
"$combineTR -out $combine_out",
"getopt_Sort.pl -in $combine_out -out $sort_out -col1 2 -col2 3",
"getopt_EventSearch.pl -in $sort_out -out $eventsearch_out -gate $gate -event $event_coincidence -detect $detector_coincidence -chan $channel_coincidence",
"getopt_EventChoice.pl -in $eventsearch_out -out $eventchoice_out -num $eventnum -zero $zzz -geo .",
"getopt_Plot.pl -in $eventchoice_out -param $plot_param -svg $plot_png -type 2"
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
