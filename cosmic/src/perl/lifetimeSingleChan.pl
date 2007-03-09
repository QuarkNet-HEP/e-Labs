#!/usr/bin/perl

#THIS SCRIPT ASSUMES THE DATA COMES IN IN ORDER OF RISING EDGES. (MOST OF THE DATA DOES THIS, THIS CAN ONLY OCCUR IF DATA HAD TO BE COMBINED.

# It searches for muon decays. If an event occurs and it is then followed by another signaal in a small period of time, suggested= 1e-5 seconds, then it can be considered a decay. The first signal comes from the muon coming to a stop in the scintillator, and if that happens the muon will decay which will give a smaller signal. We check for that smaller signal, and if it happens we can assume a muon has stopped and decayed. $checkEnergy variables is 1 if we want to make sure the second signal is smaller, O if we don't care. And $offset is the variable that holds how long we should keep the gate open in seconds. 

# for any questions e-mail peryshki@uiuc.edu
if($#ARGV < 3){    print "usage: lifetime.pl [filename to open] [filename to save to] [gatewidth in seconds] [0 or 1 for check energy]\n";
    exit 1;
}

#Set the command line arguments
$infile=$ARGV[0];
$ofile= $ARGV[1];
# Define the cutoff for the size of the gatewidth for any possible decay
# the offset will be given in seconds, and then transferred to portion of julian Day
$offset=$ARGV[2]/86400; 
$checkEnergy=$ARGV[3];	#the program checks the energy of the second signal, making sure it is smaller than the first signal
# here is a general description of what the program does


open(IN, "$infile");
open (OUT1, ">$ofile")  || die "Unable to open $ofile";
print OUT1 ("# channelNumb JulianDay PossibleDecayLength(MicroSeconds) StartDecay EndDecay FirstSignalTimeOverThreshold(nanoseconds) SecondSignalTimeoverThreshold(nanoseconds)\n");
#parse the file to look for decay events
while ($tempRead=<IN>)
{
	next if m/\s+^#/;
	last;
}
push(@array, $tempRead);
   
while(@array)
{
#for each possible event look ahead a predefined offset to determine if a decay had occured in that time period
	@tempRow=split(/\s+/,$array[0]);
	$curTime=$tempRow[2];
	$curChan=$tempRow[0];
	$curTimeOverThreshold=$tempRow[4];
	$curJulianDay=$tempRow[1];
	$i=1;
	while(defined($array[$i]) || &readLine(@array))
	{
	#if the buffer was traversed and no decays were found AND if nothing can be read into the buffer, then this event hasn't yielded a decay so we need to look at another event
		@tempRow=split(/\s+/,$array[$i]);
		$JulianDayDiff= $tempRow[1] -$curJulianDay;
		
		$timeDifference= ($JulianDayDiff + $tempRow[2])-$curTime;
		if( $timeDifference< $offset)
		{
			if($timeDifference>0 && $curChan==$tempRow[0]) 
			{
				# if a second signal happens within the set offset, and on the same channel, then it is a potentual decay
				if(!$checkEnergy || $tempRow[4]<$curTimeOverThreshold)
				{
				# if the user has enabled checking for energy signatures then make sure the timeOverThreshold of the second signal is less than the timeOverThreshold of the first. if user user has specified that this check isn't necessary, then just write the decay to a (file)
					$dif=$JulianDayDiff+$tempRow[2]-$curTime;
					$difInMicroSeconds=$dif*(86400*1e6);
					# The Difference is output in seconds, and the RE and FE is outputted as a partial day.
					printf OUT1 ("%s\t%s\t%.5lf\t%.16lf\t%.16lf\t%s\t%s\n", $curChan, $curJulianDay, $difInMicroSeconds, $curTime, $tempRow[2],$curTimeOverThreshold, $tempRow[4]);
					#	print OUT1 ( $curChan $curJulianDay $dif $curTime $tempRow[2]\n);
				}
			}
		}
		else
		{
		# if an event is checked in the buffer, and it is outside of the predefined offset, then we know it isn't a decay and not are any of the event that follow it (we assume the file is sorted in order by RisingEdges) 
			last;	
		}
		$i++;
	}
	shift(@array) #this event didn't yield a decay, shift it off the stack and check the next event
}

sub readLine 
{
# a function that loads events into our buffer
	@array=@_;

	@lastRowOfArray=split(/\s+/,$array[$#array]);
#if the last time in array minus first time is greater than the gatewidth we are looking for events in, then we don't need any more data 
	if($lastRowOfArray[2]-$curTime>$offset)
	{
		return 0;
	}
	
##commented out, because we should never have comment lines in the middle of our files	
#	while ($tempRead =~ /^#/)
#	{
#		$tempRead=<IN>;	
#	}
	if($tempRead=<IN>)
	{
		push(@array, $tempRead);
		return 1;
	}
	else
	{
		return 0;
	}
}
