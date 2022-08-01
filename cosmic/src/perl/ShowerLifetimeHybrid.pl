#!/usr/bin/perl

# EPeronja - 2022-07-08
# This program looks for hits and pulsewidths within buffers
# 1-Read the input file ordered by rising edge
# 2-Create a buffer based on a time window provided by the gatewidth
# 3-Look for hits per counter and their pulsewidths
# 4-Write to output file

if($#ARGV < 4){    
    die "usage: LifetimeShowerHybrid.pl [filename to open] [filename to save to] [file to save feedback]".
     "[gatewidth in seconds] [channel coincidence]"
}

#/Users/eperonja/ep_home/ep_fermi/6674/sortOutShort /Users/eperonja/ep_home/ep_fermi/6674/hybridOut /Users/eperonja/ep_home/ep_fermi/6674/hybrid_fb 1e-4 2 250 0 4 2 100 0 0 300 6674

# Retrieve command line arguments
$infile=$ARGV[0];
open(IN, "$infile") || die "Cannot open $infile for input";
$ofile= $ARGV[1];
$feedback = $ARGV[2];
open(OUT, ">$ofile")  || die "Unable to open $ofile for output";
open(LIFEOUT,">$feedback") || die "Unable to open $ofile_feedback for feedback";
$gatewidth=$ARGV[3];
$coincidence=$ARGV[4];

# Constants
$numSecondsInADay=86400;
$constantTimeErrorAllowed=1e-9/$numSecondsInADay;
$offset=$gatewidth/$numSecondsInADay; 
$debugger = 1;

print OUT ("\t\t\t\t\tFirst Hit\t\t\t\t\t\t\t\t\t",
          "First hits in each channel\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t",
           "Second hits from each channel\n");
print OUT ("Event\tNmHitDAQ1\tMinFracDay\t\t\tJulDay\t\tSSDB\t\teventDateTime\t\t",
                        "Hit1.ch1\tPW1\t\t",
                        "Hit1.ch2\tPW2\t\t",
                        "Hit1.ch3\tPW3\t\t",
                        "Hit1.ch4\tPW4\t\t",
                        "Hit2.ch1\tPW1\t\t",
                        "Hit2.ch2\tPW2\t\t",
                        "Hit2.ch3\tPW3\t\t",
                        "Hit2.ch4\tPW4\t\t",
                        "\n");


print LIFEOUT "LifetimeShowerHybrid analysis - User parameters:\n";
print LIFEOUT "Gatewidth: $gatewidth secs\n";
print LIFEOUT "Channel coincidence: $coincidence\n";
print LIFEOUT "Offset: $offset\n";
# Read lines into a big buffer and ignore lines with comments when beginning to read the file
while (<IN>) {
	next if m/^\s*#/;
	push(@remainingbuffer, $_);
}# End of reading the file into a large buffer

# main routine
$buffercounter = 1; #remove later
$buffersize = @remainingbuffer;
@buffersummary = ();
while($buffersize > 0) {
	@buffersummary = ();
	if ($debugger == 1) {
		push(@buffersummary, "\n\nBuffer: $buffercounter\n");
	}
	@buffer = createBuffer();
	#let's record N/counter
	if (@buffer > 1) {
		analyzeBufferForHitsCounter(@buffer,$buffercounter);
	}
	$buffersummarysize = @buffersummary;
	
	for my $i (0..$buffersummarysize-1) {
		print LIFEOUT "$buffersummary[$i]";
	}	
	$buffersize = @remainingbuffer;
	if ($buffersize <= 0) {
		last;
	}
	$buffercounter += 1;
}# end of main routine

close(IN);
close(OUT);
close(LIFEOUT);

sub createBuffer() {
	$ndx = 0;
	$size = @remainingbuffer;
	@currentbuffer = ();
	if ($size > 0) {
		$firstrow = shift(@remainingbuffer);
		@firstrowparts = split(/\s+/,$firstrow);
		$nextrownew = $remainingbuffer[$ndx];
		@nextrownewparts = split(/\s+/,$nextrownew);
		$juliandaydiff = $nextrownewparts[1] - $firstrowparts[1];
		$nextrejuliandaydiff = $nextrownewparts[2] + $juliandaydiff;
		$firstrowreoffset = $firstrowparts[2] + $offset + $constantTimeErrorAllowed;
		if ($nextrejuliandaydiff < $firstrowreoffset) {
			$nextrow = shift(@remainingbuffer);
		} else {
			$nextrow = "";
		}
		push(@currentbuffer, $firstrow);
		$size = @remainingbuffer;
		$sizenextrow = @nextrownewparts;
		while ($nextrejuliandaydiff < $firstrowreoffset && $size > 0 && $sizenextrow > 0) {
			push(@currentbuffer, $nextrow);
			$nextrownew = $remainingbuffer[$ndx];
			@nextrownewparts = split(/\s+/,$nextrownew);
			$juliandaydiff = $nextrownewparts[1] - $firstrowparts[1];
			$nextrejuliandaydiff = $nextrownewparts[2] + $juliandaydiff;
			$firstrowreoffset = $firstrowparts[2] + $offset + $constantTimeErrorAllowed;
			if ($nextrejuliandaydiff < $firstrowreoffset) {
				$nextrow = shift(@remainingbuffer);
			} else {
				$nextrow = "";
			}
			# if we popped the last one, we need to tag it along with the last buffer
			$size = @remainingbuffer;
			if ($size == 0) {
				push(@currentbuffer, $nextrow);
			}
		}
	}
	if ($debugger == 1) {		
		push(@buffersummary,"\nBegin buffer:\n");
		while( my ($i,$line) = each @currentbuffer) {
			push(@buffersummary, $line);
		}
		push(@buffersummary,"End buffer\n");
	}
	return @currentbuffer;
}# end of creating individual buffers based on the gatewidth parameter

sub analyzeBufferForHitsCounter() {
	my @localbuffer = @_;
	$buffersize = @localbuffer;
	$counter1 = $counter2 = $counter3 = $counter4 = 0;
	$julianday="";
	$minfracdaybuffer=0.0;
	$toNs = 3600*24*1e9;
	$eventDateTime="";
	$ssdb=0.0;
	$hit1ch1=$hit1ch2=$hit1ch3=$hit1ch4=sprintf('%.2f',-1.00);
	$hit1pdw1=$hit1pdw2=$hit1pdw3=$hit1pdw4=sprintf('%.2f',-1.00);
	$hit2ch1=$hit2ch2=$hit2ch3=$hit2ch4=sprintf('%.2f',-1.00);
	$hit2pdw1=$hit2pdw2=$hit2pdw3=$hit2pdw4=sprintf('%.2f',-1.00);
	$chan1hit=$chan2hit=$chan3hit=$chan4hit=0;
	for my $i (0..($buffersize-1)) {
		@hitparts = split(/\s+/, $localbuffer[$i]);
		@counterparts = split(/\./, $hitparts[0]);
		#grab data from the first hit in the buffer
		if ($julianday==""){
			$julianday = $hitparts[1];
		}
		if ($minfracdaybuffer == 0.0) {
			$minfracdaybuffer = $hitparts[2];
		}
		if ($ssdb==0.0) {
			$temp = 3600*24*$minfracdaybuffer;
			$ssdb = sprintf('%.2f',$temp);
		}
		if ($eventDateTime=="") {
			@tempdate = jd_to_gregorian($hitparts[1],$hitparts[2]);
			$eventDateTime = "$tempdate[1]/$tempdate[0]/$tempdate[2] $tempdate[3]:$tempdate[4]:$tempdate[5]";
		}
		if ($counterparts[1] == "1") {
			$counter1 += 1;
			$chan1hit=1;
			if ($counter1 == 1) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit1ch1 = sprintf('%.2f',$temp);
				$hit1pdw1 = $hitparts[4];
			}
			if ($counter1 == 2) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit2ch1 = sprintf('%.2f',$temp);
				$hit2pdw1 = $hitparts[4];
			}
		}		
		if ($counterparts[1] == "2") {
			$chan2hit=1;
			$counter2 += 1;
			if ($counter2 == 1) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit1ch2 = sprintf('%.2f',$temp);
				$hit1pdw2 = $hitparts[4];
			}
			if ($counter2 == 2) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit2ch2 = sprintf('%.2f',$temp);
				$hit2pdw2 = $hitparts[4];
			}
		}
		if ($counterparts[1] == "3") {
			$chan3hit=1;
			$counter3 += 1;
			if ($counter3 == 1) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit1ch3 = sprintf('%.2f',$temp);
				$hit1pdw3 = $hitparts[4];
			}
			if ($counter3 == 2) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit2ch3 = sprintf('%.2f',$temp);
				$hit2pdw3 = $hitparts[4];
			}
		}
		if ($counterparts[1] == "4") {
			$chan4hit=1;
			$counter4 += 1;
			if ($counter4 == 1) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit1ch4 = sprintf('%.2f',$temp);
				$hit1pdw4 = $hitparts[4];
			}
			if ($counter4 == 2) {
				$temp = $toNs*($hitparts[2] - $minfracdaybuffer);
				$hit2ch4 = sprintf('%.2f',$temp);
				$hit2pdw4 = $hitparts[4];
			}
		}
	}
	#print totals
	$totalhits = $counter1+$counter2+$counter3+$counter4;
	$chancoincidence = $chan1hit+$chan2hit+$chan3hit+$chan4hit;
	if ($chancoincidence >= $coincidence) {
    	push(@buffersummary,"\t\t\t\t\tFirst Hit\t\t\t\t\t\t\t\t\t",
       	                 "First hits in each channel\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t",
                         "Second hits from each channel\n");
    	push(@buffersummary,"Event\tNmHitDAQ1\tMinFracDay\t\t\tJulDay\t\tSSDB\t\teventDateTime\t\t",
        	                "Hit1.ch1\tPW1\t\t",
            	            "Hit1.ch2\tPW2\t\t",
                	        "Hit1.ch3\tPW3\t\t",
                    	    "Hit1.ch4\tPW4\t\t",
                        	"Hit2.ch1\tPW1\t\t",
	                        "Hit2.ch2\tPW2\t\t",
    	                    "Hit2.ch3\tPW3\t\t",
        	                "Hit2.ch4\tPW4\t\t",
            	            "\n");
	    push(@buffersummary,"$buffercounter\t\t$totalhits\t\t\t$minfracdaybuffer\t$julianday\t\t$ssdb\t$eventDateTime\t",
	                        "$hit1ch1\t\t$hit1pdw1\t",
	                        "$hit1ch2\t\t$hit1pdw2\t",
	                        "$hit1ch3\t\t$hit1pdw3\t",
	                        "$hit1ch4\t\t$hit1pdw4\t",
	                        "$hit2ch1\t\t$hit2pdw1\t",
	                        "$hit2ch2\t\t$hit2pdw2\t",
	                        "$hit2ch3\t\t$hit2pdw3\t",
	                        "$hit2ch4\t\t$hit2pdw4\t",
	                        "\n");
	    print OUT ("$buffercounter\t\t$totalhits\t\t\t$minfracdaybuffer\t$julianday\t\t$ssdb\t$eventDateTime\t",
	                        "$hit1ch1\t\t$hit1pdw1\t",
	                        "$hit1ch2\t\t$hit1pdw2\t",
	                        "$hit1ch3\t\t$hit1pdw3\t",
	                        "$hit1ch4\t\t$hit1pdw4\t",
	                        "$hit2ch1\t\t$hit2pdw1\t",
	                        "$hit2ch2\t\t$hit2pdw2\t",
	                        "$hit2ch3\t\t$hit2pdw3\t",
	                        "$hit2ch4\t\t$hit2pdw4\t",
	                        "\n");	}
}# end of analyze buffer for N Hits per Counter


sub jd_to_gregorian{
	# arguments: an integer julian day, optionally the partial julian day. Example: jd_to_gregorian(2453283, .098888)
	# returns: (day[1..31], month[1..12], year[..2004..]) array
    # returns: a (day, month, year, hour, min, sec, millisec, microsec, nanosec) array if the partial julian day is passed
    $Z = $_[0] + 0.5;
    if($_[1]){
        $Z += $_[1];
    }
	$Z = int($Z);
	$W = int(($Z - 1867216.25)/36524.25);
 	$X = int($W/4);
	$A = $Z+1+$W-$X;
	$B = $A+1524;
	$C = int(($B-122.1)/365.25);
	$D = int(365.25*$C);
	$E = int(($B-$D)/30.6001);
 	$F = int(30.6001*$E);
	$day = $B-$D-$F;
	$month = $E-1 <= 12 ? $E-1 : $E-13;	#Month = E-1 or E-13 (must get number less than or equal to 12)
	$year = $month <= 2 ? $C-4715 : $C-4716;	#Year = C-4715 (if Month is January or February) or C-4716 (otherwise)

	if($_[1]){
		$hour = int($_[1]*24);
		$min = int(($_[1]*24-$hour)*60);
		$sec = int((($_[1]*24-$hour)*60-$min)*60);
		$msec = int(((($_[1]*24-$hour)*60-$min)*60-$sec)*1000);
		$micsec = int((((($_[1]*24-$hour)*60-$min)*60-$sec)*1000-$msec)*1000);
		$nsec = int(((((($_[1]*24-$hour)*60-$min)*60-$sec)*1000-$msec)*1000)*1000);

		return ($day, $month, $year, ($hour+12)%24, $min, $sec, $msec, $micsec, $nsec);
	}

	return ($day, $month, $year);
}
