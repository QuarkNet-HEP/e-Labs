#!/usr/bin/perl

# TJ, FNAL & UMass May 2013
# used to determine if a raw data file can be blessed by comparing the rates determined from that file's metadata to values in that file's .bless

#Open this report from the meta query
#	1. Open a file in which to write results
#	2. Read a line from the file generated from Edit's meta query 
#		(line contains: FileName, blessFile, Chan1, Chan2, Chan3, Chan4, Triggers, StartDate, EndDate)	
#          2.1 Calculate length of file in seconds
#          2.2 Read the input file to get the rates of Chan1, Chan2, Chan3, Chan4 and Triggers and write those to variables
#          2.3 Open the .bless file associated with this line
#          2.4 Compare the calculated rate(s) from the meta to the rate(s) printed in the .bless file
#               2.4.1 If those rates differ by more than the standard deviation on the associated line, fail the associated file and report the failure to the output report file.
#               2.4.2 If those rates are within one standard deviation of each other, than go to the next line in the .bless file and check again.
#               2.4.3 If all the lines pass, indicate so in the output report file
#     3. Read the next line in the meta report, open the associated file and start checking.

$i = $infile = $ofile = $pathToBlessFiles = $duration = $elements = 0; 	#define these so strict is happy
@row = @splitFile = @blessFile = @chan0Rate = @chan1Rate = @chan2Rate = @chan3Rate = @triggerRate = (); #define these so strict is happy

#use strict;
#use warnings;

my $infile = $ARGV[0];	#file from meta query
my $ofile = $ARGV[1];	#results report to go back into meta
#my $pathToBlessFiles = $ARGV[2];	#If the .bless files are somewhere else



open (IN0, "$infile")  || die "Cannot open $infile for input";
open (OUT0, ">$ofile")|| die "Unable to open $ofile for output";

while (<IN0>){
	#step 2 above
	my @row = split /\,/;
	#step 2.1 above 
	my $duration = substr($row[9],11,2)*3600+substr($row[9],14,2)*60 + substr($row[9],17,2) - substr($row[8],11,2)*3600 - substr($row[8],14,2)*60 - substr($row[8],17,2); #length of file in seconds
	$files++; #keeps track of the number of checked files
	if ($duration <= 0){ #some files have fouled startDate, endDate metadata. A bad duration will yield a bad rate--these automatically fail.
		$unblessed++;
		print OUT0 "$row[1]\tunblessed\tDuration <= 0s\n";
		next
	}#end if duration = 0
	
	#step 2.2 above
	#perl can't do nested while loops while doing stuff with the $_ it's global. Each while needs a $_ to read in the current line.  
	#I'll build a arrays that can hold all of the values in the input file for later cycling through
	push (@path, $row[0]);
	push (@splitFile, $row[1]);
	push (@blessFile, $row[2]);
	push (@duration, $duration);
	push (@chan0Rate, sprintf("%.0f",$row[3]/$duration));
	push (@chan1Rate, sprintf("%.0f",$row[4]/$duration));
	push (@chan2Rate, sprintf("%.0f",$row[5]/$duration));
	push (@chan3Rate, sprintf("%.0f",$row[6]/$duration));
	push (@triggerRate, sprintf("%.6f",$row[7]/$duration));
}#end while IN0
close IN0;
my $elements = @splitFile; #Number of entries in any of the above arrays.

RELOAD: #necessary for the go to at the end. I hate to do it, but can't nest the two whiles{} otherwise needed to do this.
#The @arguments array holds all of the information from line $i in the input file. We can cycle from $i = 0 to $elements to pass these values to the checking done in step 2.4
@arguments = ($path[$i], $splitFile[$i], $blessFile[$i], $chan0Rate[$i], $chan1Rate[$i], $chan2Rate[$i], $chan3Rate[$i], $triggerRate[$i], $duration[$i]);

#step 2.3 above
#open (IN1, "$pathToBlessFiles"."$arguments[1]")  || die "Cannot open ", $pathToBlessFiles.$arguments[1], " for input ";
$candidate = $arguments[0].$arguments[2];
open (IN1, "$candidate")  || die "Cannot open ", $candidate, " for input ";
$i++; #increment this in order to get to the next set of values in the arrays.

while (<IN1>){#open a new .bless file for inspection
	my @row = split /\s+/;
	next if ($. == 1); #skip the header in the .bless file
	 #begin step 2.4 above
	if ($arguments[3] > $row[1] + $row[2] || $arguments[3] < $row[1]-$row[2]){ #Channel zero within one SD?
		$blessedState = "unblessed";
		$unblessed++; #keeps track of the number of failed files
		print OUT0 $arguments[1],"$arguments[1]\tunblessed at $row[0] due to Chan0 \t$arguments[3]\t$row[1]\t$row[2]\n";
		$blessedState = "blessed"; #reset this for the next file.
		last; #exiting the while loop--no point in further checking this file
	} #end if ($arguments[2]. . . 

	if ($arguments[4] > $row[3] + $row[4] || $arguments[4] < $row[3]-$row[4]){ #Channel one within one SD?
		$blessedState = "unblessed";
		$unblessed++; #keeps track of the number of failed files
		print OUT0 "$arguments[1]\tunblessed at $row[0] due to Chan1 \t$arguments[4]\t$row[3]\t$row[4]\n";
		$blessedState = "blessed"; #reset this for the next file.
		last; #exiting the while loop--no point in further checking this file
	} #end if ($arguments[3]. . . 

	if ($arguments[5] > $row[5] + $row[6] || $arguments[5] < $row[5]-$row[6]){ #Channel two within one SD?
		$blessedState = "unblessed";
		$unblessed++; #keeps track of the number of failed files
		print OUT0 "$arguments[1]\tunblessed at $row[0] due to Chan2 \t$arguments[5]\t$row[5]\t$row[6]\n";
		$blessedState = "blessed"; #reset this for the next file.
		last; #exiting the while loop--no point in further checking this file
	} #end if ($arguments[4]. . . 

	if ($arguments[6] > $row[7] + $row[8] || $arguments[6] < $row[7]-$row[8]){ #Channel three within one SD?
		$blessedState = "unblessed";
		$unblessed++; #keeps track of the number of failed files
		print OUT0 "$arguments[1]\tunblessed at $row[0] due to Chan3 \t$arguments[6]\t$row[7]\t$row[8]\n";
		$blessedState = "blessed"; #reset this for the next file.
		last; #exiting the while loop--no point in further checking this file
	} #end if ($arguments[5]. . . 

	if ($arguments[7] > $row[9] + $row[10] || $arguments[7] < $row[9]-$row[10]){ #triggers within one SD?
		next if $row[9] + $row[10] < 2; #low trigger rates alone shouldn't fail a file.
		$blessedState = "unblessed";
		$unblessed++; #keeps track of the number of failed files
		print OUT0 "$arguments[1]\tunblessed at $row[0] due to triggers \t$arguments[7]\t$row[9]\t$row[10]\n";
		$blessedState = "blessed"; #reset this for the next file.
		last; #exiting the while loop--no point in further checking this file
	} #end if ($arguments[6]. . .
	 #end step 2.4 above
}#end of while <IN1>
#step 2.4.3 above
if ($blessedState eq "blessed"){
	print OUT0 "$arguments[1]\t", $blessedState, "\n" ;# if a file gets to here, it passed all checks.
	$blessed++; #keeps track of the number of passed files
}
#close the current .bless file
close IN1;
#step 3 above
goto RELOAD if $i < $elements;  #I know, a go to. Shoot me. 
print OUT0 "Checked: $files. \n $blessed Blessed \n $unblessed Unblessed";