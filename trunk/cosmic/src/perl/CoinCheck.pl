#!/usr/bin/perl

#CoinCheck.pl eliminates noise in ThreshTimes.pl by only keeping data within a coincidence gate width for vertically stacked counters in a specific order

#Note: Doesn't matter if hardware is already programmed to look for coincidences, or if no coincidence check is 
#implemented in hardware, as software will check for coincidences in both cases
#Gate width can be approximated by measuring distance between top-most and bottom-most counter, and dividing by the speed of light

#Command line input:
#perl CoinCheck.pl [file to open] [file to save to] [gate width (sec)] [order of channels (top to bottom counter (sq.m))]
#Example:
#perl CoinCheck.pl infile ofile 10 3 2 1

#Script now works with real data and new ThresholdTimes.pl output format, YW 5/25/04 


if($#ARGV < 3){
	print "usage: CoinCheck.pl [file to open] [file to save to] [gate width (sec)] [order of channels (top to bottom counter (sq.m))]\n";
	exit 1;
}

#Set the command line arguments:
&setArgs;

#Determine coincidence level desired by the number of channels user specifies
$clevel=&getcoincidencelevel($first, $second, $third, $fourth);

#Open input and output files
open(IN, "$infile")  || die "Cannot open $infile"; #open infile
open (OUT1, ">$ofile")  || die "Unable to open $ofile"; #open outfile

#print a header for output file
print OUT1 ("#ID.CHANNEL, JULIAN DAY, RISING EDGE(sec), FALLING EDGE(sec), TIME OVER THRESHOLD (nanosec)\n");

$isEmpty=1; #bin is empty in beginning

while (<IN>) {
	@row= split (/\s+/, $_); #parse one line of the RE data into an array called row
	next if(m/^\s*#/);		#skip over comments
	
	$id=$row[0];
	@idArray= split (/\./, $row[0]);    #id info stored in $row[0]
        $idnum=$idArray[0];	
	$chan= $idArray[1];
	$JulianDay=$row[1];
	$REtime=$row[2];
	$FEtime=$row[3];
	$thresh=$row[4];
	chomp $REtime;  #cut off possible newline characters at end of each row
	chomp $FEtime; 
	chomp $thresh;

	if ($isEmpty) { #bin is empty
		if ($chan==$first) { #put channel data into bin
		    $starttime=$REtime;		  
		    $numofitems=1;   #there is now one item in the bin
		    &storedata;  #function to put data into bin
		    $isEmpty=0;  #bin is no longer empty		  
		}    
	}

	else { #bin has something in it already
		#put something else in bin
		if ($chan eq $ARGV[$numofitems+3] && $REtime<$starttime+$width) {
		    $numofitems++;
		    &storedata;
		}
		else {  #time to empty the bin
			$isEmpty=1; #bin gets emptied
			if ($numofitems==$clevel) { #coincidence is found, output the data to file
				for ( $i=1; $i<=$numofitems; $i++) {
				    #new printing format:
					printf OUT1 ("%s\t%s\t%.16lf\t%.16lf\t%.2lf\n", $id[$i], $jd[$i], $RE[$i], $FE[$i], $Thresh[$i]);
				    #old printing format:
			   		#print OUT1 ("$ch[$i]\t$RE[$i]\t$FE[$i]\t$Thresh[$i]\n");
				}
			$numofitems=0;
			}
			if ($chan==$first) { #special case, we need to put channel data into bin after we empty it
			    $starttime=$REtime;
			    $startchan=$chan;
			    $numofitems=1; #there is now one item in the bin
			    &storedata;
			    $isEmpty=0;	#bin is no longer empty
			}
		}
	}
}
 
sub setArgs {
$infile = $ARGV[0];
$ofile = $ARGV[1];
$width = $ARGV[2];
$first = $ARGV[3];
$second = $ARGV[4];
$third = $ARGV[5];
$fourth = $ARGV[6];
}

sub getcoincidencelevel {  #depending on how many channels (n) the user enters, program will look for n-fold coincidence
	$i=0;
	while ($_[$i]) {
		$coinlevel++;
		$i++;
	}
	$coinlevel;  #last line of function gets returned back to main program
}

sub storedata {  #for one row of good data (satifies coincidence requirement, we want to store the data into corresponding arrays for later printing)
	$id[$numofitems] = $id;
	$jd[$numofitems] = $JulianDay;
	$RE[$numofitems] = $REtime;
	$FE[$numofitems] = $FEtime;
	$Thresh[$numofitems] = $thresh;
}
