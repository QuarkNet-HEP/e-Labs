#!/usr/bin/perl

#Script for splitting user uploaded files according to the Julian Day of the first event
#
# usage: Split.pl [filename to parse] [output directory] [board ID]
#
# Paul Nepywoda, FNAL 1/2004
# revised, Yong Zhao, Mike Wilde, U.Chicago/Argonne, 3/2004
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

if($#ARGV < 2){
	die "usage: Split.pl [filename to parse] [output DIRECTORY] [board ID]\n";
}

use Time::Local 'timegm_nocheck';
use Math::BigInt;
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

($sec, $min, $hour, $day, $month, $year) = gmtime(time);
$year += 1900;
$today_date = sprintf("%04d-%02d-%02d", $year, $month+1, $day);
$today_time = sprintf("%02d:%02d:%02d", $hour, $min, $sec);

$raw_filename = $ARGV[0];
$output_dir=$ARGV[1];
$ID = $ARGV[2];
open IN, $raw_filename;

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
$last_time = "";					#this is simply words 1, 10, 11 and 16 contacenated together
$split_chan[$_] = 0 for (1..4);		#how many events are in each channel in a split file
$chanRE[$_] = 0 for (1..4);			#initilization for valid channel REs
$total_events = 0;					#total events in the raw file
$non_datalines = 0;					#junk lines
$raw_meta_written = 0;				#only open META file once
$lastdate = "";						#split files by days
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
$statusFlag = 0;					#Control structure to determine the presence of status lines--these go into the FOO.bless file.
#$blessFile = 0;						#filehandle to keep the blessfile in scope globally
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


$statusTime = 0;					#time stamp of the status line (in seconds since midnight.)
$statusVersion = 0;					#flag for version of the ST command used to generate the ST lines. One version will zero the scalars after each read (a trip meter) the other version will not (an odometer). We need to know which one is the case here so that the .bless files get populated with the correct rates.
#Removed the next line on 20 Feb 2010. I don't think we need it. 
#$oldStatusTime = 0;				#control to notice advancing status time The ^@!@#! flag isn't working. Maybe this will
$ConReg = 0;						#string to hold the contents of the control registers from the ST line
$TMCReg = 0;						#string to hold the contents of the TMC registes from the ST line

#convert MAC OS line breaks to UNIX
#Mac OS only has \r for new lines, so Unix reads it as all one big line. We first need to replace
# the \r with \n and then re-read the file, hence the "redo" command
$newline_fixing=1;
while(<IN>){
	$_ =~ s/\r\n?/\n/g;	#see http://www.westwind.com/reference/OS-X/commandline/text-files.html#text-formats
    #if($newline_fixing){
    #	$newline_fixing = 0;
    #   redo;
    #}
	
	#Had to change the regExp in Dec 07. The newest version of the hardware had some firmware versions that did not add the +/- to word 1 when it was 0000. This was fixed in firmware version 1.06, but some cards made it into the wild with earlier firmware.
	#$re="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+]\\d{4})\$";
	
	#OK the new regExp on the next line works. I did not add the + to the offset (word 16) but left it bare. The question is what does ThresholdTimes do with this? Do I need to add the + to make ThresholdTimes happy?
	$reData="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+ ]\\d{4})\$";

	#additional regExp to catch status lines
	#ST 1032 +279 +000 3354 070251 301009 A 05 BD8F8E15 111 6477 00231F00 000A711F

	$reStatus0="^([A-Z]{2}) ([0-9]{4}) ([-+ 0-9]{4}) ([-+ 0-9]{4}) ([0-9]{4}) ([0-9]{6}) ([0-9]{6}) ([AV]) ([0-9]{2}) ([0-9A-F]{8}) ([0-9]{3}) ([0-9]{4}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";
	#$reStatus0="^ST ([0-9]{4}) ([-+ 0-9]{4}) ([-+ 0-9]{4}) ([0-9]{4}) ([0-9]{6}) ([0-9]{6}) ([AV]) ([0-9]{2}) ([0-9A-F]{8}) ([0-9]{3}) ([0-9]{4}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";	
	#$reStatus1="^([A-Z]{2}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";
	$reStatus1="^DS ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8}) ([0-9A-F]{8})\$";
	
	#regExp for the output of the TL command:
	$reThreshold0="^TL L0=([0-9]+) L1=([0-9]+) L2=([0-9]+) L3=([0-9]+)\$";
	
	#*performance* using an RE is 30% faster than splitting by whitespace
	if(/$reData/o){
		@dataRow = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16);
		next if $dataRow[10] eq "000000.000" && $dataRow[11] eq "000000"; #munged GPS clock
		#$lastDay = substr($dataRow[11], 0, 2);
		$day = substr($dataRow[11], 0, 2);
		$month = substr($dataRow[11], 2, 2);
    	$year = substr($dataRow[11], 4, 2) + 2000;   # Assume no records before 2000
    	$hour = substr($dataRow[10], 0, 2);
	    $min = substr($dataRow[10], 2, 2);
	    $sec = substr($dataRow[10], 4, 2);
	    $msec = substr($dataRow[10], 7, 3);
	    $offset = $dataRow[15];
		$data_line ++;
	}

	#inserted by TJ to look for status update lines
	#Need to fix the problem with ST2 and ST3. The former does not reset the counter, and may roll over. We have asked the users to use ST2, but cannot trust that. I'll write the ST values to an array, scan the entire file, do a comparison on the DS values to determine if the user did ST2 or ST3 and do the subtraction (or not).
	
	elsif(/$reStatus0/o){
		@stRow = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14);
		$stRow = @stRow; 
		$stRowCount++;
		#print "ST line going by Boss.", "\n";
		push(@stTime, substr($stRow[5], 0, 2)*3600 + substr($stRow[5], 2, 2)*60 + substr($stRow[5], 4, 6));
		#$stRow[1], "\t", $stRow[3]/10, "\t", $stRow[4]/1000, "\t", $stRow[8], "\n"
		push(@stPress, $stRow[1]);
		push(@stTemp, $stRow[3]/10);
		push(@stVcc, $stRow[4]/1000);
		push(@stGPSSats, $stRow[8]);
		#$statusTime = substr($stRow[5], 0, 2)*3600 + substr($stRow[5], 2, 2)*60 + substr($stRow[5], 4, 6);
		#We could look at ConReg and TMCReg to see if they change. If they do, we need to start another split file.
		$ConReg = $stRow[13];
		$TMCReg = $stRow[12];
		$DAQFirmware = $stRow[10];
		next; #we need a next here to get the second line present in the output of ST.
	}
	
	elsif(/$reStatus1/o){
		@dsRow = ($1, $2, $3, $4, $5, $6);
		#$totalEvents += hex($dsRow[5]);
		push (@stCount0, hex($dsRow[1]));
		push (@stCount1, hex($dsRow[2]));
		push (@stCount2, hex($dsRow[3]));
		push (@stCount3, hex($dsRow[4]));
		push (@stEvents, hex($dsRow[5]));
		next; #get the next line in the input file. All the lifting is done on this one.
	}

	elsif(/$reThreshold0/o){
		@thRow = ($1, $2, $3, $4);
		next; #get the next line in the input file. All the lifting is done on this one.
	}

	elsif(&gps_check($_)){
        next;
	}
	else{
        $non_datalines++;
		next;
	}

	#The next section is devoted to cleaning up datalines before any more processing. 
	#There are five possible errors that can pollute the caluclation of $curr_gm_time.
	
	#The first error is a GPS flag of 4. It _always_ makes our calculation of $curr_gm_time incorrect. 

	#GPS flag = 4 in the raw data indicates that the GPS time in that line is suspect. Indeed, our calculation confirms this so we should ignore the lines with a GPS flag = 4. Now we do.
	#Actually it should check if bit 2 is 1. Otherwise it may accept invalid lines.
	next if ($dataRow[14] & 0x04 != 0); 

	#There are four asynchronous cpld rollover errors that can appear in the data, we can trap those and be more clever about dropping data lines.

	#first set the variables
	$cpld_latch = hex($dataRow[9]);
	$cpld_trig = hex($dataRow[0]);
		
	#Set the flag with a simple comparison of the buffers. Use the value of the flag as a control on further checks. Those checks can reset the flag to zero and go on or reset the flag to zero and discard the current line (rare).
	$rollover_flag = 1 if ($cpld_trig <= $last_cpld_trig && $cpld_latch > $last_cpld_latch);
	$rollover_flag = 2 if ($cpld_trig == $last_cpld_trig && $cpld_latch < $last_cpld_latch); #flag == 1 and flag == 2 can be dealt with in the same way.
	$rollover_flag = 3 if ($cpld_trig == $last_cpld_trig && $cpld_latch > $last_cpld_latch);
	#$rollover_flag = 4 if ($cpld_trig > $last_cpld_trig && $cpld_latch > $last_cpld_latch); #This should never, ever happen. Ever. Still. . . 
	#In fact it does happen. On every trigger. Always. The previous line is a good way to drop the first line of each event.
	#A new rollover case appeared in firmware 1.12 The GPS date could increment before the clock reached midnight.
	$rollover_flag = 5 if ($day != $lastDay) && (substr($dataRow[10], 0, 2) == 23) && (substr($dataRow[10], 2, 2) > 55); 
	#Set the current values of trig and latch for later comparison.
	$last_cpld_trig = $cpld_trig;
	$last_cpld_latch = $cpld_latch;

	#Check the cause of the rollover flags, decide whether to accept this line, reset the flag
	
	if ($rollover_flag == 1 || $rollover_flag == 2){
		$rollover_flag = 0; # reset the flag
		#ThresholdTimes can deal with these rollovers if the difference between the buffers is "large". Toss out lines with "small" differences.
		if ($cpld_latch - $cpld_trig < $CONST_hex8A && $cpld_trig < $cpld_latch){ 	#an arbitrarily large value.		
			$non_datalines++;
			next;		
		}
	}

	if ($rollover_flag == 3){
		$rollover_flag = 0; # reset the flag
		#An old board or a "small difference" makes this line invalid
		if ($ID <=5999 || $cpld_latch - $cpld_trig < $CONST_hex8A){	
			$non_datalines++;
			next;		
		}
	}
	
	#if ($rollover_flag == 4){
		#print $rollover_flag,"\t", $_;
	#	$rollover_flag = 0;
	#	next;
	#}
	
	if ($rollover_flag == 5){
		$rollover_flag = 0;
		next;
	}
	
if ($rollover_flag == 0){ #proceed with this line if it doesn't raise a flag.
	# get date/time of the current line
		if($last_time ne $dataRow[0].$dataRow[9].$dataRow[10].$dataRow[15]){
        	#*performance* NOT using a function call saves some compute time here
        	#($sec, $min, $hour, $day, $month, $year) = &curr_line_time_setup(@row);
       		
       		$lastDay = $day; 
       		
	        # hmm. there's an assumption there about the cpld frequency
	        $CPLDdifference = (hex($dataRow[0])-hex($dataRow[9]))/41666667;
	        $sec_offset = sprintf("%.0f", $sec + $msec/1000 + $offset/1000);
	        $sec = $sec_offset + $CPLDdifference;
	        #this is here because we require lines to go in the absolute correct day (with offsets taken into consideration)
	        #Note: most of the compute time of Split.pl is in these 2 calls
			$curr_gm_time = Time::Local::timegm_nocheck($sec, $min, $hour, $day, $month-1, $year);
			($sec, $min, $hour, $day, $month, $year) = (gmtime($curr_gm_time))[0..5];

			$year = $year+1900;
			$month = sprintf("%02d", $month+1);
			$day = sprintf("%02d", $day);
		}
		$last_time = $dataRow[0].$dataRow[9].$dataRow[10].$dataRow[15];

		#This next line may not be necessary after the dataRow[14]==4 check implemented above.
		next if($curr_gm_time < $last_gm_time);	#make sure that the GPS times are increasing
	
		$last_gm_time = $curr_gm_time;

		$date = sprintf("%04d-%02d-%02d", $year, $month, $day);
		$time = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
	
		
		#The stuff in the next for loop is really unneccessary with the data blessing scheme. I'm taking it out later.
		#count how many events are in this file in each channel
		for my $ch_num (1..4){
			$RE = $ch_num*2 - 1;	#index of each RE in the line
			$FE = $RE+1;

			if(hex($dataRow[1]) & 0b10000000){
				$chanRE[$ch_num] = 0;
				$total_events++;
			}

			#if there's a vaild (6th bit in binary is 1) rising edge we need to match
			if($chanRE[$ch_num] == 1 and (hex($dataRow[$FE]) & 0b100000)){
				$split_chan[$ch_num]++;
				$raw_chan[$ch_num]++;
				$total_events++;
				#clear array index since RE-FE match complete:
				$chanRE[$ch_num] = 0;

				#now, if there's rising edge data on the same line, it's the start of a new event (unrelated to the falling edge on this line)
				if(hex($dataRow[$RE]) & 0b100000){
					$chanRE[$ch_num] = 1;
				}
			}
			#else, this rising edge is unmatched and is the start of a new event
			elsif(hex($dataRow[$RE]) & 0b100000){
				$chanRE[$ch_num] = 1;

				#now, if there's a valid falling edge (on the same line)
            	if(hex($dataRow[$FE]) & 0b100000){
				    $split_chan[$ch_num]++;
				    $raw_chan[$ch_num]++;
				    $total_events++;
				    #clear array index since RE-FE match complete:
	                $chanRE[$ch_num] = 0;
	            }
			}
		}
 

		#don't write any split files or metadata if there are no events
		if($total_events > 0){
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
				print META "detectorid string $ID\n";
				print META "type string raw\n";
				$earliest_start = $date . " " . $time;
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
				print META "DiscThresh0 int  $thRow[0]\n"; 
				print META "DiscThresh1 int  $thRow[1]\n"; 
				print META "DiscThresh2 int  $thRow[2]\n"; 
				print META "DiscThresh3 int  $thRow[3]\n"; 
				print META "DAQFirmware int $DAQFirmware\n";
			}

			# When we see new day, split file at the day boundary
			# Mike suggested that we split at midnight, even though Julian Days begin at Noon

			if($date ne $lastdate) {	#start of a new output file
				if ($lastdate ne "") {
					
					# Write additional metadata annotation for most recent split file
					print META "chan1 int $split_chan[1]\n";
					print META "chan2 int $split_chan[2]\n";
					print META "chan3 int $split_chan[3]\n";
					print META "chan4 int $split_chan[4]\n";
					print META "enddate date $lastdate $lasttime\n";
					print META "ConReg0 string ", substr($ConReg,6,2),"\n";
					print META "ConReg1 string ", substr($ConReg,4,2),"\n";
					print META "ConReg2 string ", substr($ConReg,2,2),"\n";
					print META "ConReg3 string ", substr($ConReg,0,2),"\n";
					print META "TMCReg0 string ", substr($TMCReg,6,2), "\n";
					print META "TMCReg1 string ", substr($TMCReg,4,2), "\n";
					print META "TMCReg2 string ", substr($TMCReg,2,2), "\n";
					print META "TMCReg3 string ", substr($TMCReg,0,2), "\n";
					
					print META "DiscThresh0 int  $thRow[0]\n"; 
					print META "DiscThresh1 int  $thRow[1]\n"; 
					print META "DiscThresh2 int  $thRow[2]\n"; 
					print META "DiscThresh3 int  $thRow[3]\n"; 
					print META "DAQFirmware int $DAQFirmware\n";

				
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
    	            $cpld_real_freq = $cpld_real_freq_tot/$cpld_real_count if $cpld_real_count !=0;
                    
        	        print META "cpldfrequency float $cpld_real_freq\n";
					close SPLIT;
					#close $blessFile;
					#write the .bless file for this file.					
					for my $i  (1..$stRowCount){			
						print $blessFile "$stTime[$i]","\t", "$stCount0[$i]", "\t", sprintf("%0.0f", sqrt($stCount0[$i])), "\t", "$stCount1[$i]", "\t", sprintf("%0.0f", sqrt($stCount1[$i])),"\t", "$stCount2[$i]", "\t", sprintf("%0.0f", sqrt($stCount2[$i])),"\t", "$stCount3[$i]", "\t", sprintf("%0.0f", sqrt($stCount3[$i])), "\t", "$stEvents[$i]", "\t", sprintf("%0.0f", sqrt($stEvents[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n"; 	
					}
					close $blessFile;	
					#Empty all of the status arrays so that they can start over with the new split file.
					@stTime = ();
					@stCount0 = ();
					@stCount1 = ();
					@stCount2 = ();
					@stCount3 = ();
					@stEvents = ();
					@stPress = ();
					@stTemp = ();
					@StVcc = ();
					@stGPSSats = ();
					@stRow = ();
                	@cpld_frequency1 = (); # reset the array for the new split file.
	                @cpld_frequency2 = (); # reset the array for the new split file.
                	$stRowCount = 0;

					#write the channel counts for the most recent split file
					#Why is this here?
					#TJ took it out on 27 April
					#print "$split_chan[1] $split_chan[2] $split_chan[3] $split_chan[4]\n";

					#clear out count for channel events
					$split_chan[$_] = 0 for (1..4);
					#Clear all the status arrays.
					@STTime = ();
				}

				#open a NEW split file
				$index = 0;				#incremented if a split file of this name already exists
				$fn = "$ID.$year.$month$day.$index";
				#plagued the Quarknet group since Summer 2003, solved on 8-5-04 (by using metadata)
				while(-e "$output_dir/$fn") {
					$index++;
					$fn = "$ID.$year.$month$day.$index";
				}
				
				#Need a status file as well with the same file naming scheme
				$sfn = $fn.".bless";
				
				open(SPLIT,'>>', "$output_dir/$fn");
				open($blessFile,'>>', "$output_dir/$sfn");
				#print $blessFile $data_line, "\n";
				#informational printout only (all metadata should be retrieved from the .meta file)
				#Why is this here? TJ removed in Dec 2006
				
				$jd = jd($day, $month, $year, $hour, $min, $sec);	#GPS offset already taken into account from above

				# Write initial metadata for lfn that was just opened
				print META "[SPLIT] $output_dir/$fn\n";
				print META "creationdate date $today_date $today_time\n";
				print META "startdate date $date $time\n";
	            print META "julianstartdate float $jd\n";   # Earliest start date in file in julian days
				print META "source string $fn\n";
				print META "detectorid string $ID\n";
				print META "type string split\n";
			}
			$lastdate = $date;
			$lasttime = $time;

			print SPLIT $_;
        
        	# Thanks to Nick Dettman for this code calculating actual CPLD frequency.
	        #No need for that. We already have the split row.
    	    #@cpld_line = split(/\s+/, $_);
        
	        # if servicing 1PPS interrupt, the GPS time may be funny
		    $interrupt = (hex($dataRow[14]) & 0x01);
        	# calculates the number of seconds from the time and CPLD offset
	        $cpld_hour = substr($dataRow[10], 0, 2);
    	    $cpld_min = substr($dataRow[10], 2, 2);
        	$cpld_sec = substr($dataRow[10], 4, 6);
	        $cpld_sec_offset = sprintf("%.0f", $cpld_sec + ($dataRow[15]/1000));
    	    $cpld_day_seconds = $cpld_hour*3600 + $cpld_min*60 + $cpld_sec_offset;
        	if ($cpld_day_seconds == 86400){
            	$cpld_day_seconds = 0;
	        }
    	    if (($cpld_hex eq $dataRow[9]) || ($cpld_seconds == $cpld_day_seconds) || ($interrupt != 0) || ($time == $split_line[10])){ 
        		# both columns must advance to calculate the change
            	next;
	        }
        
        
    	    if (defined($cpld_hex)){
        	    $cpld_ticks_new = hex($dataRow[9]);
            	$cpld_ticks_old = hex($cpld_hex);
            
	            $dc = ($cpld_ticks_new - $cpld_ticks_old) % $N;
   			    $dt = ($cpld_day_seconds - $cpld_seconds);
   		    
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
        	# redefines variables for checking to see if the next line has the same data as this line
        	$cpld_time = $dataRow[10];
        	$cpld_hex = $dataRow[9];
        	$cpld_seconds = $cpld_day_seconds;
		}	#end if total_events > 0
	} #end of rollover_flag == 0;
}	#end of reading the raw file

if($total_events == 0){
	die "No valid events found in your file ($raw_filename) of length $.\n";
}
else{
	#write the channel counts for the last split file
	print "$split_chan[1] $split_chan[2] $split_chan[3] $split_chan[4]\n";

	#additional metadata for the last split file
	print META "chan1 int $split_chan[1]\n";
	print META "chan2 int $split_chan[2]\n";
	print META "chan3 int $split_chan[3]\n";
	print META "chan4 int $split_chan[4]\n";
	print META "enddate date $date $time\n";
	print META "ConReg0 string ", substr($ConReg,6,2),"\n";
	print META "ConReg1 string ", substr($ConReg,4,2),"\n";
	print META "ConReg2 string ", substr($ConReg,2,2),"\n";
	print META "ConReg3 string ", substr($ConReg,0,2),"\n";
	print META "TMCReg0 string ", substr($TMCReg,6,2), "\n";
	print META "TMCReg1 string ", substr($TMCReg,4,2), "\n";
	print META "TMCReg2 string ", substr($TMCReg,2,2), "\n";
	print META "TMCReg3 string ", substr($TMCReg,0,2), "\n";
	print META "DiscThresh0 int  $thRow[0]\n"; 
	print META "DiscThresh1 int  $thRow[1]\n"; 
	print META "DiscThresh2 int  $thRow[2]\n"; 
	print META "DiscThresh3 int  $thRow[3]\n";
	print META "DAQFirmware int $DAQFirmware\n";


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
    $cpld_real_freq = $cpld_real_freq_tot/$cpld_real_count if $cpld_real_count !=0;
    print META "cpldfrequency float $cpld_real_freq\n";

	#Write the .bless information for the last file.	
	#First have to see if the statusVersion should be 0 or 1.
	#for my $i  (1..$stRowCount){ #go through all of the arrays
	#	$statusVersion = 1 if ($stCount0[$i] < $stCount0[$i-1]) || ($stCount1[$i] < $stCount1[$i-1]) || ($stCount2[$i] < $stCount2[$i-1]) || ($stCount3[$i] < $stCount3[$i-1]) || ($stEvents[$i] < $stEvents[$i-1]); #Must be using ST3 (trip meter) as ST2 (odometer) always increases (unless it rolls over.)
		#last $i if $statusVersion == 1;
	#}
	#Use that index find the last stCountNUM value for comparison with the one going into the array
	#Do the comparison for all five scalars: oldScalar <? new Scalar
	#If that is ever true (for any of the scalars) set the flag to do the subtraction later.)
	#print "@STEvents", "\n"; 
	#$statusFlag = 1;
	#print $blessFile $statusTime, "\t", hex($dsRow[1]), "\t", sprintf("%.0f", sqrt(hex($dsRow[1]))), "\t", hex($dsRow[2]), "\t", sprintf("%.0f", sqrt(hex($dsRow[2]))), "\t", hex($dsRow[3]), "\t", sprintf("%.0f", sqrt(hex($dsRow[3]))), "\t", hex($dsRow[4]), "\t", sprintf("%.0f", sqrt(hex($dsRow[4]))), "\t", hex($dsRow[5]), "\t", sprintf("%.0f", sqrt(hex($dsRow[5]))), "\t", $stRow[1], "\t", $stRow[3]/10, "\t", $stRow[4]/1000, "\n";
	
	
	#$i=0;
	for my $i  (1..$stRowCount){
		#The columns here are: Time, Ch0, Err0, Ch1, Err1, Ch2, Err2, Ch3, Err3, Trg, ErrTrg, EventCount, Pressure, Temperature, Vcc, #Sats
		print $i, "\n";
		print $blessFile "$stTime[$i]","\t", "$stCount0[$i]", "\t", sprintf("%0.0f", sqrt($stCount0[$i])), "\t", "$stCount1[$i]", "\t", sprintf("%0.0f", sqrt($stCount1[$i])),"\t", "$stCount2[$i]", "\t", sprintf("%0.0f", sqrt($stCount2[$i])),"\t", "$stCount3[$i]", "\t", sprintf("%0.0f", sqrt($stCount3[$i])), "\t", "$stEvents[$i]", "\t", sprintf("%0.0f", sqrt($stEvents[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n";# if $statusVersion == 1; 	
		#print $blessFile "$stTime[$i]","\t", "$stCount0[$i]", "\t", sprintf("%0.0f", sqrt($stCount0[$i])), "\t", "$stCount1[$i]", "\t", sprintf("%0.0f", sqrt($stCount1[$i])),"\t", "$stCount2[$i]", "\t", sprintf("%0.0f", sqrt($stCount2[$i])),"\t", "$stCount3[$i]", "\t", sprintf("%0.0f", sqrt($stCount3[$i])), "\t", "$stEvents[$i]", "\t", sprintf("%0.0f", sqrt($stEvents[$i])), "\t", "$stPress[$i]", "\t", "$stTemp[$i]", "\t", "$stVcc[$i]", "\t", "$stGPSSats[$i]","\n" if $statusVersion == 1; 	
		print $statusVersion, "\n" if $statusVersion == 0;
	}
	
	#insert metadata which was made from analyzing the WHOLE raw data file
	`/usr/bin/perl -i -p -e 's/^ThisFileNeverCompletedSplitting.*/enddate date $date $time/' "$raw_filename.meta"`;
	`/usr/bin/perl -i -p -e 's/^totalevents.*/totalevents int $total_events/' "$raw_filename.meta"`;
	`/usr/bin/perl -i -p -e 's/^nondatalines.*/nondatalines int $non_datalines/' "$raw_filename.meta"`;
	warn "Bad/ignored lines: $non_datalines Accepted lines: $data_line\n" if($non_datalines > 0);
	if($sum_lats == 0 or $sum_longs == 0 or $sum_alts == 0){
		warn "There was no gps information with sufficient satellites for a position fix in this file. (the \"DG\" command on the board)\n";
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

sub calculate_cpld_frequency {
	if ($cpld_count == 0) {
		#one very tricky case this is
		#we have no way of finding out the frequency from the data
		#so either the frequency has been calculated on a previous
		#day, or this is the first day in which case
		#we may look at subsequent days, or just print a warning because 
		#this is a borderline case
		if (defined $cpld_freq) {
			return;
		}
		else {
			$cpld_freq = $fg1 if $ID < 6000; 	#These data are from an older board--assuming the ID is correct!
			$cpld_freq = $fg2 if $ID > 5999;	#. . .  newer board
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
