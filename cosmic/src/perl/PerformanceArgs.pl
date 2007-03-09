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
$channel1 = 1;
$channel2 = 2;
$channel3 = 3;
$num_bins = 60;

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
$singlechan_out1 = $combine_out.".1";
$singlechan_out2 = $combine_out.".2";
$singlechan_out3 = $combine_out.".3";
$freq_out1 = $singlechan_out1.".freq";
$freq_out2 = $singlechan_out2.".freq";
$freq_out3 = $singlechan_out3.".freq";
$plot_param = $freq_out1.".param";
$plot_png = $freq_out1.".png";

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
"getopt_SingleChannel.pl -in $combine_out -out $singlechan_out1 -out $singlechan_out2 -out $singlechan_out3 -chan $channel1 -chan $channel2 -chan $channel3",
"getopt_Frequency.pl -in $singlechan_out1 -in $singlechan_out2 -in $singlechan_out3 -out $freq_out1 -out $freq_out2 -out $freq_out3 -col 5 -binType 0 -binValue $num_bins",
"getopt_Plot.pl -in $freq_out1 -in $freq_out2 -in $freq_out3 -param $plot_param -svg $plot_png -type 7"
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
