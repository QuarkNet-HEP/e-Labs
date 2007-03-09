#!/usr/bin/perl
# Take a datafile and create functions for gnuplot to plot with Plot.pl
#
# Written by Paul Nepywoda, FNAL 7-14-04 
# Edited by Evgeni Peryshkin 8-20-04
# Edited by Tom Jordan, FNAL 11-21-04 removed printing the background to the function file.
# ndettman 6/29/05 - formatted the arguments to work with the "-extra " that's being passed with the output file from the beans

use Getopt::Long;
if($#ARGV < 3){
	die "usage: ExtraFunctions.pl -in [input file] -extra [output function file] -inter [intermediate raw output file] -type [function type] (-lowx [x lowerbound] -highx [x upperbound] -alphaValue [alpha variate value] -alphaYN [alpha on (yes/no)] -lifetimeValue [lifetime variate value] -lifetimeYN [lifetime on (yes/no)] -constantValue [constant variate value] -constantYN [constant on (yes/no)] -fit [Fitting turned on?)]\n";
}
my %h = ();
my $result = GetOptions(\%h, 'in=s', 'extra=s', 'inter=s', 'type=i', 'lowx=s', 'highx=s', 'alphaYN=s', 'alphaValue=s', 'lifetimeYN=s', 'lifetimeValue=s', 'constantYN=s', 'constantValue=s', 'fit=s');

$infile = $h{'in'};
$outfile = $h{'extra'};
$rawFunctionFile = $h{'inter'};
$type = $h{'type'};
$lowX = $h{'lowx'};
$highX = $h{'highx'};
$alpha = $h{'alphaValue'};
$alpha_variate = $h{'alphaYN'};
$lifetime = $h{'lifetimeValue'};
$lifetime_variate = $h{'lifetimeYN'};
$constant = $h{'constantValue'};
$constant_variate = $h{'constantYN'};
$turned_On = $h{'fit'};

if(!$turned_On) { #if turned on is false, then user doesn't want to do a fit.
    open(OUT, ">$outfile") or die("Cannot open file: $outfile for output\n");
    print OUT "# This is empty file\n";
    $logFile_dirName = `dirname $rawFunctionFile`;
    chomp($logFile_dirName);
    $gnuplotFitParam = $logFile_dirName."/gnuplotFitParam".int(rand(1000)); #gnuplot's parameter file for the fit (temp file)
    close(OUT);
    open(TMP, ">$gnuplotFitParam");
    print TMP "# This is empty file\n";
    close(TMP);
    open(LOG, ">$rawFunctionFile");
    print LOG "# This is empty file\n";
    close(LOG);
} else {

if(!$alpha){
    $alpha= 10*&MaxOfFile($infile); #call has to come before $infile is opened
}
if(!$constant){
	$constant=&AverageOfLast($infile,.5); #call has to come before $infile is opened
}
if(!$lifetime){
	$lifetime=2.0;
}

open(IN, "$infile") or die("Cannot open file: $infile for input\n");
open(OUT, ">$outfile") or die("Cannot open file: $outfile for output\n");

if($type == 0){		#gnuplot best fit for an exponential
	$logFile_dirName = `dirname $rawFunctionFile`;
	chomp($logFile_dirName);
	$gnuplotFitParam = $logFile_dirName."/gnuplotFitParam".int(rand(1000));	#gnuplot's parameter file for the fit (temp file)
	open(TMP, ">$gnuplotFitParam");
#creates an options array that will be passed to the fit function of gnuplot	
	push @options, "a=$alpha";
	push @options, "lifetime=$lifetime";
	push @options, "constant=$constant";
	push @options, "decayfit(x) = constant+a*exp(-(1/lifetime)*x)";
	push @options, "set fit logfile \"$rawFunctionFile\"";
	push @options, "set fit errorvariables";

	if($alpha_variate eq "yes" ) {
    	if(($lifetime_variate eq "yes" || $constant_variate eq "yes" )) {
	    	$alpha_string =" a, ";
    	} else {
		    $alpha_string =" a ";
        }
	}
    if($lifetime_variate eq "yes" ) {
        if(($constant_variate eq "yes") ) {
		    $lifetime_string =" lifetime,";
        } else {
		    $lifetime_string =" lifetime ";
        }
    }
	if($constant_variate eq "yes") {
		$constant_string =" constant ";
	}
    
    if($alpha_variate ne "yes" && $lifetime_variate ne "yes" && $constant_variate ne "yes")
    {
        die "Error: must vary at least one variable when doing fit\n";
    } else {
	    $variatingVariables = "via $alpha_string $lifetime_string $constant_string";
    }
    
    if($lowX ne "" && $highX ne "" && $highX<=$lowX){   #if highX is less than lowX
        die "Bad fit parameters. High x parameter lower than low x parameter (highX = $highX, lowX = $lowX).\n";
    }
    else{
	    push @options, "fit [x=$lowX:$highX] decayfit(x) '$infile' using 1:2 $variatingVariables";
    }
    
	foreach $opt (@options){
        print TMP "$opt\n";
	}

	#call gnuplot
	`/usr/local/bin/gnuplot $gnuplotFitParam > /dev/null 2>&1`;

    $alpha_error=0;
    $lifetime_error=0;
    $constant_error=0;

	#parse output and write to standard function file to be then read by Plot script
	open(LOG, "$rawFunctionFile");
	while(<LOG>){
		if(/^a\s+=\s+([\d\.e\+\-]+)\s+(\+\/-\s[\d\.e\+\-]+)/){
			$alpha = $1;
			$alpha_error = $2;
		}
        elsif(/^lifetime\s+=\s+([\d\.e\+\-]+)\s+(\+\/-\s[\d\.e\+\-]+)/){
			$lifetime = $1;
			$lifetime_error = $2;
		}
		elsif(/^constant\s+=\s+([\d\.e\+\-]+)\s+(\+\/-\s[\d\.e\+\-]+)/){
			$constant = $1;
			$constant_error = $2;
		}
        elsif(/^BREAK:\s+Undefined value during function evaluation/){
#            BREAK:          Undefined value during function evaluation
#            When this happens, it means that the fit subruitine in gnuplot blew up and didn't do a fit corrrectly
            die "This fit didn't work, Try other fit parameters\n";
		}
        elsif(/^BREAK:\s+Singular matrix in Invert_RtR/){
#           BREAK:          Singular matrix in Invert_RtR 
#           The fit matrix became singular, which leads to huge errors 
            die "This fit matrix became singular, Try other fit parameters \n";
        }
        elsif(/^BREAK:/){
#           Fit didn't complete succesfully
            die "This fit didn't complete succesfully, Try other fit parameters \n";
        }
	}
    # Depending on what variables the function should be plotted through, use the respective Function
    if($highX eq "" && $lowX eq "" || $highX<=$lowX){ #if range is incorrectly set, then don't use a range
        print OUT "Function: $constant+$alpha*exp(-(1/$lifetime)*x)\n";
    }
    if($highX ne "" && $lowX ne ""){
	    print OUT "Function: x<$highX && x>$lowX ? $constant+$alpha*exp(-(1/$lifetime)*x) : 1/0\n";
    }
    if($highX ne "" && $lowX eq ""){ #if $highX is not blank
        print OUT "Function: x<$highX ? $constant+$alpha*exp(-(1/$lifetime)*x) : 1/0\n";
    }
    if($highX eq "" && $lowX ne ""){ #if $lowX is not blank
        print OUT "Function: x>$lowX ? $constant+$alpha*exp(-(1/$lifetime)*x) : 1/0\n";
    }
	print OUT "Label: $constant+$alpha*exp(-(1/lifetime)*x) [lifetime=$lifetime $lifetime_error]\n";
        #print OUT "Function: $constant\n";
        #print OUT "Label: Background = $constant\n";
	print OUT "alpha: $alpha\n";
	print OUT "alpha_error: $alpha_error\n";
	print OUT "lifetime: $lifetime\n";
	print OUT "lifetime_error: $lifetime_error\n";
	print OUT "constant: $constant\n";
	print OUT "constant_error: $constant_error\n";

	#remove temporary gnuplot fit parameter file
    #`rm $gnuplotFitParam`;
}
else{
	die "Must choose a function type (0)\n";
}
}

sub MaxOfFile #This function find the maximum value int he histogram, This multiplied by a factor becomes a good gues for alpha.
{
    open(IN, $_[0]) or die("Cannot open file: $_[0] for input\n");
    $tempVar=0;
   	while(<IN>){
		@freqData=split(/\s+/,$_);
   	    if($tempVar<$freqData[1]){
	       $tempVar=$freqData[1];
     	 }	
	}
    close(IN);
    return $tempVar;
}

sub AverageOfLast #this average the last percent of a histogram file, the average becomes a good guess for error.
{	
	$averageOfLastInputFile=$_[0];
	$averageOfLastPercent=$_[1];
    open(IN, $_[0]) or die("Cannot open file: $_[0] for input\n");
	#get a list of y inputs that you are using from a range you are fitting
	@YrangeFitting = "";
	$numYEntriesTotal=0;
	$numYEntriesCounted=0;
	$sumOfLast=0;
	$average=0;
    while(<IN>){
    	@freqData=split(/\s+/,$_);
		if( ($lowX eq "" || $lowX < $freqData[0]) && ($highX eq "" || $highX > $freqData[0]) ){
			push(@YrangeFitting, $freqData[1]);
			$numYEntriesTotal++;
		}
	}
	#find average of last $_[1] of Ys used in fitting
	while($numYEntriesCounted/$numYEntriesTotal < $averageOfLastPercent) {
		$sumOfLast += pop(@YrangeFitting);
		$numYEntriesCounted++;
	}
	$average=$sumOfLast/$numYEntriesCounted;
    close(IN);
	return $average;
}
