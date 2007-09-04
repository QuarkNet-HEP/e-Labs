#!/usr/bin/perl

# A script to execute all of the transformations in an e-Lab "Performance Study".
# The resulting plot is a histogram of duration (in ns) that each PMT pulse.
# This plot informs us about the "quality" of the data file.
# The transformations include:
#	ThesholdTimes.pl
#		input --> raw data
#		output --> .thresh file (a listing of timiing details for each PMT pulse in the data file
#			This transform takes the most time and is not effected by user input. We will write the transforms derived data to the same dir that the raw data are in.
#			Subsequent runs will check for the existence of this file. If present, they will ignore ThresholdTimes.pl transform and pick up this output file
#	Combine.pl
#		input --> .thresh files
#		output --> .combine
#			Simply cats together all of the input files
#	SingleChannel.pl
#		input --> .combine files
#		output --> a separate file for each channel (1-4)
#			Output files are essentially .thresh files for each channel in the active DAQ
#	Frequency.pl
#		input --> .combine.CHAN files
#		input --> Number of histogram bins
#		output --> frequency table
#			Table represents a histogram of the PMT pulse durations
#	Plot.pl
#		input --> .combine.CHAN.freq
#		output --> Plot.param
#		output --> Plot.png 
#			Plot.pl directs gnuplot to read the param file and create the plot



# Getopt allows us to use switches in the command line execution of this script. These switches include:
# 	-in(put)  	for each input file name or /path/to/file/name 
#	-pre(fix) 	for the /path/to/derived/data/filenameStub
#	-id			for serial numbers of the detectors that created the input files
#	-bins 		for number of histogram bins
use Getopt::Long;

my %h = ();
my $result = GetOptions(\%h, 'in=s@', 'id=i@', 'pre=s', 'bins=s');

#Gather the serial numbers
@serialNumbers = @{$h{'id'}};
$prefix = $h{'pre'};

if (length $prefix == 0){
	print "You must enter a path into which the derived data will be written.\n";
	print "Specify this path like:\n";
	print "-pre /path/to/derived/data\n";
	print "where each derived data file name will start with \"\data\"\n";
	exit;
}

$numBins = $h{'bins'};

if (length $numBins == 0){
	print "You must enter a number of bins for the histogram.\n";
	print "Specify this number like:\n";
	print "-bins NUM\n";
	exit;
}

#threshold files will be infile1.thresh infile2.thresh...
@infile = @{$h{'in'}};

if ($#infile != $#serialNumbers){
	print "You must enter ONE serial number for each input file.\n";
	print "You entered: ", $#serialNumbers + 1, " serial(s) and ", $#infile +1, " file(s)\n";
	print "Use -in for each input file and -id for each serial number\n";
	exit;
}

#Build the list of output filenames for ThresholdTimes
foreach $k (@infile){
	push @ofile, $k.".thresh";
}
@combine = @ofile;

#Set the names of the reamining derived files3...
$combine_out = $prefix.".combine";
$singlechan_out1 = $combine_out.".1";
$singlechan_out2 = $combine_out.".2";
$singlechan_out3 = $combine_out.".3";
$singlechan_out4 = $combine_out.".4";
$freq_out1 = $singlechan_out1.".freq";
$freq_out2 = $singlechan_out2.".freq";
$freq_out3 = $singlechan_out3.".freq";
$freq_out4 = $singlechan_out4.".freq";
$plot_param = $prefix."Plot.param";
$plot_png = $prefix."Plot.png";
#Finished setting names


#Create the threshold time files. These summary files are immutable to user input and only need to be written once. Subsequent runs should check to see if they exist.
while($infile=shift(@infile)){
	$ofile=shift (@ofile);
	$serialNumbers=shift (@serialNumbers);
	
	#ONLY CALCULATE THRESHOLD FILES IF THEY DONT EXIST
	if(! -e $ofile){
		$TR = "ThresholdTimes.pl $infile $ofile $serialNumbers";
		
		print "Running: $TR\n";
		`perl $TR`;
		print "ret: $?\n";
        die "Error!\n" if(($? & 256) or ($? & 512));
	}
}
$combineTR = "Combine.pl ";
foreach $f (@combine){
	$combineTR .= "$f ";
}

@TRs = (
"$combineTR $combine_out",
"SingleChannel.pl $combine_out '$singlechan_out1 $singlechan_out2 $singlechan_out3 $singlechan_out4'  '1 2 3 4'",
"Frequency.pl '$singlechan_out1 $singlechan_out2 $singlechan_out3 $singlechan_out4' '$freq_out1 $freq_out2 $freq_out3 $freq_out4' 5 0 $numBins",
"Plot.pl -file '$freq_out1 $freq_out2 $freq_out3 $freq_out4' -extra 'extraFun_out'  -param $plot_param -svg $plot_png -type 7 -title 'Performance Study' -ylabel 'PMT pulses' -xlabel 'Time over Threshold (nanosec)' -caption 'Detector #$serialNumber' -lowx '' -highx '' -lowy '' -highy '' -zlabel '' -lowz '' -highz ''"
);


#loop through all TRs and execute
while($TR = shift(@TRs)){
	print "Running: $TR\n";
	`perl $TR`;
	print "ret: $?\n";
    die "Error!\n" if(($? & 256) or ($? & 512));
}

print "All transformations are complete. Derived data are in:\n $prefix\n"
