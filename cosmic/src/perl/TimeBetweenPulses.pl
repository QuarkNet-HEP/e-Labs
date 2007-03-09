#!/usr/bin/perl
# For use with output from ThresholdTimes.pl
# Computes the time between consecutive rising edges on each channel
#
#Written by Paul Nepywoda, FNAL on 1-12-04
#nepywoda modified on 1-15-04 to work with new ThresholdTimes format

if($#ARGV < 1){
	print "usage: TimeBetweenPulses.pl [file of REs to open] [file to save to]\n";
	exit 1;
}

$infile = shift(@ARGV);
open IN, "$infile";
$ofile = shift(@ARGV);
open OUT, ">$ofile";

#print a header
print OUT "#Channel, Time Diffence of Rising Edge (seconds)\n";


while(<IN>){
	next if(m/^\s*#/);		#skip over comments

	$_ =~ s/^[0-9]{4}\.//;		#remove detector ID from first collumn

	@row = split /\s/, $_;
	$chan = $row[0];
	$jd = $row[1];
	$time = $row[2]*86400;		#mult partial JD to get seconds

	if(defined($prevtime{$chan})){		#we have a previous time to compare to on this channel
		if(defined($prevday) && $jd > $prevday){				#we're on the next julian day
			$prevtime{$chan} -= 1;
		}
		$diff = $time - $prevtime{$chan};
		if($diff < 0){			#wraparound case when the counter resets
			$diff += 86400;
		}
		printf OUT "%s\t%.12f\n", $chan, $diff;
		$prevtime{$chan} = $time;
	}
	else{					#first time we have data on this channel
		$prevtime{$chan} = $time;
	}

	$prevday = $jd;
}
