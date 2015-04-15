#!/usr/bin/perl
#WireDelay.pl
#input [thresholdTimes files] [output files] [geometryDirectory]
#Data offset by cable length amount
#ndettman, FNAL 6/14/07 changed to use gps cable length as well as signal cable length.
#tjordan, FNAL 29/02/12 added offset correction due to firmware > 1.11

#Set the command line arguments
@infile = split (/\s+/, $ARGV[0]);
@ofile = split (/\s+/, $ARGV[1]);
if($ARGV[2]){
    $geo_dir=$ARGV[2];
} else { die "Error: Geometry file directory not specified\n"; }
@DAQID = split (/\s+/, $ARGV[3]);
@firmware = split (/\s+/, $ARGV[4]);
$firmwareOffset = 1/86400; # New firmware is off by exactly one second. This needs to be turned into a fraction of a day.

$#firmware = $#DAQID = $#infile if $#ARGV = 3; #so that the "number of inputs" check works if firmware is absent.

die "This requires 3 OR 5 inputs:", "\n", "3 inputs: [\"input-file1 input-file2 ...\"] [\"output-file1 output-file2 ... \"] [\"geometry file directory\"]", "\n", "5 inputs: [\"input-file1 input-file2 ...\"] [\"output-file1 output-file2 ... \"] [\"geometry file directory\"] [\"DAQID-file1 DAQID-file2 . . \"] [\"firmware-file1 firmware-file2 . . \"]", "\n", "You have ".($#ARGV)." arguments and they are \"@ARGV\"\n" if($#ARGV < 3 || $#ARGV == 4 || $#ARGV > 5); #we aren't getting the correct number of inputs;

die "The number of inputs, outputs and DAQIDs and firmware versions must match!\n" if($#infile != $#ofile || $#infile != $#firmware || $#infile != $#DAQID);

#open up the CommonSubs.pl
$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
    warn "couldn't parse $commonsubs_loc $@" if $@;
    warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
    warn "couldn't run $commonsubs_loc"       unless $return;
    die;
}
$max=2**31;

#While loop to go through all input files
while($infile=shift(@infile)){
    $ofile=shift (@ofile);
    $firmware=shift(@firmware);
    $DAQID=shift(@DAQID);
    $lastId="";

    #Open input and output files
    open(IN, "$infile")  || die "Cannot open $infile for input";
    open (OUT1, ">$ofile")  || die "Cannot open $ofile for output";
    
    #print the header
    print OUT1 ("#USING WIREDELAYS: ID.CHANNEL, Julian Day, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec)\n");

    #data analysis
    while(<IN>){
        next if /^\s*#/;
        @inputRow= split (/\s+/, $_);
        ($id, $chan) = split /\./, $inputRow[0];
		printf OUT2 ("INPUT: $_\n");
 
        #get geometry info
        @detectorGeoHash= &all_geo_info($id, $geo_dir) if($lastId !=$id);
        #Wire length delay will be subtracted from "retime" and "fetime" before we output to file
        ##We use the same wireDelay for both rising edge and falling edge, because a user can't reset his geometry between the rising and falling edge pair.
        $cableLenDelay=&wireDelay($inputRow[1]+$inputRow[2],$id,$chan);
        #prepare output, resetting jd if necessary
        #caution sometimes rounding errors can occur by 1*10^(-16)
        
        #This block does the offset due to cable lengths recorded in the geo file.
        $reNewTime=$cableLenDelay+$inputRow[2];
        $feNewTime=$cableLenDelay+$inputRow[3];
        $outputJd=$inputRow[1];
        
        #This block does the correction for errors introduced by firmware
        #EPeronja: Added the cable length delay calculation to this check
        if($firmware > 1.11 && $DAQID > 5999){
        	$reNewTime=$firmwareOffset + $cableLenDelay + $inputRow[2];
        	$feNewTime=$firmwareOffset + $cableLenDelay + $inputRow[3];
        }
        
        if($reNewTime>=1.0){
            $outputJd=$inputRow[1]+int($reNewTime);
            $reNewTime-=int($reNewTime);
            $feNewTime-=int($feNewTime);
        }
 
        printf OUT1 ("%s\t%d\t%.16f\t%.16f\t%.2f\n",$inputRow[0],$outputJd,$reNewTime,$feNewTime,$inputRow[4]);
        $lastId=$id;
    }
}

sub wireDelay{
    my $currentJd=$_[0];
    my $detectorIdLookingAt=$_[1];
    my $channelNum=$_[2];
    if(defined($jdRange[0]) && $jdRange[0]<$currentJd && $jdRange[1]>$currentJd){
        #we can just return delayFromCable because, we reload the hash each time the detector id changes
        #return $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'}/86400;
        #return $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'}/86400e11;
        $delay = $detectorGeoHash[$positionInHash]{'gpsCabLen'} - $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'};
        return $delay/86400e11;
    } elsif($#detectorGeoHash==-1){
        die "there is no data in the geometry file\n";
    } else { #find proper cable-delay for specific julian-day time period
        if(0==$#detectorGeoHash) { #only one entry is contained in hash
            @jdRange=($detectorGeoHash[0]{'jd'},$max);
        } else {
            @jdRange=($detectorGeoHash[0]{'jd'},$detectorGeoHash[1]{'jd'});
        }
        if($detectorGeoHash[0]->{jd} > $currentJd) {
            # changes the output to the user from a julian day to an actual date that the user can understand
            @currentActualDay = &jd_to_gregorian(int($currentJd));
            $currDay = @currentActualDay[0];
            $currMonth = @currentActualDay[1];
            $currYear = @currentActualDay[2];
            die "there isn't any geometry data for detector #$detectorIdLookingAt on date:$currMonth/$currDay/$currYear\n";
        }
        $positionInHash=0;
        while($positionInHash<= $#detectorGeoHash && (!($jdRange[0]<=$currentJd && $jdRange[1]>$currentJd))){
              $positionInHash++;
              if($positionInHash == $#detectorGeoHash) { # if we are the the last entry of geo file, then that geometry should last untill now. meaning upper bound of range should be at its maximum.
                  @jdRange=($detectorGeoHash[$positionInHash]{'jd'},$max);
              } else {
                  @jdRange=($detectorGeoHash[$positionInHash]{'jd'},$detectorGeoHash[$positionInHash+1]{'jd'});
              }
          }
          #return $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'}/86400;
          #return $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'}/86400e11;
          $delay = $detectorGeoHash[$positionInHash]{'gpsCabLen'} - $detectorGeoHash[$positionInHash]{"chan".$channelNum}{'cabLen'};
          return $delay/86400e11;
      }
  }
