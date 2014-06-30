#!/usr/bin/perl
#ThresholdTimes.pl
#   - calculates the absolute time of both the rising edge and falling edge for an event down to 3/4 of a nanosecond
#   - outputs a file where each line is: the_detector_id.channel_number julian_day rising_edge falling_edge time_over_threshold


# TJ Added output to file named by timestamp of job. 30 September 2003
# TJ removed print to Std out on 2 October.
#28 October remove constructed arguments and rely on _all_ arguments from command line. Before uploading to the portal.
# YW modified timeoverthresh function so that $REtime, $FEtime, and $nanodifference are now arrays instead of single variables, so they do not get overwritten when ThresholdTimes.pl is applied to multiple channels simultaneously. 1/6/04
# Nepywoda modified on 1-13-04: the new format for our arguments is: [infile] [outfile] [ other arguments... ].
#	Also, we no longer need to specify whether we want only RE, FE, or Threshold. We're going to output all 3 all the time from now on.
#	Also, we no longer specify which channel we want. The output will always have all 4 channels in it.
#Jan14 2004 Logic was added to check for onboard clock rollover (which happens every ~=103 sesconds) and also when the pps pulse either updates when it shouldn't or doesn't update at all. When a RE and FE comes in on seperate lines, for the falling edge the ppsCount, which is column 10, might not be updated correctly. We fix this by ignoring the ppsCount from the falling edge and using the ppsCount from the RE only, and doing all math in terms of the RE ppsCount.
#
#Nepywoda changed (way too much) on 1-15-04:
# Our new format for the output of thresholdtimes is as follows:
# [ID].[channel] [JD]{floor(JD of the current event time)} [REtime]{16 digit decimal precision in partial JD} [FEtime]{16 digit decimal precision in partial JD} [TOT]{2 digit decimal precision in nanoseconds}
# Note: the RE and FE times are fractions of a day since the JD time listed in column 2
# We did this because we needed to know which events went with which day in combined files.
# Also, there was considerable debate about whether we were getting the precision we needed with using a precision of 3/4 of a nanosecond on the board. Perl converts variables from strings to C-style doubles (8 bytes) when doing operations. It turns out that a 64bit double has a precision of around 1.11e-16 in decimal when considering numbers with a .999 < max < 1.00. 3/4 of a nanosecond is precise to the e-15th decimal bit, so we're barely safe in that respect. For printing out, we'll round/print out to the 16th decimal place, even though in some cases that's not our true precision (but it's not LESS than the precision of 3/4 nanosecond).
# Reference for double type: http://babbage.cs.qc.edu/courses/cs341/IEEE-754.html
#Nepywoda changed on 3-25-04:
# Threshold times are now all positive values. Problem was having a falling edge matching a previous rising edge on the same line as a NEW rising edge.
# Now we're correctly using the 6th bit of the RE/FE data to determine if it's valid or not
#Nepywoda changed on 6-9-04 - now using timegm_nocheck to add in the "word 16" GPS offset.
#Nepywoda changed on 7-5-04 - performance increase of 39% by optimizing calculations
# nepywoda 7-13-04: argument tests and correct warning/error output
# nepywoda 8-1-04: fixed bugs with calculating the julian day around noon


if($#ARGV < 2){
	die "usage: ThresholdTimes.pl [\"input-file1 input-file2 ... \"] [\"output-file1 output-file2 ... \"] [\"board-ID1 board-ID2 ...\"] {[\"cpld-freq1 cpld-freq2 ... \"]}  You have ".($#ARGV+1)." arguments and they are \"@ARGV\"\n";
}

#$commonsubs_loc="/export/d1/paul/portal/application/CommonSubs.pl";
$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
	warn "couldn't parse $commonsubs_loc $@" if $@;
	warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
	warn "couldn't run $commonsubs_loc"       unless $return;
	die;
}
#use Time::Local 'timegm_nocheck';
$last_gps_day = "";
$last_sec_string = "";
#define CONSTANTS for better performance
$CONST_hex8A = hex('AAAAAAAA');
$CONST_hex8F = hex('FFFFFFFF');

#Set the command line arguments
@infile = split (/\s+/, $ARGV[0]);
@ofile = split (/\s+/, $ARGV[1]);
@serialNumber = split (/\s+/, $ARGV[2]);
@cpld_frequency = split (/\s+/, $ARGV[3]);

#NOTE: gateWidth isn't really used in any calculation. We used to use it in edgetime's calculation but not anymore
#$gateWidth = 240e-9;   #const gateWidth in seconds
$max=2**31;
die "The number of inputs, outputs, and serial numbers must match! (args: @ARGV)\n" if($#infile != $#ofile or $#infile != $#serialNumber);

use Digest::MD5 qw(md5_hex);

#While there are more files to parse, go through each line of the raw data file, performing the transformation
while($infile=shift(@infile)){
	$ofile=shift (@ofile);
	$serialNumber=shift (@serialNumber);
    $cpld_frequency = shift(@cpld_frequency);
    if($cpld_frequency eq ""){
        $cpld_frequency = 41666667;
    }

    $cpldResFreq = $cpld_frequency*32;  #cpld resolution frequency is 32 times the clock freq (Hz)
	die "The detector's serial number ($serialNumber) must be positive.\n" if($serialNumber <=0);

    #md5 input/output file comparison
    my $str = join " ", @ARGV[0..$#ARGV];
    my $mtime1 = (stat($0))[9];         #this script's timestamp
    my $mtime2 = (stat($infile))[9];    #input file's timestamp
    my $mtime3 = (stat("$geo_dir/$serialNumber/$serialNumber.geo"))[9];
    $str = "$mtime1 $mtime2 $str $mtime3";
    my $md5 = md5_hex($str);
    if(-e $ofile){
        $outmd5 = `head -n 1 $ofile`;
        $outmd5 = substr($outmd5, 1);
        chomp $outmd5;
        print "md5s COMPUTED:$md5 FROMFILE:$outmd5\n";
        if($md5 eq $outmd5){
            print "input argument md5's match, not re-calculating output file: $ofile\n";
            next;
        }
    }
	
	#Open input and output files
	open(IN, "$infile")  || die "Cannot open $infile for input";
	open (OUT1, ">$ofile")  || die "Cannot open $ofile for output";

	#@REorphan = (0,0,0,0,0);	#for 'info_output'

	#print the header
    print OUT1 ("#$md5\n");
    print OUT1 ("#md5_hex($str)\n");
	print OUT1 ("#ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec)\n");

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

        #next if /^\s*#/;
		#Had to change the regExp in Dec 07. The newest version of the hardware had some firmware versions that did not add the +/- to word 1 when it was 0000. This was fixed in firmware version 1.06, but some cards made it into the wild with earlier firmware.
	#$re="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+]\\d{4})\$";
	
	#OK the new regExp on the next line works. I did not add the + to the offset (word 16) but left it bare. 
	$re="^([0-9A-F]{8}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{2}) ([0-9A-F]{8}) (\\d{6}\\.\\d{3}) (\\d{6}) ([AV]) (\\d\\d) ([0-9A-F]) ([-+ ]\\d{4})\$";

        #@row=split(/ /, $_);	#parse 1 line of the raw data into an array called @row
        #*performance* using an RE is 30% faster than split
        if(/$re/o){
            @row = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16);
        }
        else{
			#print "WARNING! Junk on line $.. Ignoring line:\n $_";		#printing too much to STDOUT makes java/jsp hang (on 8-10-04)
            next;
        }
        #print OUT1 @row;
		#calculate timeoverthreshold for all 4 channels
        for my $i (1..4) {
            &timeoverthresh($i, @row);
        }
        $count4++;
	}
	close IN;
	
	#undef last_gps_day to help with bug 229
	$last_gps_day = undef;
	#'info_output' - some statistics of this file
    #print "Number of \"Orphan fixes\" for $ofile:\n";
    #print "chan1: $REorphan[1] chan2: $REorphan[2] chan3: $REorphan[3] chan4: $REorphan[4]\n";
    #print "DEBUG: currentPpsSeconds:$count1 $count11 compute_jd:$count2 $count22 lines:$count4\n";
	print "WARNING! No matching RE-FE pairs found in the file: $infile\n" if($count2 < 1);
}


#Functions
# &timeoverthresh function looks at one channel of raw data, finds the rising edge and falling edge, and calculates the time over threshold
sub timeoverthresh {
	$ch_num = $_[0];	#The 1st argument passed into the function is the channel number
	$row = $_[1];		#The 2nd argument passed into the function is @row

	$RE = 2*$ch_num-1;	#Index used to locate the RE data for the channel
	$FE = $RE+1;		#Index used to locate the FE data for the channel

	#ORPHAN RISING EDGE FIX:
	# (note: this isn't a "fix" but clearing the retime-fetime pair every time there's a new board-event PREVENTS the "orphan rising edge")
	#7957DD68 80 01 00 01 28 3D 00 01 76E8AA18 230736.331 210703 A 04 2 -0477
	#7957DD6B 00 01 00 01 32 01 00 01 79647272 230736.331 210703 A 04 0 +0522
	#7DDF35FD 80 01 00 01 25 36 00 01 7BE03ACE 230738.331 210703 A 04 0 -0485
	# If a rising edge occurs close to the end of the (default) 250ns board-gate-width, then it's matching falling edge may occur outside of the board's gate, meaning it will be dropped (since the board defines the beginning of a "new event/gate width" as the time it sees a rising edge. Attempt at a diagram: [RE1...FE1.................RE2...]...FE2. <- so the 2nd falling edge isn't recorded on the board and the 2nd rising edge is "orphaned".
    if(hex($row[1]) & 0b10000000){
        #$REorphan[$ch_num]++ if(exists($chan[$ch_num]{retime}));	#for 'info_output'
        $chan[$ch_num] = ();
    	#print "orphan fix ";
    }

	#if there's a valid (6th bit in binary is 1) rising edge we need to match
	if(exists($chan[$ch_num]{retime}) and (($decFE=hex($row[$FE])) & 0b100000)){
        $chan[$ch_num]{fetime} = &calctime(\%{$chan[$ch_num]}, $decFE, @row);
		#print data if there's an event
		if(exists($chan[$ch_num]{retime}) and exists($chan[$ch_num]{fetime})){
			&print_data();
            $chan[$ch_num] = ();	#clear the hash since the RE-FE match is complete
		}

		#now, if there's rising edge data on the same line, it's the start of a new event (unrelated to the falling edge on this line)
		if(($decRE=hex($row[$RE])) & 0b100000){
            $chan[$ch_num]{retime} = &calctime(\%{$chan[$ch_num]}, $decRE, @row);
		}
	}
	#else, this rising edge is unmatched and is the start of a new event
	elsif(($decRE=hex($row[$RE])) & 0b100000){
        $chan[$ch_num]{retime}=calctime(\%{$chan[$ch_num]}, $decRE, @row);
		
		#now, if there's rising edge data (on the same line) and a valid falling edge
		if(exists($chan[$ch_num]{retime}) and (($decFE=hex($row[$FE])) & 0b100000)){
            $chan[$ch_num]{fetime}=calctime(\%{$chan[$ch_num]}, $decFE, @row);
		}

		#print data if there's an event
		if(exists($chan[$ch_num]{retime}) and exists($chan[$ch_num]{fetime})){
			&print_data;
            $chan[$ch_num] = ();	#clear the hash since the RE-FE match is complete
		}
	}
}



#calctime: calculate the absolute time down to 3/4s of a nanosecond of an edge
# We're using the rising edge's gps time as a base for calculating both the rising and falling edge data (since the gps isn't 100% correct on every row)
# inputs:
# 1) a hash reference for a certain channel (containing any of: {retime}, {fetime}, {rePpsCount}, {rePpsTime})
# 2) a 2-digit decimal value for either the rising or falling edge data
# 3) current @row array from raw data
# output:
# - returns an edgetime in partial days (seconds/86400)
sub calctime {
	($chandata, $edge, $row) = @_;
	$TMC = $edge % 32;  #the 5 bit "data" in the edge (rest is status info)

	if(!exists($chandata->{rePpsCount}) or !exists($chandata->{rePpsTime})){	#if the rePpsCount or rePpsTime don't exist, we know this is a rising edge, and the start of a new event
        $count1++;
        $chandata->{rePpsTime} = $last_rePpsTime;
        $chandata->{rePpsCount} = $last_rePpsCount;
        $curr_sec_string = $row[10].$row[15];
        if($curr_sec_string ne $last_sec_string){
        $count11++;
            $chandata->{rePpsTime} = &currentPpsSeconds($row[10], $row[15]);
            $chandata->{rePpsCount} = hex($row[9]);
            $last_rePpsTime = $chandata->{rePpsTime};
            $last_rePpsCount = $chandata->{rePpsCount};
        }
        $last_sec_string = $curr_sec_string;

		#save these for computing the JD
		$chandata->{reTMC} = $TMC;
		$chandata->{reDiff} = (hex($row[0])-$chandata->{rePpsCount});
	}


	#GPS-ahead-of-board ERROR FIX:
	#Paul's Notes 5/17/04: this only happens on lines like this
	#97F9378A 80 01 00 01 3B 01 00 01 957EA4C1 014813.919 260703 V 05 2 -0075
	#97F9378B 00 01 00 01 01 2F 00 01 97FA6D1D 014813.919 260703 V 05 0 +0925
	# so we use the ppsTime and ppsCount on the previous line instead of the current line
#	if($difference > -hex('AAAAAAAA') and $difference < 0){ # a problem could occur if when we need to rely on the last ppsCount and ppsTime, and if that time happened far into the past, then we will be using the onboard time to get the difference, and the onboard clock drifts a little bit. Hopefully this wouldn't happen, and it if does, the clock doesn't drift too much.
#		$ppsCount= $lastPpsCount;
#		$ppsTime= $lastPpsTime;
#		$difference= (hex($triggerCount)-hex($ppsCount));	#recalculate difference with new values
#print "fix1 $. \n";
#	}
	
	#calculate the board's trigger count difference from the gps's count
	$difference = (hex($row[0])-$chandata->{rePpsCount});

	#rollover ERROR FIX:
	#Paul's Notes 5/17/04: this happens on lines like this
	#01B24491 80 01 00 01 34 01 00 01 FF4A8161 045103.263 260703 A 03 2 -0379
	#01B24492 00 01 00 01 01 2F 00 01 01C649BC 045103.263 260703 A 03 0 +0620
	# so we add FFFFFFFF which is what the board rolls over
	if($difference < -$CONST_hex8A){		#AAAAAAAA is arbitrary, but big enough to catch the rollover
		$difference = $difference+$CONST_hex8F;
	}


	#the absolute rising/falling edge time = UTC-of-RE_CPLDp + (CPLDe-CPLDp)/CPLDe_frequency + TMC/CPLDe_frequency*32
	$edgetime = $chandata->{rePpsTime} + ($difference)/$cpld_frequency + ($TMC)/$cpldResFreq;

	#if the second is over 86400, subtract 86400 from it
	$edgetime -= 86400 if($edgetime >= 86400);

	return $edgetime/86400;		#divide seconds by 86400 to get the fraction of a day
}

#currentPpsSeconds
# takes in a GPS time string of HHMMSS.mmm (mmm is mili-seconds) and rounds it to the nearest second of a Julian Day based on the 2nd argument offset
sub currentPpsSeconds {
	my $number = $_[0];
	my $offset = $_[1];

    #*performance* substr is over 1000% faster than splitting and concatenating
    my $hour = (substr($number, 0, 2) + 12)%24; #add 12 hours because JDs start at 12:00pm
    my $min = substr($number, 2, 2);
    my $sec = substr($number, 4, 6);

    my $sec_offset = sprintf("%.0f", $sec + ($offset/1000));   #round with GPS offset in word 16

	my $day_seconds = $hour*3600 + $min*60 + $sec_offset; #seconds since beginning of the current JD

	return $day_seconds;
}


sub print_data {
    $compute_jd = 1;
    $curr_gps_day = $row[11];
    $count2++;
    if($curr_gps_day eq $last_gps_day){
        $curr_edge_time = $chan[$ch_num]{retime};
        if($curr_edge_time >= $last_edge_time or $curr_edge_time < 0){
            $compute_jd = 0;
        }
    }
    #only compute the current jd if different from the last (*performance*)
    if($compute_jd==1){
		my $msec_offset = $row[15];
		my $offset = $chandata->{reDiff}/$cpld_frequency + $chandata->{reTMC}/$cpldResFreq + $msec_offset/1000;
	    $jd = &curr_line_jd($offset, @row);
        $last_gps_day = $curr_gps_day;
        $last_edge_time = $chan[$ch_num]{retime};
        $count22++;
    }

	my $nanodifference = ($chan[$ch_num]{fetime}-$chan[$ch_num]{retime})*1e9*86400;
	my $id= $serialNumber . "." . $ch_num;

    #print OUT1 "$. ";	#for debugging
    $nanodifference = sprintf "%.2f", $nanodifference;
    #Here is the error that FIT caught. I assumed pulses <100ns!
    if($nanodifference > 10000 or $nanodifference < 0){  #physically impossible to have a time over threshold > 100ns or < 0ns
        #print "Ignoring event on line: $. channel $ch_num with ToT: $nanodifference\n";
    }
    else{
        #see header comments for the reasons behind this printf statement:
        printf OUT1 ("%s\t%d\t%.16f\t%.16f\t%.2f\n", $id, $jd, $chan[$ch_num]{retime}, $chan[$ch_num]{fetime}, $nanodifference);
    }
}
