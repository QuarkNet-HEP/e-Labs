#!/usr/bin/perl


#THIS SCRIPT ASSUMES THE DATA COMES IN IN ORDER OF RISING EDGES. (most of the data is in order, unless somebody uses another combine script that will not sort the result like our's does.

#This script searches for possible decays in a stack that can be supported by an n-fold coincidence.
#Here are the assumptions we make.
#	1) A muon signal has to occur consecutively in a stack to be considered a muon signal.
#	2) it is not necessary for a muon to start registering at the highest scintillator in the stack.
#	3) To search for a possible muon decay, first a user defined coincidence level has to be satisfied.
#	4) Theoretically the decay time over threshold could be shorter than the first signal, check if user wants.
# It searches for muon decays. If an event occurs and it is then followed by another signal in a small period of time, suggested= 1e-5 seconds, then it can be considered a decay. The first signal comes from the muon coming to a stop in the scintillator, and if that happens the muon will decay which will give a smaller signal. We check for that smaller signal, and if it happens we can assume a muon has stopped and decayed. $checkEnergy variables is 1 if we want to make sure the second signal is smaller, O if we don't care. And $offset is the variable that holds how long we should keep the gate open in seconds. 

$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
    warn "couldn't parse $commonsubs_loc $@" if $@;
    warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
    warn "couldn't run $commonsubs_loc"       unless $return;
    die;
}

if($#ARGV < 4){    
    die "usage: lifetime.pl [filename to open] [filename to save to] [gatewidth in seconds] [0 or 1 for check energy] [required coincidence Level 0 to n] [geometry directory]\n";
}

#Set the command line arguments
$infile=$ARGV[0];
open(IN, "$infile") || die "Cannot open $infile for input";
$ofile= $ARGV[1];
open (OUT1, ">$ofile")  || die "Unable to open $ofile for output";
# Define the cutoff for the size of the gatewidth for any possible decay
# the offset will be given in seconds, and then transferred to portion of julian Day
die "Error: Lifetime gatewidth ($ARGV[2]) must be positive\n" if($ARGV[2]<=0);
warn "Error: Lifetime gatewidth ($ARGV[2]) being more than 1 second will yield lots of noise\n" if($ARGV[2]>1);
$offset=$ARGV[2]/86400; 
die "Error: CheckEnergy ($ARGV[3]) value needs to be zero or one\n" if($ARGV[3]!=0 && $ARGV[3]!=1);
$checkEnergy=$ARGV[3];	#the program checks the energy of the second signal, making sure it is smaller than the first signal
die "Error: coincidence level has to be bigger or equal to zero\n" if($ARGV[4]<0);
$minimumCoincidenceLevel=$ARGV[4];

#For each detector read the geo file. and load it into a 2-d array of (julian-day, stack)

if($ARGV[5]){
    $geo_dir=$ARGV[5];
} else { die "Error: Geometry file directory not specified\n"; }

#Declaring useful information
$max=2**31;
$speedOfMuon=299792458; #(Meters/second) speed of light in vacum
$percentTimeErrorAllowed=.01;
$numSecondsInDay=86400;
$constantTimeErrorAllowed=1e-9/$numSecondsInDay;
$currentBufferPosition=-1;
$totalStackTime=0;
$foundDecays="false";
$first_fileRead=1;

#variables for stack reading
$previousDetector=0;
$positionInHash=0;

print OUT1 ("# channelNumb JulianDay PossibleDecayLength(MicroSeconds) StartDecay EndDecay FirstSignalTimeOverThreshold(nanoseconds) SecondSignalTimeoverThreshold(nanoseconds) PossibleDecayNumber\n");

#Ignore lines with comments when beginning to read the file
while (<IN>)
{
	next if m/^\s*#/;
	last;
}
push(@array, $_);

#getting detector number
@splitting=split(/\s+/,$array[0]);
chop($splitting[0]);
chop($splitting[0]);
push(@detectorsToCheck, $splitting[0]);
$detector_Number_Checking=0;

#this function keeps the whole thing going.
&StartReadingFile();

sub CheckThatReadingFromCorrectDetector {
#the script will run through the file multiple times, depending on the number of detectors selected. But on each run it will ignore all detectors other than the one it is looking at. This function makes sure ignores other detectors.
    @splitting=split(/\s+/,$array[$currentBufferPosition]);
    chop($splitting[0]);
    chop($splitting[0]);
    while($splitting[0] != $detectorsToCheck[$detector_Number_Checking]) {
        &CleanBuffer();
        if($#array<1){
            &AddToBuffer();
        }
        @splitting=split(/\s+/,$array[$currentBufferPosition]);
        chop($splitting[0]);
        chop($splitting[0]);        
    }
}

sub AddToDetectorArray {
#If this is the first time the file is read, then this function searches for new detector ids, whos geometry information will then be loaded into memory, and checked for muon decays.
    if($first_fileRead) {
        #getting detector number
        @splitting=split(/\s+/,$array[$#array]);
        chop($splitting[0]);
        chop($splitting[0]);
        if(!&Data_FoundIn_Array($splitting[0],@detectorsToCheck)) {
            push(@detectorsToCheck, $splitting[0]);
        }
    }
}

sub FindSpecificDecay	
{
#This function will look ahead a time offset, to see if a second signal had falled in the same channel, This function is only run after the stack requirements are satisfied.
	$decayToCheck=$_[0];
	@possibleStartDecayData=split(/\s+/,$array[$decayToCheck]);
	$curTime=$possibleStartDecayData[2];
	$curChan=$possibleStartDecayData[0];
	$curTimeOverThreshold=$possibleStartDecayData[4];
	$curJulianDay=$possibleStartDecayData[1];
	$i=1;
	$PossibleDecayNumber=0;
	while(defined($array[$i]) )
	{
		@possibleEndDecayData=split(/\s+/,$array[$i]);
		$JulianDayDiff= $possibleEndDecayData[1] -$curJulianDay;
		
		$timeDifference= ($JulianDayDiff + $possibleEndDecayData[2])-$curTime;
		if($curChan==$possibleEndDecayData[0]) 
		{
		 #TJ change the next line. We were getting to many prompt events that look like muons just passing through. This value in pjd is close to a few hundred ns--a nice cut for a reasonable lower limit.
			if( 3.4e-12 < $timeDifference && $timeDifference  < $offset )
			{
				# if a second signal happens within the set offset, and on the same channel, then it is a potentual decay
				if(!$checkEnergy || $possibleEndDecayData[4]<$curTimeOverThreshold)
				{
				# if the user has enabled checking for energy signatures then make sure the timeOverThreshold of the second signal is less than the timeOverThreshold of the first. if user user has specified that this check isn't necessary, then just write the decay to a (file)
					$dif=$JulianDayDiff + $possibleEndDecayData[2]-$curTime;
					$difInMicroSeconds=$dif*($numSecondsInDay*1e6);
					$PossibleDecayNumber++;
					# The Difference is output in seconds, and the RE and FE is outputted as a partial day.
					printf OUT1 ("%s\t%s\t%.5f\t%.16f\t%.16f\t%s\t%s\t%s\n", $curChan, $curJulianDay, $difInMicroSeconds, $curTime, $possibleEndDecayData[2],$curTimeOverThreshold, $possibleEndDecayData[4], $PossibleDecayNumber);
                    $foundDecays="true";
                    #last is used to stop the search for decay events once the first one is found.
                    last;
				}
			}
		}
		$i++;
	}
}

sub FindPossibleStartDecayWithCoincidenceCheck
{
#Goes through the buffer to find a channel where the muon could have possibly stopped.
#The way the stack is satisfied is if an x-amount of signals occur in very short increments going down through the stack. Where the stream of signals have stopped, could be a possible start to a decay.
	if($#array>=1)
	{
        #read Current Stack Information
        &CheckThatReadingFromCorrectDetector();
    	@currentRow=split(/\s+/,$array[$currentBufferPosition]);
        &updateStackTime($currentRow[1],$detectorsToCheck[$detector_Number_Checking]);
        if($noStack)
        {
            #if no stack for this detector exists, then try to find decay event for this signal
    	    &FindSpecificDecay($currentBufferPosition);
        }
        else
        {
	        $stackPointer=0;
		    #find the position in the stack of the signal
		    while($currentRow[0] !=$stackId[$stackPointer] )
		    {
			    $stackPointer++;
			    if($stackPointer>$#stackId)  # the id doesn't appear in the user defined stack
			    {
                    if($minimumCoincidenceLevel<=0) {
                        #if coincidence required is less than 1, then try to find a matching decay signal even thought the signal is not from an event in the stack.
                        &FindSpecificDecay($currentBufferPosition);
                        return;
                    } else {
                        #don't consider this line as a decay next function call is CleanBuffer, which will start looking at the next line.
				        return;
                    }
			    }
		    }
		    #Check for coincidences
		    $coincidenceObtained=1;
            #Next line should be"$stackPointer<$#stackId" because we don't want o check coincidence check for anything at the bottom of a stack
            $lookingAheadConstant=0; #the lookingahead constant facilitates looking ahead in the buffer and ignoring events that might happen at the same time as the muon travels down the stack.
		    while($stackPointer<$#stackId)
		    {
			    @oneRow=split(/\s+/,$array[$currentBufferPosition+$coincidenceObtained-1+$lookingAheadConstant]);
                if($currentBufferPosition+$coincidenceObtained+$lookingAheadConstant> $#array) {
                    #you have reached end of file
                    return;
                }
			    @twoRow=split(/\s+/,$array[$currentBufferPosition+$coincidenceObtained+$lookingAheadConstant]);
                #call the check stack function a second time, to make sure we are still in the same stack
                &updateStackTime($twoRow[1],$detectorsToCheck[$detector_Number_Checking]);
			    $JulianDayDifference= $oneRow[1] -$twoRow[1];
			    $PossibleDecayLength=$JulianDayDifference+$twoRow[2]-$oneRow[2];
			    if( $PossibleDecayLength < &AddPositiveErrorAmount($stackTime[$stackPointer]) &&
			    	$PossibleDecayLength > &AddNegativeErrorAmount($stackTime[$stackPointer]) &&
				    $twoRow[0] == $stackId[$stackPointer+1] ) {
    				$coincidenceObtained++;
	    			$stackPointer++;
		    	} elsif ( $PossibleDecayLength < &AddPositiveErrorAmount($stackTime[$stackPointer]) &&
			    	$PossibleDecayLength > &AddNegativeErrorAmount($stackTime[$stackPointer])) {
                    $lookingAheadConstant++;
                } else {
				    last;
			    }
		    }
	    	$currentBufferPosition=$currentBufferPosition+$coincidenceObtained-1;
		    #if proper amount of coincidences was found, check that counter for a decay.
		    if($coincidenceObtained>=$minimumCoincidenceLevel && $#array>0)
		    {
			    #check for decay at possible location
			    &FindSpecificDecay($currentBufferPosition);
	    	}
	    }
    }
}

sub CleanBuffer
{ #Clean Buffer AUTOMATICALLY erases entries before and currently what currentBufferPosition points to
	while($currentBufferPosition>=0)
	{
		shift(@array);
		$currentBufferPosition--;
	}
	$currentBufferPosition=0;
}

sub AddToBuffer
{
# a function that loads events into our buffer so we can search for decays
#print "adding to Buffer";
#add to Buffer at least two data lines, if that is not possible exit program
while($#array<1 || $currentBufferPosition >= $#array)
{
	if($tempRead=<IN>)
	{
		push(@array,$tempRead);
        &AddToDetectorArray();
	} else {
    #if buffer can't be read, that means we are at the end of file, we either quit or check for other stacks depending on function.
        if($#detectorsToCheck>$detector_Number_Checking) {
            #there are other detector stacks to check for.
            close(IN);
            $first_fileRead=0;
            open(IN, "$infile") || die "Cannot open $infile for input";
            while (<IN>){
                next if m/^\s*#/;
                last;
            }
            push(@array, $_);
            $detector_Number_Checking++;
            &StartReadingFile();
        } else { # we have checked all the stacks, now analysis is done
            if($foundDecays eq "false"){
                die "Error: No possible decays were found in these files\n";
            }
		    exit;
        }
	}
}
	@firstRowOfArray=split(/\s+/,$array[$currentBufferPosition]);
	@lastRowOfArray=split(/\s+/,$array[$#array]);
	$JulianDayDifference= $lastRowOfArray[1] -$firstRowOfArray[1];	
	while(($lastRowOfArray[2]+$JulianDayDifference) < ($firstRowOfArray[2]+$offset+&AddPositiveErrorAmount($totalStackTime))) {
##Probably could be commented out, because we should not have comment lines in the middle of our files	
#    	while ($tempRead =~ /^#/){
#		    $tempRead=<IN>;	
#	    }
		if($tempRead=<IN>){
			push(@array,$tempRead);
            &AddToDetectorArray();
		} else {
			last;
		}
		@lastRowOfArray=split(/\s+/,$array[$#array]);
		$JulianDayDifference= $lastRowOfArray[1] -$firstRowOfArray[1];	
	}
}

sub AddPositiveErrorAmount
{
	$timeToAdd=$_[0];
	return ($timeToAdd+ $timeToAdd*$percentTimeErrorAllowed+$constantTimeErrorAllowed);
}
sub AddNegativeErrorAmount
{
	$timeToAdd=$_[0];
	return ($timeToAdd- $timeToAdd*$percentTimeErrorAllowed-$constantTimeErrorAllowed);
}

#this function is always called, it figured out if the stack needs updating
sub updateStackTime
{
#using current jd, find set proper range, stack, time, totalTime.
    my $currentJd = $_[0];
    my $detectorIdLookingAt = $_[1];
    my $need_To_Update=0;
    #if a new detector is being looked at, we need to go through the hash again
    if( $previousDetector != $detectorIdLookingAt) {
        @detectorGeoHash= &all_geo_info($detectorIdLookingAt, $geo_dir);
        if(0==$#detectorGeoHash) { #only one entry is contained in hash
            @jdRange=($detectorGeoHash[0]->{jd},$max);  
        } else {
            @jdRange=($detectorGeoHash[0]->{jd},$detectorGeoHash[1]->{jd});
        }   
        if($detectorGeoHash[0]->{jd} > $currentJd) {
            die "there isn't any geometry data for detector #$detectorIdLookingAt on Julidan Day:$currentJd\n";
        }
        $positionInHash=0;
        $previousDetector = $detectorIdLookingAt;
        $need_To_Update=1;
    }
    #Here we are progressing through the geometry file, finding a place where the range engulfs our data. We make an assumption that the configuration of detectors is left untouched from the last entry to the geo file, untill the present.         
    if (!($jdRange[0]<=$currentJd && $jdRange[1]>$currentJd) || $need_To_Update ) {
    #clear the stacks, because they are going to be updated
        @stackId=(); 
        @stackTime=();
        @stackDistance=();
        $totalStackTime=0;       
        while($positionInHash <= $#detectorGeoHash && (!($jdRange[0]<=$currentJd && $jdRange[1]>$currentJd))) {
            $positionInHash++;
            if($positionInHash == $#detectorGeoHash) { # if we are the the last entry of geo file, then that geometry should last untill now. meaning upper bound of range should be at its maximum.
                @jdRange=($detectorGeoHash[$positionInHash]->{jd},$max);
            } else {
                @jdRange=($detectorGeoHash[$positionInHash]->{jd},$detectorGeoHash[$positionInHash+1]->{jd});
            }
        }
        #positionInHash now holds a valid position
    #Now we gather the stack information and timing information from the entry in geo, and load it in to the stack array and time array                         
        if($detectorGeoHash[$positionInHash]->{stacked} == 0) {
            $noStack=1;
            @stackId=(); 
            @stackTime=();
            @stackDistance=();
            $totalStackTime=0;
        } else { #Assume user has entered a stack, and calculate it, where top of the stack is defined by altitude.
        #find Max altitude to be the top detector
            my @max_altitude=(-$max,0); #this is a double, with max altitude and the channel that corresponds to it.
            my @chan_stack=();
            my $chan_counter=1;
            my $loop_counter=1;
            while($loop_counter<=4) {
                while($chan_counter<=4) {
#                    $max_altitude[1]=0;
                    if($detectorGeoHash[$positionInHash]->{"chan".$chan_counter}{z} ne '*' && $detectorGeoHash[$positionInHash]->{"chan".$chan_counter}{z} >= $max_altitude[0] && !&Data_FoundIn_Array($chan_counter,@chan_stack)) {
                    @max_altitude=($detectorGeoHash[$positionInHash]->{"chan".$chan_counter}{z},$chan_counter);
                    }
                    $chan_counter++;
                }
                if($max_altitude[1] != 0){
                    push(@chan_stack,$max_altitude[1]);
                }
                @max_altitude=(-$max,0);
                $loop_counter++;
                $chan_counter=1;
            }
        #now the stack is in order, and all that is needed is to load that stack into stackarray and calculate times.
            if($#chan_stack<0){
                $noStack=1;
                @stackId=(); 
                @stackDistance=();
                @stackTime=();
                $totalStackTime=0;          
            } elsif($#chan_stack>=0) {
                push(@stackId, "$detectorIdLookingAt.$chan_stack[0]");
                my $chan_stack_traverser = 1;
                while($chan_stack_traverser<=$#chan_stack) {
                    push(@stackId, "$detectorIdLookingAt.$chan_stack[$chan_stack_traverser]");
                    push(@stackDistance,sqrt( ($detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser-1]}{'x'}-$detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser]}{'x'})**2+ ($detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser-1]}{'y'}-$detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser]}{'y'})**2+ ($detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser-1]}{'z'}-$detectorGeoHash[$positionInHash]->{"chan".$chan_stack[$chan_stack_traverser]}{'z'})**2));
                    $chan_stack_traverser++;
                }
            #then fill in the time stack
                $totalStackTime=0;
                my $a=0;
                while($a<=($#stackDistance)){
                    push(@stackTime,($stackDistance[$a]/$speedOfMuon)/$numSecondsInDay);
                    $totalStackTime+=($stackDistance[$a]/$speedOfMuon)/$numSecondsInDay;
                    $a++;
                }        
            }
        #don't forget to reset coincidence level after update occurs
        $coincidenceObtained=1;
        }
    }
}

sub Data_FoundIn_Array {
    (my $data, my @array)=@_;
    my $count=0;
    while($count<=$#array) {
        if($array[$count] == $data) {
            return 1;
        }
        $count++;
    }
    return 0;
}

sub StartReadingFile {
    while(@array)
    {
    	&CleanBuffer();
    	&AddToBuffer();
    	&FindPossibleStartDecayWithCoincidenceCheck();
    }
}
