#!/usr/bin/perl

#Script for splitting user uploaded files according to the Julian Day of the first event
#
# usage: Split.pl [filename to parse] [output directory] [board ID]
#
# Paul Nepywoda, FNAL 1/2004
# revised, Yong Zhao, Mike Wilde, U.Chicago/Argonne, 3/2004
# revised, Tom Jordan, FNAL, numerous times
#
# Output: files split based on the beginning of a new Julian Day in the output directory, and named: id.yyyy.mmdd
#
# nepywoda changed 5-19-04: meta.dat is now $ID.meta.dat
# nepywoda changed 5-24-04: Split.pl checks the GPS date and if it's less than Jan 01, 2003 (happens when the GPS gets confused), it discards the data
# nepywoda changed 6-9-04: check to see if the GPS times are increasing (if not, ignore dataline) 
# nepywoda changed 7-2-04: correctly transforms Mac OS and DOS/Win new lines to UNIX new lines
# nepywoda changed 8-1-04: fixed bugs when computing the day around midnight
# nepywoda changed 8-7-04: fixed splitting problems when we split more than 1 file for a day. Solution: index the output files
# jordant  changed 8-15-06: fixed dropped first lines from raw data file if there was an incomplete pulse on the first line. Solution: increment $total_events in the FOR $ch_num 1..4 loop's first IF (line 113 right now) This allows the if $total_events > 0 conditional to fire-that's where the print SPLIT lives.
# jordant  changed 12-18-06: fixed line dropping when CPLD rollovers go asynchronous. We were throwing away too many lines by just looking at the time calculation.
# hategan  changed 02-20-08: fixed CPLD frequency calculations
# jordant  changed 09-06-09: added status line parsing
# jordant  changed 04-01-10: created a flag (#5) for occurences of the date changing before midnight. We now discard the lines.
# jordant changed 04-23-10: dropped a raw data line if the clock and GPS CPLD latch are both 0.
# jordant changed 07-07-10: inserting lines to create additional files needed for blessing.
# jordant changed 11-01-10: checking to see if user is doing ST2 or ST3 when writing raw data. Knowing which one is crucial to data blessing.
# jordant changed 5 Oct 11: fixing bug 372
# jordant changed 4 Jan 13: fixing bug 517
# eperonja changed in 2015: numerous fixes as follows (with Mark Adams' help)
#							cpldfrequency calculation problems				
		 
if($#ARGV < 2){
	die "usage: Split.pl [filename to parse] [output DIRECTORY] [board ID]\n";
}

use Time::Local 'timegm_nocheck';
use Math::BigInt;
use File::Copy;

$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
	warn "couldn't parse $commonsubs_loc $@" if $@;
	warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
	warn "couldn't run $commonsubs_loc"       unless $return;
	die;
}

$| = 1;		#print to STDOUT whenever it gets data...not simply when there's a new line

#information for metadata (raw and split files)
my ($start, $end, $split_start, $split_end, $today_date, $today_time, $blessFile);

($sec, $min, $hour, $day, $month, $year) = gmtime(time); #these variables mean Right Now--the time that the file was read by the system

$year += 1900;
$today_date = sprintf("%04d-%02d-%02d", $year, $month+1, $day);
$today_time = sprintf("%02d:%02d:%02d", $hour, $min, $sec);

#now that we've written today_data and today_time, we can reuse these variables ($sec, $min, etc.) to represent values from the raw data.

$raw_filename = $ARGV[0];
$output_dir=$ARGV[1];
$ID = $ARGV[2];
open IN, $raw_filename;
open(ERRORS,">$raw_filename.errors");

# Create and/or ensure output directory is writeable

stat $output_dir;
if ( ! -e _ ) {
	mkdir($output_dir, 0755) or die "$0: error: cannot create writeable directory $output_dir\n";
}
if ( ! ( -d $output_dir && -x _ && -w _ )) {
	die "$0: error: cannot create writeable directory $output_dir\n";
} 

# Create new metadata file in portal current directory

$last_gm_time = Time::Local::timegm_nocheck(0,0,0,0,1,2000);
$lastTime = "";						#this is the time from the last line
$split_chan[$_] = 0 for (1..4);		#how many events are in each channel in a split file
$chanRE[$_] = 0 for (1..4);			#initilization for valid channel REs
$total_events = 0;					#total events in the raw file
$non_datalines = 0;					#junk lines
$raw_meta_written = 0;				#only open META file once
$lastDate = "";						#split files by days
$sum_lats = 0;						#sum of latitudes from "DG" lines in the raw datafile
$sum_longs = 0;						#sum of longitudes from "DG" lines in the raw datafile
$sum_alts = 0;						#sum of altitudes from "DG" lines in the raw datafile
$lat_count = 0;						#number of latitude lines
$long_count = 0;					#number of longitude lines
$alt_count = 0;						#number of altitude lines
$cpld_latch = 0;					#CPLD count of GPS arrival $dataRow[9]
$last_cpld_latch = 0;				#CPLD count of GPS arrival on the _last_ line
$cpld_trig = 0;						#CPLD count of trigger $dataRow[0]
$last_cpld_trig = 0;				#CPLD count of trigger on the _last_ line
$data_line = 0;						#increments on each acceptably formatted data line

$fg1 = 41666667;					#CPLD frequency guess for old boards
$fg2 = 25000000;					#CPLD frequency guess for new boards

$N = 0xffffffff + 1;				#the modulus for CPLD clock wrap-arounds
									#apparenly perl cries "overflow" if 0x100000000 is used
									#It's suspicious. Maybe bigint should be used.
$Nover2 = int($N/2);				#precalculated N/2
$CONST_hex8F = hex('FFFFFFFF');
$CONST_hex8A = hex('AAAAAAAA');
$rollover_flag = 0;					#Control structure to determine rollover status of the two CPLD buffers: Trigger (word[0]) and Latch (word[9]).
$flaggedLatch = 0;					#Current value of the latch to hold for later checking
$flaggedTime = 0;					#Current value of the time to hold for later checking
$recoveredFlag = 1;					#Flag used in the async rollovers
$skipSomeLines = 0;					#Flag used in the asynch rollovers
$statusFlag = 0;					#Control structure to determine the presence of status lines--these go into the FOO.bless file.
$blessFile = 0;						#filehandle to keep the blessfile in scope globally

@dataRow = ();						#row of properly formatted raw data
@stRow = ();						#status line
@dsRow = ();						#row of scalars
@thRow = ();						#row of threshold values
#The next set of arrays hold information for the .bless file. I need to fill these as the original file gets parsed, determine if the the user did ST 2 or ST 3 do the subtraction (or not) based on that and then dump these arrays to the .bless file.
@stTime = ();						#Number of seconds since Greenwhcih midnight
@stCount0 = ();						#Counts in Channel zero
@stErr0 = ();						#Error in the channel 0 counts. (Square Root of the count)
@stCount1 = ();						#Counts in Channel one
@stErr1 = ();						#Error in the channel 1 counts. (Square Root of the count)
@stCount2 = ();						#Counts in Channel two
@stErr2 = ();						#Error in the channel 2 counts. (Square Root of the count)
@stCount3 = ();						#Counts in Channel three
@stErr3 = ();						#Error in the channel 3 counts. (Square Root of the count)
@stTrg = ();						#Number of triggers from the DS line
@stTrgErr = ();						#Error in the trigger counts. (Square Root of the count)
@stEvents = ();						#Running total of events in the file. A discontinuity here shows goofy GPS
@stPressure = ();					#Atmospheric pressure (in mbar) as reported by ST
@stTemp = ();						#Temperature (in deg C) as reported by ST
@stVcc = ();						#Bus voltage as reported by ST
@stGPSSats = ();					#Number of satellites as reported by ST
@stCountTemp =();					#temporary array to hold the differences while "fixing" the scalars read by ST 2
@splitscreated = ();				#keep the names of the splits created to clean up after a failure

$stTime = 0;						#time stamp of the status line (in seconds since midnight)
$oldSTTime = 0;						#time stamp from the LAST ST line (in seconds since midnight)
$stTimeGlitch = 0;					#flag for a GPS error that causes the time in the ST lines to stick. We need to bail on this ST line and the next DS line if the ST time is stuck.
$stType = 0;						#flag for version of the ST command used to generate the ST lines. One version will zero the scalars after each read the other version will not. We need to know which one is the case here so that the .bless files get populated with the correct rates.
$dsRowCount=0;
$stRowCount=0;
$stDate = 0;						#Raw date from the ST line	
$oldSTDate = 0;						#checks to see if the date is changing in the ST line--useful for files with no triggers
$ConReg = 0;						#string to hold the contents of the control registers from the ST line
$oldConReg = 0;						#erm . . . 
$TMCReg = 0;						#string to hold the contents of the TMC registers from the ST line
$numSplitFiles = 0;					#number of succesfully split files created.
$chan3 = $chan2 = $chan1 = $chan0 = 0; 	#holds the incremented channel counts. fixes bug #485
#$DAQID = 0; 						#string to hold the DAQID read in from the ST line. Needs to be zero here as there is a check for its value later.
$GPSSuspects = 0;					#int to hold the number of lines that we discard because the GPS date is suspect.

$current_data_row = "";				#to be able to print the prior data row
$previous_data_row = "";			#to be able to print the current data row
$clock_problem_count = 0;			#to keep the count of times that we found the clock to be off
@diff = ();                         #difference between ticks
@difflowrate = ();                  #hold difference between ticks
$DAQFirmware = 0;                   #holds the DAQFirmware value
$DAQFirmwareComments = "";          #if there is anything we need to say about firmware
$eventStart = 0;                    #event counter

#convert MAC OS line breaks to UNIX
#Mac OS only has \r for new lines, so Unix reads it as all one big line. We first need to replace
# the \r with \n and then re-read the file, hence the "redo" command
$newline_fixing=1;
while(<IN>){
	$_ =~ s/\r\n?/\n/g;	#see http://www.westwind.com/reference/OS-X/commandline/text-files.html#text-formats
    if($newline_fixing){
    	$newline_fixing = 0;
    	redo;
    }

	#Had to change the regExp in Dec 07. The newest version of the hardware had some firmware versions that did not add the +/- to word 1 when it was 0000. This was fixed in firmware version 1.06, but some cards made it into the wild with earlier firmware.
	#$re="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+]\\d{4})\$";
	
	#sample data line:
	#43395535 BD 00 39 00 3D 00 3E 00 42CB61CE 012138.020 130506 V 07 0 +0053
	
	#OK the new regExp on the next line works. I did not add the + to the offset (word 16) but left it bare. The question is what does ThresholdTimes do with this? Do I need to add the + to make ThresholdTimes happy?
	$reData="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+ ]\\d{4})\$";

	#additional regExp to catch status lines
	#hardware version < 5999 makes these ST lines:
	# ST 0005 2350 0149 2677 170128 120110 A 07 027BC86B 34 0057 003C1E00 000A711F
	$reStatus0="^([A-Z]{2}) ([0-9]{4}) ([0-9]{4}) ([0-9]{4}) ([0-9]{4}) ([0-9]{6}) ([0-9]{6}) ([AV]) ([0-9]{2}) ([0-9A-F]{8}) ([0-9]{2,3}) ([0-9]{4}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";
	
	#hardware version > 5999 makes these ST lines:
	# ST 1009 +2147483647 +050 3339 053155 180910 A 10 70CCD046 112 6626 00231F00 000A713F
	# ST 1009 +2511 +064 3344 031123 180910 A 06 48D6AAD9 112 6600 00A8A000 0016710F
	# ST 1009 +4134 +040 3344 031423 180910 A 05 550F37D9 112 6600 00847C00 0016710F
	# ST 1032 +279 +000 3354 070251 301009 A 05 BD8F8E15 111 6477 00231F00 000A711F
	# added to the regex for word three to address bug 477--TJ
	$reStatus1="^([A-Z]{2}) ([0-9]{4}) ([-+ 0-9]{4,11}) ([-+ 0-9]{4}) ([0-9]{4}) ([0-9]{6}) ([0-9]{6}) ([AV]) ([0-9]{2}) ([0-9A-F]{8}) ([0-9]{2,3}) ([0-9]{4}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";

	#hardware version < 6000 makes these DS lines:
	#DS 000021E7 00001F05 00001F97 000021D8 00000021 <--there is a space there!
	$reDS0="^([A-Z]{2}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8})\\s+\$";
	#There is probably a way to do this with chomp. But the above works for now.
	
	#hardware version > 5999 makes these DS lines:
	#DS 00000B98 0000098A 00000E51 00001089 00000004
	$reDS1="^([A-Z]{2}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";
	
	#regExp for the output of the TL command:
	$reThreshold0="^([A-Z]{2}) L0=([0-9]+) L1=([0-9]+) L2=([0-9]+) L3=([0-9]+)\$";

	#*performance* using an RE is 30% faster than splitting by whitespace
	if(/$reData/o){
		#$non_datalines++;
		@dataRow = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16);
		if (substr($dataRow[10],0,2) == substr($lastTime,0,2) && $dataRow[11] != $date && $dataRow[12] eq "V"){
			$GPSSuspects++;
			#print "$GPSSuspects", "\t", "$data_line","\n";
			#print $_;
			print ERRORS "SKIP 1-This line was skipped:\n";
			print ERRORS "$_\n";
			next;
		}
		
		if ($dataRow[10] eq "000000.000" || $dataRow[9] eq "00000000"){ #munged GPS clock
			$non_datalines ++;
			print ERRORS "SKIP 2-Munged GPS clock:\n";
			print ERRORS "$_\n";
			next;
		}
		# substr($dataRow[11],3,2) >> substr($year,2,2); #more GPS munging GPS date cannot be later than upload or earlier than 1999
		if (substr($dataRow[11],4,2) > substr($year,2,2)){#more GPS munging
			$GPSSuspects++;
			print ERRORS "SKIP 3-More GPS munging:\n";
			print ERRORS "$_\n";
			#print $., " Year in raw data line is bad, boss\n";
			next;
		}
	
		#bug 535 re-opened date slipped back six years during a data-run
		if (defined $date && substr($dataRow[11],4,2) != substr($date,4,2) && substr($dataRow[11],0,2) ne 01 && substr($dataRow[11],4,2) ne 01){ #just checking current value against $date will fail if $date is not def. Also, the year can change if it is 01 Jan. 
			$GPSSuspects++;
			print ERRORS "SKIP 4-Date slipped back six years during a data-run:\n";
			print ERRORS "$_\n";
			#print "$. Line 228 \n";
			next; #don't allow $time or $date to be set to the values in the current line--those are goofy
		}
		#print "$. $total_events \n";
		$total_events++ if hex($dataRow[1]) >= 128; # If the 7th bit is set, this is a new and valid event.
		next if $total_events == 0; #A data file can have a munged first line in the event. This breaks the logic that sets the filenames. 

		$lastTime = $time;
				
		if ($rollover_flag == 5){ #this is a stuck GPS latch
			print ERRORS "This line would have been skipped due to a stuck GPS latch:\n";
			print ERRORS "$_\n";
			#next if $flaggedLatch == hex($dataRow[9]);#The latch hasn't advanced yet.
			#if ($flaggedLatch != hex($dataRow[9])){#the rollover has recovered
				$rollover_flag = 0;#We need this to get into the block that starts if ($rollover_flag ==0)
				$flaggedLatch = $flaggedDate = $flaggedTime = 0;
			#}
			if ($flaggedDate != $dataRow[11]){#the date advanced
				$rollover_flag = 0;#We need this to get into the block that starts if ($rollover_flag ==0)
				$flaggedLatch = $flaggedDate = $flaggedTime = 0;
			}
		} 

		if ($rollover_flag == 6){ #this is a stuck clock
			print ERRORS "This line would have been skipped due to a stuck clock:\n";
			print ERRORS "$_\n";
			#next if $flaggedTime == $dataRow[10];#The clock hasn't advanced yet.
			#if ($flaggedTime != $dataRow[10]){ #The clock has advanced, do some clean up and move on
				$rollover_flag = 0;
				$flaggedLatch = $flaggedTime = 0;
				$lastTime = $dataRow[10] if $lastDate == $dataRow[11]; #fixing bug 655
				$cpld_latch = hex($dataRow[9]);
			#}
			if ($flaggedDate != $dataRow[11]){#the date advanced
				$rollover_flag = 0;#We need this to get into the block that starts if ($rollover_flag ==0)
				$flaggedLatch = $flaggedDate = $flaggedTime = 0;
			}
		}
		
		#inserted by TJ to look for data lines that appear when the user types HT--Bug 372
		#that user command inserts the next four lines of data into the file as an example.
		#these lines are fake data and shouldn't make it through split
		#DE799F14 BB 00 00 00 00 00 00 00 DE1C993A 132532.010 111007 A 05 0 +0060
		#DE799F15 00 00 00 00 21 00 00 00 DE1C993A 132532.010 111007 A 05 0 +0060
		#DE799F15 00 35 00 00 00 00 00 00 DE1C993A 132532.010 111007 A 05 0 +0060
		#DE799F15 00 00 00 00 00 3C 00 00 DE1C993A 132532.010 111007 A 05 0 +0060
		
		if ($dataRow[11] == 111007 && $dataRow[9] eq DE1C993A){ #only need to check these two--this is really unlikely. Really. Checking them all is too expensive.
			print ERRORS "SKIP 5-Looking for word 10 to be equal to DE1C993A and word 12 to be equal to 111007:\n";
			print ERRORS "$_\n";
			$non_datalines ++;
			next;
		}	

		#there can be asynchronous clock and date rollovers: Bug 513
		#D8BDBF27 00 00 00 28 00 00 00 00 D8621B39 235956.009 190912 A 08 0 +0051
		#DD78EF15 AB 00 2E 00 2D 00 2C 00 DCDA83F9 235959.001 200912 A 06 0 +0059
		#DD78EF15 00 38 00 3D 00 3A 00 3A DCDA83F9 235959.001 200912 A 06 0 +0059
		#DF2C1263 B4 00 37 00 37 00 37 00 DE57FC39 000000.009 200912 A 08 0 +0051
		
		if ($dataRow[10] > 235950 && $dataRow[11] != $date){ #munged GPS clock
			print ERRORS "SKIP 6-Munged GPS clock:\n";
			print ERRORS "$_\n";
			$non_datalines ++;
			next;
		}
		
		$last_cpld_latch = $cpld_latch;
		$cpld_latch = hex($dataRow[9]);
		$last_cpld_trig = $cpld_trig;
		$cpld_trig = hex($dataRow[0]);
			
		#The next section is devoted to cleaning up datalines before any more processing. 
		#There are five possible errors that can pollute the caluclation of absolute time.
	
		#The first error is a GPS flag of 4. It _always_ makes our calculation of absolute time incorrect. 

		#GPS flag = 4 in the raw data indicates that the GPS time in that line is suspect. Indeed, our calculation confirms this so we should ignore the lines with a GPS flag = 4. Now we do.
		#Actually it should check if bit 2 is 1. Otherwise it may accept invalid lines.
		#Commented out this next piece of code that checks for the "8" flag for older boards. 
		#Sten, Mark and Bob agreed that this check is not necessary.
		#next if ($dataRow[14] >> 3); 
		#next if ($dataRow[14] & 0x04 != 0); 

		#trying somethiing new with GPS time solutions. TJ wonders if the V and A flag really mean something about the timing solution. Thus far there is no evidence for it.
		#next if ($dataRow[12] eq 'V');
		#And now looking at number of satellites
		#next if ($dataRow[13] < 2);

		#There are several asynchronous "register rollover errors" that can appear in the data, we can trap those and be more clever about dropping data lines.

		#1. The trigger latch can roll over before the GPS latch does
		#2. The trigger latch can "get stuck while the GPS rolls over
		#3. The trigger latch can stay the same while the GPS latch rolls over (I doubt that this EVER happens
		#4. We've deprecated this one
		#5. The time stamp can advance before the GPS latch does
		#6. The GPS latch can advance before the time stamp does.	
	
		#Set the flag with a simple comparison of the buffers. Use the value of the flag as a control on further checks. Those checks can reset the flag to zero and go on or reset the flag to zero and discard the current line (rare).
		#we no longer do this "set the flag and then check the flag" thing. Now it's all in one step.
	
		#$rollover_flag = 1 if ($cpld_trig <= $last_cpld_trig && $cpld_latch > $last_cpld_latch);
		if (hex($dataRow[0]) <= $last_cpld_trig && hex($dataRow[9]) > $last_cpld_latch){#we used to set $rollover_flag==1 here and then check the value of the flag a few lines later. Now we do it all here.
			#$rollover_flag = 0; # reset the flag
			#ThresholdTimes can deal with these rollovers if the difference between the buffers is "large". Toss out lines with "small" differences.
			if (hex($dataRow[9]) - hex($dataRow[0]) < $CONST_hex8A && $cpld_trig < $cpld_latch){ 	#an arbitrarily large value.		
				print ERRORS "SKIP 7-ThresholdTimes can deal with these rollovers if the difference between the buffers is large. Toss out lines with small differences.\n";
				print ERRORS "$_\n";
				$non_datalines++;
				next; #This gets us around the $rollover_flag==0 check down below.		
			}
		}
	
		#$rollover_flag = 2 if ($cpld_trig == $last_cpld_trig && $cpld_latch < $last_cpld_latch); #flag == 1 and flag == 2 can be dealt with in the same way.
		if (hex($dataRow[0]) == $last_cpld_trig && hex($dataRow[9]) < $last_cpld_latch){#we used to set $rollover_flag==2 here and then check the value of the flag a few lines later. Now we do it all here.
			#$rollover_flag = 0; # reset the flag
			#ThresholdTimes can deal with these rollovers if the difference between the buffers is "large". Toss out lines with "small" differences.
			if ($cpld_latch - $cpld_trig < $CONST_hex8A && $cpld_trig < $cpld_latch){ 	#an arbitrarily large value.		
				print ERRORS "SKIP 8-ThresholdTimes can deal with these rollovers if the difference between the buffers is large. Toss out lines with small differences.\n";
				print ERRORS "$_\n";
				$non_datalines++;
				next;		
			}
		}
	
		#$rollover_flag = 3 if ($cpld_trig == $last_cpld_trig && $cpld_latch > $last_cpld_latch);
		if (hex($dataRow[0]) == $last_cpld_trig && hex($dataRow[9]) > $last_cpld_latch){#we used to set $rollover_flag==3 here and then check the value of the flag a few lines later. Now we do it all here.
			#$rollover_flag = 0; # reset the flag
			#An old board or a "small difference" makes this line invalid
			if ($DAQID<=5999 || $cpld_latch - $cpld_trig < $CONST_hex8A){	
				print ERRORS "SKIP 9-An old board or a small difference makes this line invalid.\n";
				print ERRORS "$_\n";
				$non_datalines++;
				next; 		
			}
		}	
	
		#$rollover_flag = 4 if ($cpld_trig > $last_cpld_trig && $cpld_latch > $last_cpld_latch); #This should never, ever happen. Ever. Still. . . 
		#In fact it does happen. On every trigger. Always. The previous line is a good way to drop the first line of each event.

		#flag four has been removed

		#$rollover_flag = 5 if ($time != $lastTime && $cpld_latch == $last_cpld_latch && $recoveredFlag == 1); #Clock advanced. GPS latch did not
		
		if ($dataRow[10] != $lastTime && hex($dataRow[9]) == $last_cpld_latch) {#Clock advanced. GPS latch did not
			print ERRORS "This line would have been skipped due to that the clock advanced, the GPS latch did not:\n";
			print ERRORS "$_\n";
			#$rollover_flag = 5; 
			#$flaggedLatch = hex($dataRow[9]);
			#$flaggedDate = $dataRow[11];
			#$non_datalines++;
			#next;
		}
	
		#$rollover_flag = 6 if ($cpld_latch != $last_cpld_latch && $time == $lastTime && $recoveredFlag == 1); #GPS latch advanced. Clock did not.
		if (hex($dataRow[9]) != $last_cpld_latch && $dataRow[10] == $lastTime) {#GPS latch advanced. Clock did not.
			print ERRORS "This line would have been skipped due to that the GPS latch advanced, the clock did not:\n";
			print ERRORS "$_\n";
			#$rollover_flag = 6;
			#$flaggedTime = $dataRow[10];
			#$flaggedDate = $dataRow[11];
			#$non_datalines++;
			#next;
		}
	
		#Check the cause of the rollover flags, decide whether to accept this line, reset the flag
	
		#if ($rollover_flag == 1 || $rollover_flag == 2){
		#	$rollover_flag = 0; # reset the flag
			#ThresholdTimes can deal with these rollovers if the difference between the buffers is "large". Toss out lines with "small" differences.
		#	if ($cpld_latch - $cpld_trig < $CONST_hex8A && $cpld_trig < $cpld_latch){ 	#an arbitrarily large value.		
		#		$non_datalines++;
		#		next;		
		#	}
		#}

		#if ($rollover_flag == 3){
		#	$rollover_flag = 0; # reset the flag
		#	#An old board or a "small difference" makes this line invalid
		#	if ($DAQID<=5999 || $cpld_latch - $cpld_trig < $CONST_hex8A){	
		#		$non_datalines++;
		#		next;		
		#	}
		#}
	
	
		#if ($rollover_flag == 5 || $rollover_flag == 6) { #latch or clock is stuck
		#	next; # we can throw the current line away, but we have to carefully look at the next several lines.
		#}

		#if ($time == $lastTime && $cpld_latch != $last_cpld_latch){ # the latch increases but the clock doesn't ("stuck clock")
		#	$rollover_flag = 7 if $rollover_flag == 0 && $flaggedLatch != 0 && $flaggedTime !=0; #this has the outcome of only CHANGING the flag, that's different than re-setting it. 
		#}
		$lastDate = $date;
		$date = $dataRow[11];
		$time = $dataRow[10]; 
	}#end of if /$reData/o)

	#the current line is not a data line or has passed the rollover tests. Proceed.
	elsif(/$reStatus0/o || /$reStatus1/o){
		
		@stRow = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14);
		#next if ($stRow[6] != $date) && (substr($date,0,2) != 12) && (substr($date,2,2) != 31); #there if a bad GPS date gets into the ST line. Also, check to see if the date rolled because of a new year--part of bug 535
		next if $stRow[5] == 0; #fixing bug 631
		if (($stRow[6] != $date) && (substr($date,0,2) != 12) && (substr($date,2,2) != 31)){#; #there if a bad GPS date gets into the ST line. Also, check to see if the date rolled because of a new year--part of bug 535
			#print "$. Line 427 \n";
			$stTimeGlitch = 1;
			next;
		}
		$STLineNumber = $.; #needed to check if this ST line is followed by a DS line			
		$stRow = @stRow; 
		#next if substr($stRow[5], 0, 2)*3600 + substr($stRow[5], 2, 2)*60 + substr($stRow[5], 4, 6) == 0;
		$oldSTTime = $stTime;
		$stTime = substr($stRow[5], 0, 2)*3600 + substr($stRow[5], 2, 2)*60 + substr($stRow[5], 4, 6);
		if ($oldSTTime == $stTime){ #munged GPS time will stop the status line time from advancing. Writing repeating times into the status array will break the calculation of rate and other bits in the bless file
			$stTimeGlitch = 1;
			next;
		}	
        #log it to the error file
        if ($stTime < $oldSTTime) {
            print ERRORS "The following ST Line displays a time earlier than the prior ST Line:\n";
            print ERRORS $_;
        }
		
		#We could look at ConReg and TMCReg to see if they change. If they do, we need to start another split file.
		#$oldSTDate = $stDate;
		$stDate = $stRow[6];
		$oldSTDate = $stDate if $oldSTDate == 0;
		$oldConReg = $ConReg;
		$ConReg = $stRow[13];
		$oldConReg = $ConReg if $oldConReg == 0; #Testing revealed a case where a data file _started_ with an ST line this changed $ConReg, but not $oldConReg. 
		#$oldTMCReg = $TMCReg; #Ths one is a bit more complicated. The word changes, but the difference between values doesn't. Fix this later. Very few users can do this.
		#print "$stRowCount \n";
		if ($stRowCount == 0) {
			$TMCReg = $stRow[12];
			$DAQFirmware = $stRow[10]/100 if $stRow[10] > 99; 	#The DAQ firmware writes the firmware as an INT (e.g., FW version 1.06 is reported in the ST line as 106)
			$DAQFirmware = $stRow[10]/10 if $stRow[10] < 100;	#Some of the ints are less than 100. 
			$DAQID = int($stRow[11]);
			if ($DAQID != 0 && $ID != $DAQID) {
				clean_failed_splits();
				die "The DAQ ID selected ($ID) does not match the DAQ ID stored in these data ($DAQID). We've cancelled your upload. Did you select the correct ID?";
			}
		}
		$stRowCount++;
		next; #we need a next here to get the second line present in the output of ST.
	} #end of elsif (/$reStatus0/o || /$reStatus1/o)

	elsif(/$reDS1/o || /$reDS0/o){
		$non_datalines++;
		if ($stTimeGlitch == 1) { #bail on this DS line. The scalars are correct but a non-advancing time will break the bless file.
			$stTimeGlitch = 0; #reset the flag
			next; #ignore this DS update
		}
		
		$DSLineNumber = $.; #Needed to check if this DS line is preceded by an ST line
		
		next if $DSLineNumber - $STLineNumber != 1;
		@dsRow = ($1, $2, $3, $4, $5, $6);

		if ($DSLineNumber - $STLineNumber == 1){ #Only fill the blessing arrays if the DS line follows the ST line
			push (@stCount0, hex($dsRow[1]));
			push (@stCount1, hex($dsRow[2]));
			push (@stCount2, hex($dsRow[3]));
			push (@stCount3, hex($dsRow[4]));
			push (@stEvents, hex($dsRow[5]));
			push(@stTime, $stTime);
			push(@stPress, $stRow[1]);
			push(@stTemp, $stRow[2]/10); #changing $stRow[3] to $stRow[2] fixes bug 453
			push(@stVcc, $stRow[4]/1000);
			push(@stGPSSats, $stRow[8]);
			$dsRowCount++;
		}	
		next; #get the next line in the input file. All the lifting is done on this one.
	}#end of elsif(/$reDS!/o

	elsif(/$reThreshold0/o){
		@thRow = ($2, $3, $4, $5);
		$non_datalines++;
		next; #get the next line in the input file. All the lifting is done on this one.
	}

	elsif(&gps_check($_)){
        next;
	}
	else{
        $non_datalines++;
		next;
	}


if ($rollover_flag == 0){ #proceed with this line if it doesn't raise a flag.

		if ($dataRow[10] < $lastTime && $dataRow[10] < 230000 && $dataRow[11] == $lastDate){
			$non_datalines ++;
			next;	  
		}
		$data_line ++;

		$day = substr($dataRow[11], 0, 2);
		$month = substr($dataRow[11], 2, 2);
    	$year = substr($dataRow[11], 4, 2) + 2000;   # Assume no records before 2000
    	$hour = substr($dataRow[10], 0, 2);
	    $min = substr($dataRow[10], 2, 2);
	    $sec = substr($dataRow[10], 4, 2);
	    $msec = substr($dataRow[10], 7, 3);
	    $offset = $dataRow[15]; # if $ID < 6000; # Fixes bug 459 removing the conditional to test fixes to shower.


		#The following IF block sends the date and time fromt the current line to an external module to ask what the date and time are. 
		#That's not necessary and really, really expensive in terms of run time. I'm taking it out.
		#if($lastTime ne $dataRow[0].$dataRow[9].$dataRow[10].$dataRow[15]){
        	#*performance* NOT using a function call saves some compute time here
        	#($sec, $min, $hour, $day, $month, $year) = &curr_line_time_setup(@row);
       		#$lastDay = $day; 
       		
			#$CPLDdifference = (hex($dataRow[0])-hex($dataRow[9]))/41666667 if $DAQID < 6000;
			#$CPLDdifference = (hex($dataRow[0])-hex($dataRow[9]))/25000000 if $DAQID > 5999;
			
			#$sec_offset = sprintf("%.0f", $sec + $msec/1000 + $offset/1000);
	        #$sec = $sec_offset;# + $CPLDdifference;
			#$sec = $sec_offset + $CPLDdifference;
	        #this is here because we require lines to go in the absolute correct day (with offsets taken into consideration)
	        #Note: most of the compute time of Split.pl is in these 2 calls
			#$curr_gm_time = Time::Local::timegm_nocheck($sec, $min, $hour, $day, $month-1, $year);
			#($sec, $min, $hour, $day, $month, $year) = (gmtime($curr_gm_time))[0..5];

			#$year = $year+1900;
			#$month = sprintf("%02d", $month+1);
			#$day = sprintf("%02d", $day);
			
			#So the problem lies in here. . . We are re-defining $day. . .that changes date for no good reason. that can spawn a new split file for no good reason. Taking this out to test bug 495.
		#} # end of if ($lastTime ne $dataRow. . . 
		
		#$last_time = $dataRow[0].$dataRow[9].$dataRow[10].$dataRow[15];

		#This next line may not be necessary after the dataRow[14]==4 check implemented above.
		#next if($curr_gm_time < $last_gm_time);	#make sure that the GPS times are increasing
	
		#$last_gm_time = $curr_gm_time;

		#$date = sprintf("%04d-%02d-%02d", $year, $month, $day);
		#$time = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
	
		$total_events++ if hex($dataRow[1]) >= 128; # If the 7th bit is set, this is a new and valid event.

		#don't write any split files, bless files or metadata if there are no events--or ST lines
		if($total_events > 0){# && $stRowCount > 0) {
			
			#only open the metadata file once
			if($raw_meta_written == 0){
				$raw_meta_written = 1;
				# metadata file for raw and split files. 
				open(META,">$raw_filename.meta");

				#unbuffered write to META handle
				$old_fh = select(META);
				$| = 1;
				select($old_fh);

				# Write initial metadata for raw/uploaded file
				# WHY don't we wait until the END of the split process to write raw metadata? because if the Split.pl process is killed before it completes, we still want metadata for the raw file to be written
				$fn = `basename $raw_filename`; 
				chomp $fn;
				print META "[RAW] $raw_filename\n";
				print META "creationdate date $today_date $today_time\n";
				print META "detectorid string $DAQID\n";
				print META "type string raw\n";
				#need to format date to YYYY-MM-DD and Time to HH:MM:SS
				$earliest_start = 2000+substr($date,4,2)."-". substr($date,2,2)."-". substr($date,0,2) . " " . substr($time,0,2).":". substr($time,2,2).":". substr($time,4,2);
				print META "startdate date $earliest_start\n"; # Earliest start date in file
				$jd = jd($day, $month, $year, $hour, $min, $sec);	#GPS offset already taken into account from above
	            print META "julianstartdate float $jd\n";   # Earliest start date in file in julian days
				#the following line is replaced when the splitting is complete
				print META "ThisFileNeverCompletedSplitting date 0000-01-01\n";
				print META "totalevents int 0\n";
				print META "nondatalines int 0\n";
				print META "avglatitude string 0\n";
				print META "avglongitude string 0\n";
				print META "avgaltitude string 0\n";
				#print the threshold for each channel
				print META "GPSSuspectsTotal int 0\n";
				print META "totalDataLines int 0\n";	
				#print META "DiscThresh0 int $thRow[0]\n"; 
				#print META "DiscThresh1 int $thRow[1]\n"; 
				#print META "DiscThresh2 int $thRow[2]\n"; 
				#print META "DiscThresh3 int $thRow[3]\n"; 
				#print META "DAQFirmware string $DAQFirmware\n";
			} #end of if ($raw_meta_written ==0)

			# When we see new day--or the control register changes, split file at the day boundary
			# Mike suggested that we split at midnight, even though Julian Days begin at Noon
			$oldSTDate = $stDate = $dataRow[11] if $date ne $lastDate && $stRowCount == 0; 
			$oldSTDate = $stDate = $dataRow[11] if $dsRowCount == 0;
			$oldSTDate = $stDate = $dataRow[11] + 10000 if $dsRowCount == 0 && $dataRow[10] > 235959;
			#$lastDate = $stDate if $stDate != $lastDate && substr($dataRow[10],10,4) eq 0000; 
			
			if($dataRow[11] ne $lastDate || $oldSTDate ne $stDate) {	#start of a new output file ##removed the checking of the control registers. Fixes bug #487  
				#print "Dates don't match, Boss. $date $lastDate $stDate $oldSTDate \n";
				
				if ($lastDate ne "") {
					#die "These data do not contain the same number of ST and DS lines; we have stopped your upload. We created $numSplitFiles usable file(s) before this error." if $dsRowCount != $stRowCount;
					# The file that we are splitting has hit a date boundary. We need to start writing a new SPLIT file and write the .bless file for the file that we are closing. 
					# First, some housekeeping:
					# 0. Close the existing file.
					# 1. Determine if the DAQ was producing ST2 or ST3 lines
					# 2. Use the ST Type to re-write (possibly) the @stCountN arrays (i.e., $stCount0[n] must be subtacted from $stCount0[n+1] if ST 2)
					# 3. Determine the rate.
					# 4. Sum up those arrays to determine meta for counts in channels 0-3 and triggers
					# 5. Create and write metadata about the file that was just closed						
					# 6. Write the .bless file for the file that was just closed.
					#Do this again later on for the last file that we are splitting					
					close SPLIT;
					
					# 1. Determine if the DAQ was producing ST2 or ST3 lines
					# When ST 2, the DAQ does not clear the onboard registers (that we call stCountN or stEvents here) after printing the lines. So the count in any channel over the time interval is the previous (stCount0 or stEvent) subtracted from the current (stCount0 or stEvent)
					# When ST3 these onboard registers are cleared after each printing, so there is no need to do the subtraction.
					# We just need to see if these (stCountN and stEvents) keep growing over the life of the file. If they do, we need to subtract one from the next to get the scalar increment over the integration time.
					if ($dsRowCount != $stRowCount || $dsRowCount == 0) {
						if ($numSplitFiles == 0) {
							clean_failed_splits();					
							die "These data span at least one day that does not contain any 'ST', 'DS' line pairs--or, the data in those lines are munged. We have stopped your upload. We created $numSplitFiles usable file(s) before this error."; #(removing the comment before the OR in this conditional it somehow got removed)
						} else {
							warn "These data span at least one day that does not contain any 'ST', 'DS' line pairs--or, the data in those lines are munged. We have stopped your upload. We created $numSplitFiles usable file(s) before this error."; #(removing the comment before the OR in this conditional it somehow got removed)
						}
					}
								
					if ($dsRowCount > 0){
						#First we need to learn which channel to look at (the trigger may be too slow) to see if it is working (i.e., plugged in & turned on).
						#The channel is off if the scalar hasn't incremented. I hope that one ping is enough to tell.						
						#EPeronja: the old logic works for most of the cases except for ST 3. The latter resets the counts so we have come across situations
						#		   in which the first and the second are the same and this logic fails the whole file!			
						#$goodChan = 0 if ($stCount0[0] != $stCount0[1]);
						#$goodChan = 1 if ($stCount1[0] != $stCount1[1]) && $goodChan == -1;
						#$goodChan = 2 if ($stCount2[0] != $stCount2[1]) && $goodChan == -1;
						#$goodChan = 3 if ($stCount3[0] != $stCount3[1]) && $goodChan == -1;			
						$goodChan = 0 if (($stCount0[0] != $stCount0[1]) || ($stCount0[0] == $stCount0[1] && $stCount0[1] != 0));
						$goodChan = 1 if (($stCount1[0] != $stCount1[1]) || ($stCount1[0] == $stCount1[1] && $stCount1[1] != 0)) && $goodChan == -1;
						$goodChan = 2 if (($stCount2[0] != $stCount2[1]) || ($stCount2[0] == $stCount2[1] && $stCount2[1] != 0)) && $goodChan == -1;
						$goodChan = 3 if (($stCount3[0] != $stCount3[1]) || ($stCount3[0] == $stCount3[1] && $stCount3[1] != 0)) && $goodChan == -1;

						if ($goodChan == -1) {
							if ($numSplitFiles == 0) {
								clean_failed_splits();					
								die "This detector has no working channels. We have stopped your upload. We created $numSplitFiles usable file(s) before this error.";
							} else {
								warn "This detector has no working channels. We have stopped your upload. We created $numSplitFiles usable file(s) before this error.";
							}
						}

											
						#now that we know what channel to look at, let's test for ST 2 or ST 3 by checking how often a scalar read is larger than the previous read.
						for $j (0..$dsRowCount-1){
							$n++ if $goodChan == 0 && $stCount0[$j] <= $stCount0[$j+1];
							$n++ if $goodChan == 1 && $stCount1[$j] <= $stCount1[$j+1];
							$n++ if $goodChan == 2 && $stCount2[$j] <= $stCount2[$j+1];
							$n++ if $goodChan == 3 && $stCount3[$j] <= $stCount3[$j+1];
						} # end of for (1..$stRowCount-2)
						#The last loop tells us how many times the count advanced from one DS to the next. If this number (n) is close to the number of rows, this detector is likely to be running ST 2.
						$j = 0;
						$stType = 3 if $n/$dsRowCount < 0.7;
						$stType = 2 if $n/$dsRowCount > 0.7;
					} #end of if($dsRowCount > 0)
					
					# 2. Use the ST Type to re-write (possibly) the @stCountN arrays (i.e., $stCount0[n] must be subtacted from $stCount0[n+1] if ST 2)
					#We need to know how many times each channel (and the trigger) fired over the last interval. If this detector is running ST 2, the scalars aren't zero-ing after the last read. We need to subtract the value in row (i) from the value in row (i+1)
						#Row(i):	DS 000021E7 00001F05 00001F97 000021D8 00000021 
 						#Row(i+1):	DS 000058F9 0000509C 000053C5 000058EB 00000054 
 						#Row(i+2):	DS 0000903B 00008295 0000874F 0000900B 00000087 

					#These values now live in the arrays called stCount(0-3) and stEvents. What we need is the rate--not the counts. Also the counts need "fixing" if the detector is using ST 2
					
					#"fix" the arrays built with ST2.
					if ($stType == 2){
						for $j (1..$dsRowCount){
							#Subtract one from the previous (and not the latter) so that we see the rate in the last integration period (and not the next)
							push(@stCountTemp, $stCount0[$j] - $stCount0[$j-1]) if $stCount0[$j] > $stCount0[$j-1]; #the if is there so that we don't get diffs < 0
						} #end for $j (1..$dsRowC . . .
						#swap the newly subtracted arrays with the stCountN $stEvents arrays
						@stCount0=@stCountTemp;
						#clear the array for use in the next for loop
						@stCountTemp = ();
						
						#Once again with feeling for the other channels and the triggers:
						for $j (1..$dsRowCount){
							push(@stCountTemp, $stCount1[$j] - $stCount1[$j-1]) if $stCount1[$j] > $stCount1[$j-1];
						} #end for $j (1..$dsRow
						
						@stCount1=@stCountTemp;
						@stCountTemp = ();
						
						for $j (1..$dsRowCount){
							push(@stCountTemp, $stCount2[$j] - $stCount2[$j-1]) if $stCount2[$j] > $stCount2[$j-1];
						}#end for $j (1..$dsRow. . . 
						
						@stCount2=@stCountTemp;
						@stCountTemp = ();
						
						for $j (1..$dsRowCount){
							push(@stCountTemp, $stCount3[$j] - $stCount3[$j-1]) if $stCount3[$j] > $stCount3[$j-1];
						}#end for $j (1..$dsRow. . . 
						
						@stCount3=@stCountTemp;
						@stCountTemp = ();
						
						for $j (1..$dsRowCount){
							push(@stCountTemp, $stEvents[$j] - $stEvents[$j-1]) if $stEvents[$j] > $stEvents[$j-1];
						} #end for $j (1..$ds . . .
						@stEvents=@stCountTemp;
					} #end of if($stType = 2)
					
					
					# 3. Determine the rate
					#But those counts stored in the array are how many times the channel fired in the user-defined interval between the STs. Shouldn't it be a true rate?
					#Yep. Just divide the count by the difference in time between two reads. BUT we have to do this after counting up the totals in each array. It can't be done before then.
					
					if (($stTime[2]-$stTime[1]) > 0){ # it should have been caught by now, but still. . . 
						for $j (1..$dsRowCount-1){
                            if ($stTime[$j] > $stTime[$j-1]) {
								$stRate0[$j] = sprintf("%0.5f", $stCount0[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
								$stRate1[$j] = sprintf("%0.5f", $stCount1[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
								$stRate2[$j] = sprintf("%0.5f", $stCount2[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
								$stRate3[$j] = sprintf("%0.5f", $stCount3[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
								#The rate may be very low here. . .  
								#$stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stTime[$j] > $stTime[$j-1] && ($stEvents[$j]/($stTime[$j] - $stTime[$j-1]) > 1);
								#$stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stTime[$j] > $stTime[$j-1] && ($stEvents[$j]/($stTime[$j] - $stTime[$j-1]) < 1); # we've already ruled out counts < 0
                                $stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if ($stEvents[$j]/($stTime[$j] - $stTime[$j-1]) > 1);
                                $stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if ($stEvents[$j]/($stTime[$j] - $stTime[$j-1]) < 1); # we've already ruled out counts < 0
                            }
						}#end for $j (1..$d . . 
					}#end if (($stTime[2] . . .
					
					# 4. Sum up those cout N arrays to determine meta for counts in channels 0-3 and triggers and write those to meta.
					$chan0 += $_ for @stCount0;
					$chan1 += $_ for @stCount1;
					$chan2 += $_ for @stCount2;
					$chan3 += $_ for @stCount3;
					$events += $_ for @stEvents;
			
					
					# 5. Create and write metadata about the file that was just closed						
					#determine clock frequency
					calculate_cpld_frequency();

        	        $cpld_low = $cpld_freq - $cpld_sigma;
            	    $cpld_high = $cpld_freq + $cpld_sigma;
                	# only calculates the "real" average frequency using data within one standard deviation of averaged_sigma;
	                foreach $i (@cpld_frequency){ 
    	                if ($i >= $cpld_low && $i <= $cpld_high){
        	                $cpld_real_freq_tot += $i;
            	            $cpld_real_count++;
                	    }#end if ($i >=$cpld_low
	                }#end foreach
    	            $cpld_real_freq = sprintf("%0.0f",$cpld_real_freq_tot/$cpld_real_count) if $cpld_real_count !=0;
					print ERRORS "total rejects: ", $clock_problem_count, "\n";
					print ERRORS "total cpld count: ", $cpld_real_count, "\n";
					if ($cpld_real_count > 0) {
						print ERRORS "percentaje: ", $clock_problem_count/$cpld_real_count, "\n";
					}
					
					#check firmware being empty
					if ($DAQFirmware == 0) {
						calculate_firmware();
						$DAQFirmwareComments = "$DAQFirmware was calculated from the split data";
						print ERRORS "DAQFirmware: $DAQFirmware was calculated from the split data\n";
					}
										
					#Start writing meta and write metadata about the file that was just closed						
					#print META "enddate date $lastDate $lastTime\n";
					print META "enddate date ", 2000+substr($lastDate,4,2). "-". substr($lastDate,2,2). "-" . substr($lastDate,0,2) . " " .substr($lastTime,0,2). ":" .substr($lastTime,2,2). ":" .substr($lastTime,4,2),"\n";
					print META "ConReg0 string ", substr($ConReg,6,2),"\n";
					print META "ConReg1 string ", substr($ConReg,4,2),"\n";
					print META "ConReg2 string ", substr($ConReg,2,2),"\n";
					print META "ConReg3 string ", substr($ConReg,0,2),"\n";
					print META "TMCReg0 string ", substr($TMCReg,6,2), "\n";
					print META "TMCReg1 string ", substr($TMCReg,4,2), "\n";
					print META "TMCReg2 string ", substr($TMCReg,2,2), "\n";
					print META "TMCReg3 string ", substr($TMCReg,0,2), "\n";
					print META "DiscThresh0 int $thRow[0]\n"; 
					print META "DiscThresh1 int $thRow[1]\n"; 
					print META "DiscThresh2 int $thRow[2]\n"; 
					print META "DiscThresh3 int $thRow[3]\n"; 
					print META "DAQFirmware string $DAQFirmware\n";
					print META "chan1 int $chan0\n";
					print META "chan2 int $chan1\n";
					print META "chan3 int $chan2\n";
					print META "chan4 int $chan3\n";
					print META "triggers int $events\n";
        	        print META "cpldfrequency int $cpld_real_freq\n";
        	        print META "blessedstatus string awaiting\n"; # File now awaiting blessing
					print META "datalines int $data_line\n";
					print META "GPSSuspects int $GPSSuspects\n";
					if ($DAQFirmwareComments != "") {
						print META "DAQFirmwareComments string $DAQFirmwareComments";
					}
					
					# 6. Write the .bless file for the file that was just closed.
					#First the header
					
					print $blessFile "###Seconds (since Midnight UTC) \t Chan 0 rate \t Error in Chan0 \t Chan 1 rate \t Error in Chan1 \t Chan 2 rate \t Error in Chan2 \t Chan 3 rate \t Error in Chan3 \t Trigger rate\tError in Triggers \t Raw BA output \t Temp (DegC) \t Bus Voltage \t #GPS satellites in view \n";
					
					#Now the table
					#for my $i  (1..$dsRowCount-2){			
					#	print $blessFile "$stTime[$i]","\t", "$stRate0[$i]", "\t", sprintf("%0.0f", sqrt($stRate0[$i])), "\t", "$stRate1[$i]", "\t", sprintf("%0.0f", sqrt($stRate1[$i])),"\t", "$stRate2[$i]", "\t", sprintf("%0.0f", sqrt($stRate2[$i])),"\t", "$stRate3[$i]", "\t", sprintf("%0.0f", sqrt($stRate3[$i])), "\t", "$stEventRate[$i]", "\t", sprintf("%0.0f", sqrt($stEventRate[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
					#}

					#Changing the way that we calculate error. Bug #625
		
					#Now the table
					#for my $i  (1..$dsRowCount-2){			
					#	print $blessFile "$stTime[$i]","\t", "$stRate0[$i]", "\t", sprintf("%0.0f", sqrt($stRate0[$i])), "\t", "$stRate1[$i]", "\t", sprintf("%0.0f", sqrt($stRate1[$i])),"\t", "$stRate2[$i]", "\t", sprintf("%0.0f", sqrt($stRate2[$i])),"\t", "$stRate3[$i]", "\t", sprintf("%0.0f", sqrt($stRate3[$i])), "\t", "$stEventRate[$i]", "\t", sprintf("%0.0f", sqrt($stEventRate[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
					#}
		
					for my $i  (1..$dsRowCount-2){
                       if (($stRate0[$i]/($stTime[$i] - $stTime[$i-1])) >=0 && ($stRate1[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stRate2[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stRate3[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stEventRate[$i]/($stTime[$i] - $stTime[$i-1])) >= 0) {                      
    						print $blessFile "$stTime[$i]","\t", "$stRate0[$i]", "\t", sprintf("%0.5f", sqrt($stRate0[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stRate1[$i]", "\t", sprintf("%0.5f", sqrt($stRate1[$i]/($stTime[$i] - $stTime[$i-1]))),"\t", "$stRate2[$i]", "\t", sprintf("%0.5f", sqrt($stRate2[$i]/($stTime[$i] - $stTime[$i-1]))),"\t", "$stRate3[$i]", "\t", sprintf("%0.5f", sqrt($stRate3[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stEventRate[$i]", "\t", sprintf("%0.5f", sqrt($stEventRate[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
                       }
					}

					close $blessFile;	
					
					#Empty all of the status arrays so that they can start over with the new split file.
					@stTime = @StCoutTemp = @stCount0 = @stRate0 = @stCount1 = @stRate1 = @stCount2 = @stRate2 = @stCount3 = @stRate3 = @stEvents = @stRateEvents = @stType = @stPress = @stTemp = @StVcc = @stGPSSats = @stRow =  @cpld_frequency1 = @cpld_frequency2 = @stCountTemp = @cpld_frequency = ();
					@diff = @diffflowrate = ();
					#reset any scalars in use
					$GPSSuspectsTot += $GPSSuspects; #for the .raw file
					$data_line_total += $data_line; #for the .raw file
					$chan3=$chan2=$chan1=$chan0=$n=$i=$j=$stRowCount=$stType=$dsRowCount=$events=$GPSSuspects=$data_line=$cpld_real_freq_tot=$cpld_real_count=0;
					$clock_problem_count = 0;
					$DAQFirmware = $eventStart = 0;
					$DAQFirmwareComments = "";
					$goodChan=-1;
					$numSplitFiles++;
					#print "code never makes it here if datafile is < 1 day.\n";
				
				}#end if($lastDate ne "")
			#}#end if($date ne $lastDate)

			#open a NEW split file
			$index = 0;				#incremented if a split file of this name already exists
			$fn = "$ID.$year.$month$day.$index";
			#Need a bless file as well with the same file naming scheme
			$sfn = $fn.".bless";

			#plagued the Quarknet group since Summer 2003, solved on 8-5-04 (by using metadata)
			while(-e "$output_dir/$fn") {
				$index++;
				$fn = "$ID.$year.$month$day.$index";
				$sfn = $fn.".bless";
			} #end while(-e "$output...
				
			open(SPLIT,'>>', "$output_dir/$fn");
			push @splitscreated, "$fn";
			open($blessFile,'>>', "$output_dir/$sfn");
			
			$jd = jd($day, $month, $year, $hour, $min, $sec);	#GPS offset already taken into account from above

			# Write initial metadata for lfn that was just opened
			print META "[SPLIT] $output_dir/$fn\n";
			print META "creationdate date $today_date $today_time\n";
			print META "startdate date ", 2000+substr($date,4,2). "-". substr($date,2,2). "-" . substr($date,0,2) . " " .substr($time,0,2). ":" .substr($time,2,2). ":" .substr($time,4,2),"\n";
	        print META "julianstartdate float $jd\n";   # Earliest start date in file in julian days
			#print META "source string $fn\n";
			print META "source string $raw_filename\n"; #Fixes bug 457
			print META "detectorid string $ID\n";
			print META "type string split\n";
			print META "blessfile string $sfn\n"; 
			print ERRORS "[SPLIT] $output_dir/$fn\n";

		} # end  if($total_events > 0 && $stRowCount > 0)
			#$lastDate = $date;
			#$lasttime = $time;

			print SPLIT $_;
        	# Thanks to Nick Dettman for this code calculating actual CPLD frequency.
	        #@cpld_line = split(/\s+/, $_);
			$current_data_row = $_;
        
	        # if servicing 1PPS interrupt, the GPS time may be funny
		    $interrupt = (hex($dataRow[14]) & 0x01);
        	# calculates the number of seconds from the time and CPLD offset
	        $cpld_hour = substr($dataRow[10], 0, 2);
    	    $cpld_min = substr($dataRow[10], 2, 2);
        	#$cpld_sec = substr($dataRow[10], 4, 6);
    	    if ($DAQID >= 6000) {
	        	$cpld_sec = substr($dataRow[10], 4, 2);
    	    } else {
	        	$cpld_sec = substr($dataRow[10], 4, 6);
    	    }        	
	        $cpld_sec_offset = sprintf("%.0f", $cpld_sec + ($dataRow[15]/1000)); # if $DAQID < 6000 (removing the conditional to test fixes to shower);
			#6000 DAQ time calculation code should not use word 16 for anything.  
			if ($DAQID >= 6000) {
				$cpld_sec_offset = sprintf("%.0f", $cpld_sec); 
			} else {
				$cpld_sec_offset = sprintf("%.0f", $cpld_sec + ($dataRow[15]/1000)); 
			}
    	    $cpld_day_seconds = $cpld_hour*3600 + $cpld_min*60 + $cpld_sec_offset;
        	
        	$cpld_day_seconds = 0 if $cpld_day_seconds == 86400;
        	
        	#This code will write to an output file if the ticks changed but the clock didn't
        	#It is more for debugging purposes, just to see when this happens if it happens
 			if ($cpld_seconds == $cpld_day_seconds && $cpld_hex ne $dataRow[9]) {
        	    $cpld_ticks_new = hex($dataRow[9]);
            	$cpld_ticks_old = hex($cpld_hex);
                $dc_test = ($cpld_ticks_new - $cpld_ticks_old) % $N;
   			    $dt_test = ($cpld_day_seconds - $cpld_seconds);				
				print ERRORS "\n-->DIFFERENT CLOCK TICKS WHILE TIME IS THE SAME", "\n";
				print ERRORS $previous_data_row;
				print ERRORS $current_data_row;
				print ERRORS "dc: ", $dc_test, " dt: ", $dt_test, "\n";		
			}
		 	if (hex($dataRow[1]) >= 128) {
				$eventStart = $eventStart + 1;
			}

			#to calculate firmware from data
			if (defined $cpld_hex && defined $cpld_seconds) {
				if ($dataRow[9] ne $cpld_hex && $cpld_seconds == $cpld_day_seconds && hex($dataRow[1]) >= 128 && $data_line > 1) {
		 			$data9 = hex($dataRow[9]);
		 			$data0 = hex($dataRow[0]);
		 			$diff = $data0 - $data9;
					push @diff, $diff;
				}
			}	         
	        next if $cpld_hex eq $dataRow[9] || $cpld_seconds == $cpld_day_seconds || $interrupt != 0 || $time == $split_line[10];
	 
    	    if (defined($cpld_hex)){
        	    $cpld_ticks_new = hex($dataRow[9]);
            	$cpld_ticks_old = hex($cpld_hex);
                $dc = ($cpld_ticks_new - $cpld_ticks_old) % $N;
   			    $dt = ($cpld_day_seconds - $cpld_seconds);
  				$new_dt1 = $dt;
  				$new_dt2 = $dt;
  				#if the clock is wrong the $new_dt will be different
				check_clock_being_off();
				#only allow the clock being right
				if ($new_dt1 == $dt && $new_dt2 == $dt) {
	   		        #calculate CPLD frequency with first guess
    	    		$cpld_freq = $fg1 + (($dc - $fg1*$dt + $Nover2) % $N - $Nover2)/$dt;
        			$cpld_freq_tot1 += $cpld_freq;
    	    		push @cpld_frequency1, $cpld_freq;
        			#calculate CPLD frequency with second guess
            		$cpld_freq = $fg2 + (($dc - $fg2*$dt + $Nover2) % $N - $Nover2)/$dt;
        	  		$cpld_freq_tot2 += $cpld_freq;
    	    		push @cpld_frequency2, $cpld_freq;
              		$cpld_count++;
				}
        	} #end of if (defined($cpld_hex)
        	
        	# redefines variables for checking to see if the next line has the same data as this line
        	$cpld_time = $dataRow[10];
        	$cpld_hex = $dataRow[9];
        	# write to the error file if there was a problem with the clock
            if ($cpld_day_seconds != 0 && $cpld_day_seconds < $cpld_seconds) {
                print ERRORS "\nTIME DECREASED INSTEAD OF INCREASING:\n";
                print ERRORS $previous_data_row;
                print ERRORS $current_data_row;
            }
        	$cpld_seconds = $cpld_day_seconds;
        	$previous_data_row = $current_data_row;
		}	#end 
	} #end if rollover_flag == 0;
}	#end of reading the raw file

#die "This file contains no ST lines. We now require these lines. We've cancelled your upload. Please consult the DAQ HE screen to implement this feature of the hardware." if $stRowCount == 0;

if($total_events == 0){
	clean_failed_splits();
	die "No valid events found in your file ($raw_filename) of length $.\n";
}
else{
	#all of the next is for writing the bless file for the last SPLIT file
	if ($numSplitFiles == 0){
		$data_line_total = $data_line;
		$GPSSuspectsTot = $GPSSuspects;
	}
	
	# 1. Determine if the DAQ was producing ST2 or ST3 lines
	#When ST 2, the DAQ does not clear the onboard registers (that we call stCountN or stEvents here) after printing the lines. So the count in any channel over the time interval is the previous (stCount0 or stEvent) subtracted from the current (stCount0 or stEvent)
	#When ST3 these onboard registers are cleared after each printing, so there is no need to do the subtraction.
	#We just need to see if these (stCountN and stEvents) keep growing over the life of the file. If they do, we need to subtract one from the next to get the scalar increment over the integration time.
	
	#die "These data do not contain the same number of ST and DS lines; we have stopped your upload. We created $numSplitFiles usable file(s) before this error." if $dsRowCount != $stRowCount;
	if ($dsRowCount != $stRowCount || $dsRowCount == 0) {
		if ($numSplitFiles == 0) {
			clean_failed_splits();
			die "These data span at least one day that does not contain any 'ST', 'DS' line pairs--or, the data in those lines are munged.  We have stopped your upload.  We created $numSplitFiles usable file(s) before this error."; #(removing the comment before the OR in this conditional it somehow got removed).
		} else {
			warn "These data span at least one day that does not contain any 'ST', 'DS' line pairs--or, the data in those lines are munged.  We have stopped your upload.  We created $numSplitFiles usable file(s) before this error."; #(removing the comment before the OR in this conditional it somehow got removed).			
		}
	}
					
	if ($dsRowCount > 0){
		#First we need to learn which channel to look at (the trigger may be too slow) to see if it is working (i.e., plugged in & turned on).
		#The channel is off if the scalar hasn't incremented in 10 pings.						
		$goodChan = 0 if (($stCount0[0] != $stCount0[1]) || ($stCount0[0] == $stCount0[1] && $stCount0[1] != 0));
		$goodChan = 1 if (($stCount1[0] != $stCount1[1]) || ($stCount1[0] == $stCount1[1] && $stCount1[1] != 0)) && $goodChan == -1;
		$goodChan = 2 if (($stCount2[0] != $stCount2[1]) || ($stCount2[0] == $stCount2[1] && $stCount2[1] != 0)) && $goodChan == -1;
		$goodChan = 3 if (($stCount3[0] != $stCount3[1]) || ($stCount3[0] == $stCount3[1] && $stCount3[1] != 0)) && $goodChan == -1;

		if ($goodChan == -1) {
			if ($numSplitFiles == 0) {
				clean_failed_splits();					
				die "This detector has no working channels. We have stopped your upload. We created $numSplitFiles usable file(s) before this error.";
			} else {
				warn "This detector has no working channels. We have stopped your upload. We created $numSplitFiles usable file(s) before this error.";
			}
		}
					
		#now that we know what channel to look at, let's test for ST 2 or ST 3 by checking how often a scalar read is larger than the previous read.
		for $j (1..$dsRowCount-1){
			$n++ if $goodChan == 0 && $stCount0[$j] <= $stCount0[$j+1];
			$n++ if $goodChan == 1 && $stCount1[$j] <= $stCount1[$j+1];
			$n++ if $goodChan == 2 && $stCount2[$j] <= $stCount2[$j+1];
			$n++ if $goodChan == 3 && $stCount3[$j] <= $stCount3[$j+1];
		} # end of for (1..$stRowCount-2)
		#The last loop tells us how many times the count advanced from one DS to the next. If this number (n) is close to the number of rows, this detector is likely to be running ST 2.
		$j = 0;
		$stType = 3 if $n/$dsRowCount < 0.7;
		$stType = 2 if $n/$dsRowCount > 0.7;
	}
					
	# 2. Use the ST Type to re-write (possibly) the @stCountN arrays (i.e., $stCount0[n] must be subtacted from $stCount0[n+1] if ST 2)
	#We need to know how many times each channel (and the trigger) fired over the last interval. If this detector is running ST 2, the scalars aren't zero-ing after the last read. We need to subtract the value in row (i) from the value in row (i+1)
	#Row(i):	DS 000021E7 00001F05 00001F97 000021D8 00000021 
	#Row(i+1):	DS 000058F9 0000509C 000053C5 000058EB 00000054 
	#Row(i+2):	DS 0000903B 00008295 0000874F 0000900B 00000087 

	#These values now live in the arrays called stCount(0-3) and stEvents. What we need is the rate--not the counts. Also the counts need "fixing" if the detector is using ST 2
					
	#"fix" the arrays built with ST2.
	if ($stType == 2){
		for $j (1..$dsRowCount-1){
			#Subtract one from the previous (and not the latter) so that we see the rate in the last integration period (and not the next)
			push(@stCountTemp, $stCount0[$j] - $stCount0[$j-1]) if $stCount0[$j] > $stCount0[$j-1]; #the if is there so that we don't get diffs < 0
		}
		#swap the newly subtracted arrays with the stCountN $stEvents arrays
		@stCount0=@stCountTemp;
		#clear the array for use in the next for loop
		@stCountTemp = ();
						
		#Once again with feeling for the other channels and the triggers:
		for $j (1..$dsRowCount-1){
			push(@stCountTemp, $stCount1[$j] - $stCount1[$j-1]) if $stCount1[$j] > $stCount1[$j-1];
		}
		@stCount1=@stCountTemp;
		@stCountTemp = ();
						
		for $j (1..$dsRowCount-1){
			push(@stCountTemp, $stCount2[$j] - $stCount2[$j-1]) if $stCount2[$j] > $stCount2[$j-1];
		}
		@stCount2=@stCountTemp;
		@stCountTemp = ();
						
		for $j (1..$dsRowCount-1){
			push(@stCountTemp, $stCount3[$j] - $stCount3[$j-1]) if $stCount3[$j] > $stCount3[$j-1];
		}
		@stCount3=@stCountTemp;
		@stCountTemp = ();
						
		for $j (1..$dsRowCount-1){
			push(@stCountTemp, $stEvents[$j] - $stEvents[$j-1]) if $stEvents[$j] > $stEvents[$j-1];
		} 
		@stEvents=@stCountTemp;
	} #end of if($stType = 2)
					
					
	# 3. Determine the rate
	if (($stTime[2]-$stTime[1]) > 0){ # it should have been caught by now, but still. . . 
		for $j (1..$dsRowCount-1){
            if ($stTime[$j] > $stTime[$j-1]) {
			     $stRate0[$j] = sprintf("%0.5f", $stCount0[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
			     $stRate1[$j] = sprintf("%0.5f", $stCount1[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
			     $stRate2[$j] = sprintf("%0.5f", $stCount2[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
			     $stRate3[$j] = sprintf("%0.5f", $stCount3[$j]/($stTime[$j] - $stTime[$j-1]));# if $stTime[$j] > $stTime[$j-1];
			     #The rate may be very low here. . .  
			     #$stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stTime[$j] > $stTime[$j-1] && $stEvents[$j]/($stTime[$j] - $stTime[$j-1]) > 1;
			     #$stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stTime[$j] > $stTime[$j-1] && $stEvents[$j]/($stTime[$j] - $stTime[$j-1]) < 1; # we've already ruled out counts < 0
                 $stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stEvents[$j]/($stTime[$j] - $stTime[$j-1]) > 1;
                 $stEventRate[$j] = sprintf("%0.5f", $stEvents[$j]/($stTime[$j] - $stTime[$j-1])) if $stEvents[$j]/($stTime[$j] - $stTime[$j-1]) < 1; # we've already ruled out counts < 0
            }
		}
	}
	
	# 4. Sum up those arrays to determine meta for counts in channels 0-3 and triggers and write those to meta
	$chan0 += $_ for @stCount0;
	$chan1 += $_ for @stCount1;
	$chan2 += $_ for @stCount2;
	$chan3 += $_ for @stCount3;
	$events += $_ for @stEvents;
					
	# 5. Create and write metadata about the file that was just closed						
	# determine clock frequency
	calculate_cpld_frequency();

    $cpld_low = $cpld_freq - $cpld_sigma;
    $cpld_high = $cpld_freq + $cpld_sigma;
    # only calculates the "real" average frequency using data within one standard deviation of averaged_sigma;
	foreach $i (@cpld_frequency){ 
    	if ($i >= $cpld_low && $i <= $cpld_high){
        	$cpld_real_freq_tot += $i;
            $cpld_real_count++;
        }
	}
    $cpld_real_freq = sprintf("%0.0f",$cpld_real_freq_tot/$cpld_real_count) if $cpld_real_count !=0;
	print ERRORS "total rejects: ", $clock_problem_count, "\n";
	print ERRORS "total cpld count: ", $cpld_real_count, "\n";
	if ($cpld_real_count > 0) {
		print ERRORS "percentaje: ", $clock_problem_count/$cpld_real_count, "\n";
	}

	#check firmware being empty
	if ($DAQFirmware == 0) {
		calculate_firmware();
		$DAQFirmwareComments = "$DAQFirmware was calculated from the split data";
		print ERRORS "DAQFirmware: $DAQFirmware was calculated from the split data\n";
	}
						
	#Start writing meta and write metadata about the file that was just closed						
	#2000+substr($date,4,2). "-". substr($date,2,2). "-" . substr($date,0,2) . " " .substr($time,0,2). ":" .substr($time,2,2). ":" .substr($time,4,2),"\n"
	#print META "enddate date $lastDate $lastTime\n";
	print META "enddate date ", 2000+substr($lastDate,4,2). "-". substr($lastDate,2,2). "-" . substr($lastDate,0,2) . " " .substr($lastTime,0,2). ":" .substr($lastTime,2,2). ":" .substr($lastTime,4,2),"\n";
	print META "ConReg0 string ", substr($ConReg,6,2),"\n";
	print META "ConReg1 string ", substr($ConReg,4,2),"\n";
	print META "ConReg2 string ", substr($ConReg,2,2),"\n";
	print META "ConReg3 string ", substr($ConReg,0,2),"\n";
	print META "TMCReg0 string ", substr($TMCReg,6,2), "\n";
	print META "TMCReg1 string ", substr($TMCReg,4,2), "\n";
	print META "TMCReg2 string ", substr($TMCReg,2,2), "\n";
	print META "TMCReg3 string ", substr($TMCReg,0,2), "\n";
	print META "DiscThresh0 int $thRow[0]\n"; 
	print META "DiscThresh1 int $thRow[1]\n"; 
	print META "DiscThresh2 int $thRow[2]\n"; 
	print META "DiscThresh3 int $thRow[3]\n"; 
	print META "DAQFirmware string $DAQFirmware\n";
	print META "chan1 int $chan0\n";
	print META "chan2 int $chan1\n";
	print META "chan3 int $chan2\n";
	print META "chan4 int $chan3\n";
	print META "triggers int $events\n";
    print META "cpldfrequency int $cpld_real_freq\n";
	print META "blessedstatus string awaiting\n"; # File now awaiting blessing
	print META "datalines int $data_line\n";
	print META "GPSSuspects int $GPSSuspects\n";
	if ($DAQFirmwareComments != "") {
		print META "DAQFirmwareComments string $DAQFirmwareComments\n";
	}

					
	# 6. Write the .bless file for the file that was just closed.
	#First the header
	
	print $blessFile "###Seconds (since Midnight UTC) \t Chan 0 rate \t Error in Chan0 \t Chan 1 rate \t Error in Chan1 \t Chan 2 rate \t Error in Chan2 \t Chan 3 rate \t Error in Chan3 \t Trigger rate\tError in Triggers \t Raw BA output \t Temp (DegC) \t Bus Voltage \t #GPS satellites in view \n";
	
	#Changing the way that we calculate error. Bug #625
		
	#Now the table
	#for my $i  (1..$dsRowCount-2){			
	#	print $blessFile "$stTime[$i]","\t", "$stRate0[$i]", "\t", sprintf("%0.0f", sqrt($stRate0[$i])), "\t", "$stRate1[$i]", "\t", sprintf("%0.0f", sqrt($stRate1[$i])),"\t", "$stRate2[$i]", "\t", sprintf("%0.0f", sqrt($stRate2[$i])),"\t", "$stRate3[$i]", "\t", sprintf("%0.0f", sqrt($stRate3[$i])), "\t", "$stEventRate[$i]", "\t", sprintf("%0.0f", sqrt($stEventRate[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
	#}
	
	for my $i  (1..$dsRowCount-2){
        if (($stRate0[$i]/($stTime[$i] - $stTime[$i-1])) >=0 && ($stRate1[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stRate2[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stRate3[$i]/($stTime[$i] - $stTime[$i-1])) >= 0 && ($stEventRate[$i]/($stTime[$i] - $stTime[$i-1])) >= 0) {                      
    		print $blessFile "$stTime[$i]","\t", "$stRate0[$i]", "\t", sprintf("%0.5f", sqrt($stRate0[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stRate1[$i]", "\t", sprintf("%0.5f", sqrt($stRate1[$i]/($stTime[$i] - $stTime[$i-1]))),"\t", "$stRate2[$i]", "\t", sprintf("%0.5f", sqrt($stRate2[$i]/($stTime[$i] - $stTime[$i-1]))),"\t", "$stRate3[$i]", "\t", sprintf("%0.5f", sqrt($stRate3[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stEventRate[$i]", "\t", sprintf("%0.5f", sqrt($stEventRate[$i]/($stTime[$i] - $stTime[$i-1]))), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
        }
	}
					
	close $blessFile;	
	#write the channel counts for the last split file
	#Why is this here? Do we print this on the line confiming the upload? If so, it's wrong--it only holds the counts for the _last_ file.
	#print "$chan0 $chan1 $chan2 $chan3\n";

	if ($data_line_total==0){
		clean_failed_splits();
		die "There are no valid events in this file. There may be trigger data; if so, the timing solution is unreliable. Please file a helpdesk ticket.";
	}
	
	#insert metadata which was made from analyzing the WHOLE raw data file
	$endDateMeta = 2000+substr($date,4,2). "-". substr($date,2,2). "-" . substr($date,0,2);
	$endTimeMeta = substr($time,0,2). ":" .substr($time,2,2). ":" .substr($time,4,2);
	$GPSSuspectsTot += $GPSSuspects;
	`/usr/bin/perl -i -p -e 's/^ThisFileNeverCompletedSplitting.*/enddate date $endDateMeta $endTimeMeta/' "$raw_filename.meta"`;
	`/usr/bin/perl -i -p -e 's/^totalevents.*/totalevents int $total_events/' "$raw_filename.meta"`;
	`/usr/bin/perl -i -p -e 's/^nondatalines.*/nondatalines int $non_datalines/' "$raw_filename.meta"`;
	#print META "GPSSuspects int 0\n";
	#print META "totalDataLines int 0\n;"	
	`/usr/bin/perl -i -p -e 's/^GPSSuspectsTotal.*/GPSSuspectsTotal int $GPSSuspectsTot/' "$raw_filename.meta"`;
	`/usr/bin/perl -i -p -e 's/^totalDataLines.*/totalDataLines int $data_line_total/' "$raw_filename.meta"`;
	warn "Your uploaded data file contained $data_line_total accepted data lines. We ignored $GPSSuspectsTot line(s) due to a suspect GPS date.\n" if($data_line_total > 0);
	if($sum_lats == 0 or $sum_longs == 0 or $sum_alts == 0){
		warn "If you included DG commands in your file, there were fewer than six satellites in view when you did. We have ignored these DG commands; they provide an unreliable position.";
	}
	else{
		my $avg_lat = $sum_lats/$lat_count;
		my @avg_lat_arr = split(/\./, $avg_lat);
		my $avg_lat_str = sprintf("%d.%.4f", $avg_lat_arr[0], 60*(".".$avg_lat_arr[1]));
		my $avg_long = $sum_longs/$long_count;
		my @avg_long_arr = split(/\./, $avg_long);
		my $avg_long_str = sprintf("%d.%.4f", $avg_long_arr[0], 60*(".".$avg_long_arr[1]));
		my $avg_alt = sprintf("%.0f", $sum_alts/(10*$alt_count)); # round to the tens place since the GPS is very inaccurate
        $avg_alt *= 10;
		`/usr/bin/perl -i -p -e 's/^avglatitude.*/avglatitude string $avg_lat_str/' "$raw_filename.meta"`;
		`/usr/bin/perl -i -p -e 's/^avglongitude.*/avglongitude string $avg_long_str/' "$raw_filename.meta"`;
		`/usr/bin/perl -i -p -e 's/^avgaltitude.*/avgaltitude string $avg_alt/' "$raw_filename.meta"`;
		print META "Average latitude: $avg_lat_str\n";
		print META "Average longitude: $avg_long_str\n";
		print META "Average altitude: $avg_alt\n";
	}
}

sub calculate_firmware {
	$lineCount = 0;
	$diffOverCpld = 0;
	$diffCount = 0;
	foreach $i (@diff) {
		$lineCount = $lineCount + 1;
		$diffOverCpld = $i/$cpld_real_freq;
		if ($diffOverCpld < 0.07) {
			$diffCount = $diffCount + 1;
		}
	}
	$lineCountLowRate = 0;
	$diffOverCpldRate = 0;
	$diffCountLowRate = 0;
	foreach $i (@difflowrate) {
		$lineCountLowRate = $lineCountLowRate + 1;
		$diffOverCpldRate = $i/$cpld_real_freq;
		if ($diffOverCpldRate < 0.07) {
			$diffCountLowRate = $diffCountLowRate + 1;
		}
	}
	$ratio = 0;
	if ($ID < 6000) {
		$DAQFirmware = "0.0";
	} else {
		if ($eventStart > 0) {
			$ratio = $lineCount/$eventStart * 100;
		}
		#Mark Adams suggested checking that the collected problems is about 1% of the total number of events
		if ($lineCount > 0 && $ratio > 1) {
			if ($diffCount / $lineCount * 100 > 50) {
				$DAQFirmware = "1.11";
			} else {
				$DAQFirmware = "1.12";
			}
		} else {
			$ratio = 0;
			if ($eventStart > 0) {
				$ratio = $lineCountLowRate/$eventStart * 100;
			}
			#Mark Adams suggested checking that the collected problems is about 3% of the total number of events
			if ($lineCountLowRate > 0 && $ratio > 3) {
				if ($diffCountLowRate / $lineCountLowRate * 100 > 20) {
					$DAQFirmware = "1.11";
				} else {
					$DAQFirmware = "1.12";
				}				
			} else {
				$DAQFirmware = "1.12";
			}
		}
	}
}

sub check_clock_being_off{
	#This function will double check the seconds elapsed.
	$seconds_to_check = 100;	#add/subtract this number to find the shortest distance to the default cpdld
	$range_to_ignore = 10;		#if the cpld is already 10+/- we do not really care to do any calculations
    $current_cpld1 = $fg1 + (($dc - $fg1*$dt + $Nover2) % $N - $Nover2)/$dt;      	
    $current_cpld2 = $fg2 + (($dc - $fg2*$dt + $Nover2) % $N - $Nover2)/$dt;    
	$chosenguess;    
    if ($ID < 6000 ) {
    	$chosenguess = $fg1;
    } else {
    	$chosenguess = $fg2;
    }

	$diff1 = abs($chosenguess - $current_cpld1);
	$diff2 = abs($chosenguess - $current_cpld2);
	
	#no need to go further is the difference is close to zero
	if ($diff1 >= 0 && $diff1 <= $range_to_ignore && $diff2 >= 0 && $diff2 <= $range_to_ignore) {
		return;
	}

	$new_calc1 = $current_cpld1;
	$new_calc2 = $current_cpld2;
		
	for $i (1..$seconds_to_check){
		if ($dt+$i > 0) {
			$localdt = $dt+$i;
			$localcpld1 = $fg1 + (($dc - $fg1*$localdt + $Nover2) % $N - $Nover2)/$localdt;
			$localcpld2 = $fg2 + (($dc - $fg2*$localdt + $Nover2) % $N - $Nover2)/$localdt;
			if ($diff1 > abs($chosenguess - $localcpld1)) {
				$new_calc1 = $localcpld1;
				$diff1 = abs($chosenguess - $localcpld1);
				$new_dt1 = $localdt;
			}		
			if ($diff2 > abs($chosenguess - $localcpld2)) {
				$new_calc2 = $localcpld2;
				$diff2 = abs($chosenguess - $localcpld2);
				$new_dt2 = $localdt;
			}			
		}
		if ($dt-$i > 0) {
			$localdt = $dt-$i;
			$localcpld1 = $fg1 + (($dc - $fg1*$localdt + $Nover2) % $N - $Nover2)/$localdt;
			$localcpld2 = $fg2 + (($dc - $fg2*$localdt + $Nover2) % $N - $Nover2)/$localdt;
			if ($diff1 > abs($chosenguess - $localcpld1)) {
				$new_calc1 = $localcpld1;
				$diff1 = abs($chosenguess - $localcpld1);
				$new_dt1 = $localdt;
			}		
			if ($diff2 > abs($chosenguess - $localcpld2)) {
				$new_calc2 = $localcpld2;
				$diff2 = abs($chosenguess - $localcpld2);
				$new_dt2 = $localdt;
			}			
		}
	}

	if ($dt != $new_dt1 && $dt != $new_dt2) {
 		$data9 = hex($dataRow[9]);
 		$data0 = hex($dataRow[0]);
 		$diff = $data0 - $data9;
		push @difflowrate, $diff;

		$clock_problem_count = $clock_problem_count + 1;
		print ERRORS "\nCLOCK PROBLEMS, SECONDS ARE OFF\n";
		print ERRORS $previous_data_row;
		print ERRORS $current_data_row;
		print ERRORS "old dt1: ", $dt, " old calc1: ", $current_cpld1, " new calc1: ", $new_calc1, " new dt1: ", $new_dt1, "\n";		
		print ERRORS "old dt2 ", $dt, " old calc2: ", $current_cpld2, " new calc2: ", $new_calc2, " new dt2: ", $new_dt2, "\n";		
	}   
}

sub gps_check{
    #thanks to Nick Dettman for his research into this
	$line = $_[0];
	@split_line = split(/\s+/, $line);
    if(scalar(@split_line) > 1){
        if($split_line[1] eq "Status:"){
            $valid = $split_line[2];
        }
        elsif($split_line[1] eq "Latitude:"){
            $data[0] = $split_line[2];
            $NS = $split_line[3];
        }
        elsif($split_line[1] eq "Longitude:"){
            $data[1] = $split_line[2];
            $EW = $split_line[3];
        }
        elsif($split_line[1] eq "Altitude:"){
            $alt = $split_line[2];
        }
        elsif($split_line[1] eq "Sats"){
            $sats = $split_line[3];
        }
        else{
            #not a valid gps dataline
            return 0;
        }

        # decided that the best data to use for an accurate average is *valid* data that uses *6* or more satellites.
        return 1 if(!defined($valid) or $valid eq "V");
        return 1 if(!defined($sats) or $sats < 6);
        @lat = split(/:/, $data[0]);
        @long = split(/:/, $data[1]);
        $alt =~ s/m/0/;

        $latitude = $lat[0] + ($lat[1]/60);
        $longitude = $long[0] + ($long[1]/60);

        if($NS eq "S"){
            $latitude = $latitude*(-1);
        }
        if($EW eq "W"){
            $longitude = $longitude*(-1);
        }

        $sum_lats = $sum_lats + $latitude;
        $lat_count = $lat_count + 1;

        $sum_longs = $sum_longs + $longitude;
        $long_count = $long_count + 1;

        $sum_alts = $sum_alts + $alt;
        $alt_count = $alt_count + 1;

        return 1;
    }
    return 0;
}

sub stddev {
	 my $avg = shift;
	 my $n = shift;
	 
	 my $s = 0;
	 foreach $x (@_) {
	 	$s += ($avg - $x)**2;
	 }
	 return sqrt($s/$n);
}

#remove split files that did not complete or failed
sub clean_failed_splits {
	$raw_newname = "$raw_filename.failed";
	$meta_filename = "$raw_filename.meta";	
	$meta_newname = "$raw_filename.meta.failed";
	move($raw_filename, $raw_newname);
	move($meta_filename, $meta_newname);
	`gzip -9 $raw_newname`;
	unlink("$raw_filename.errors");
	unlink("$output_dir/$fn"); 
	unlink("$output_dir/$sfn");
}

sub calculate_cpld_frequency {
	if ($cpld_count == 0) {
		#one very tricky case this is
		#we have no way of finding out the frequency from the data so either the frequency has been calculated on a previous day, or this is the first day in which case we may look at subsequent days, or just print a warning because this is a borderline case
		if (defined $cpld_freq) {
			return;
		}
		else {
			$cpld_freq = $fg1 if $DAQID < 6000; 	#These data are from an older board--assuming the ID is correct!
			$cpld_freq = $fg2 if $DAQID > 5999;	#. . .  newer board
			push @cpld_frequency, $cpld_freq;
			$cpld_sigma = 0.0; 
			#print "Warning: Not enough data to calculate CPLD frequency. Your DAQ serial number is $ID so we are using $cpld_freq\n";
			return;
		}
	}
	# calculate averages for both guesses
	$cpld_freq1 = $cpld_freq_tot1/$cpld_count;
	$cpld_freq2 = $cpld_freq_tot2/$cpld_count;
	# calculate standard deviations for both CPLD frequency guesses
			
	$cpld_sigma1 = stddev($cpld_freq1, $cpld_count, @cpld_frequency1);
	$cpld_sigma2 = stddev($cpld_freq2, $cpld_count, @cpld_frequency2);
				
	# select the one with the lowest stddev
	# now, the guesses are only used when the
	# CPLD clock counter wraps around in weird ways
	# If that doesn't happen at all, both calculations
	# will yield the same result, so it doesn't matter
	# which one is chosen
	if ($cpld_sigma1 > $cpld_sigma2) {
		$cpld_sigma = $cpld_sigma2;
		$cpld_freq = $cpld_freq2;
		@cpld_frequency = @cpld_frequency2;
	}
	else {
		$cpld_sigma = $cpld_sigma1;
		$cpld_freq = $cpld_freq1;
		@cpld_frequency = @cpld_frequency1;
	}
}
