#!/usr/bin/perl

# TJ, FNAL & UMass May 2013
# used to determine if a raw data file can be blessed by comparing the rates determined from that file's metadata to values in that file's .bless

#Open this report from the meta query
#	1. Open a file in which to write results
#	2. Read a line from the file generated from Edit's meta query 
#		(line contains: FileName, blessFile, Chan1, Chan2, Chan3, Chan4, Triggers, StartDate, EndDate)	
#          2.1 Calculate length of file in seconds
#          2.3 Use the meta to the rates of Chan1, Chan2, Chan3, Chan4 and Triggers and write those to variables
#          2.4 Open the .bless file associated with this line
#          2.5 Compare the calculated rate(s) from the meta to the rate(s) printed in the .bless file
#               2.5.1 If those rates differ by more than the standard deviation on the associated line, fail the associated file and report the failure to the output report file.
#               2.5.2 If those rates are within one standard deviation of each other, than go to the next line in the .bless file and check again.
#               2.5.3 If all the lines pass, indicate so in the output report file
#     4. Read the next line in the meta report, open the associated file and start checking.

$i = $infile = $ofile = $pathToBlessFiles = $duration = $elements = 0; 	#define these so strict is happy
@row = @splitFile = @blessFile = @chan0Rate = @chan1Rate = @chan2Rate = @chan3Rate = @triggerRate = (); #define these so strict is happy

#use strict;
use warnings;

my $infile = $ARGV[0];	#file from meta query
my $ofile = $ARGV[1];	#results report to go back into meta
my $pathToBlessFiles = $ARGV[2];	#If the .bless files are somewhere else

open (IN0, "$infile")  || die "Cannot open $infile for input";
open (OUT0, ">$ofile")|| die "Unable to open $ofile for output";

while (<IN0>){
	my @row = split /\,/;
	my $duration = substr($row[8],11,2)*3600+substr($row[8],14,2)*60 + substr($row[8],17,2) - substr($row[7],11,2)*3600 - substr($row[7],14,2)*60 - substr($row[7],17,2); #length of file in seconds
	if ($duration <= 0){
		print OUT0 "$row[0] \t unblessed \t Duration <= 0s\n";
		next
	}#end if duration = 0
		
	#perl can't do nested while loops while doing stuff with the $_ it's global. Each while needs a $_ to read in the current line.  
	#I'll build an array that can hold all of the values in the input file for later cycling
	push (@splitFile, $row[0]);
	push (@blessFile, $row[1]);
	push (@chan0Rate, sprintf("%.0f",$row[2]/$duration));
	push (@chan1Rate, sprintf("%.0f",$row[3]/$duration));
	push (@chan2Rate, sprintf("%.0f",$row[4]/$duration));
	push (@chan3Rate, sprintf("%.0f",$row[5]/$duration));
	push (@triggerRate, sprintf("%.0f",$row[6]/$duration));
}#end while IN0
close IN0;
my $elements = @splitFile; #Number of entries in any of the above arrays.

RELOAD: #necessary for the go to at the end. I hate to do it, but can't nest the two whiles{} otherwise needed to do this.

@arguments = ($splitFile[$i], $blessFile[$i], $chan0Rate[$i], $chan1Rate[$i], $chan2Rate[$i], $chan3Rate[$i], $triggerRate[$i]);
open (IN1, "$pathToBlessFiles"."$arguments[1]")  || die "Cannot open ", $pathToBlessFiles.$arguments[1], " for input ";
$i++;

while (<IN1>){#open a new .bless file for inspection
	my @row = split /\s+/;
	#if ($row[0] eq "###Seconds"){#skip the header
	if ($. == 1){#skip the header
		print "$arguments[0] \n"; #and write the file name 
		next;
	} #end if $. == 1 
	
	if ($arguments[2] < $row[1] + $row[2] || $arguments[2] > $row[1]-$row[2]){ #Channel zero within one SD?
		print "$row[0] \t Chan0 pass!";
	}
	else{
		print OUT0 "$arguments[0] fails at $row[0] due to Chan0 \n";
		print "\n";
		next;
	} #end if ($arguments[2]. . . 

	if ($arguments[3] < $row[3] + $row[4] || $arguments[3] > $row[3]-$row[4]){ #Channel one within one SD?
		print "\t Chan1 pass!";
	}
	else{
		print OUT0 "$arguments[0] fails at $row[0] due to Chan1 \n";
		print "\n";
		next;
	} #end if ($arguments[3]. . . 

	if ($arguments[4] < $row[5] + $row[6] || $arguments[4] > $row[5]-$row[6]){ #Channel two within one SD?
		print "\t Chan2 pass!";
	}
	else{
		print OUT0 "$arguments[0] fails at $row[0] due to Chan2 \n";
		print "\n";
		next;
	} #end if ($arguments[4]. . . 

	if ($arguments[5] < $row[7] + $row[8] || $arguments[5] > $row[7]-$row[8]){ #Channel three within one SD?
		print "\t Chan3 pass!";
	}
	else{
		print OUT0 "$arguments[0] fails at $row[0] due to Chan3 \n";
		print "\n";
		next;
	} #end if ($arguments[5]. . . 

	if ($arguments[6] < $row[9] + $row[10] || $arguments[6] > $row[9]-$row[10]){ #triggers within one SD?
		print "\t trigger pass!\n";
	}
	else{
		print OUT0 "$arguments[0] fails at $row[0] due to triggers \n";
		print "\n";
		next;
	} #end if ($arguments[6]. . . 

	#print "$row[0] \t Chan0 Pass \n" if $arguments[2] < $row[1] + $row[2] || $arguments[2] > $row[1]-$row[2];
	#print "$row[1] \t $row[2] \t $arguments[2] \n";
}

#close the current .bless file
close IN1;
#get and inspect the next file
goto RELOAD if $i < $elements;  #I know, a go to. Shoot me. 