#!/usr/bin/perl
#EventSearch.pl
#
# Takes a *SORTED* ThresholdTimes file and finds showers based on the rising edges
#
# nepywoda changed on 5-20-04: we now output the Julian Day of the Rising Edge(s) in the event lines
# nepywoda changed on 6-14-04: changed the code to not drop the first event in a shower
# nepywoda 7-13-04: argument tests and correct warning/error output
# nepywoda 1-5-05: new output format which also prints event number and number of hit detectors
# nepywoda 6-20-05: channel coincidence checking added

use Getopt::Long;

if($#ARGV < 5){
	die "usage: EventSearch.pl -in [input-file] -out [output-file] -gate [gate width in nanoseconds] -detect [detector coincidence level] -chan [channel coincidence level] -event [event coincidence level]\n";
}

my %h = ();
my $result = GetOptions(\%h, 'in=s', 'out=s', 'gate=i', 'detect=i', 'chan=i', 'event=i');

$infile = $h{'in'};
open (IN, "$infile")  || die "Cannot open $infile for input";
$outfile = $h{'out'};
open (OUT1, ">$outfile")|| die "Unable to open $outfile for output";

#gate width (in partial days) for the signals to fit to be considered a shower
$gate = $h{'gate'}*1e-9/86400;

#number of different detectors which must fire within a gatewidth to be considered a shower
$detector_coincidence = $h{'detect'};
#number of channels within each detector which must fire
$channel_coincidence = $h{'chan'};
#number of hits which need to happen within a gatewidth
$event_coincidence = $h{'event'};


die "Error: Gate width must be an integer.\n" if($h{'gate'} !~ /^\d+$/);
die "Error: Gate width must be greater than zero.\n" if($gate <= 0);
die "Error: Detector coincidence level must be an integer.\n" if($detector_coincidence !~ /^\d+$/);
die "Error: Event coincidence level must be an integer.\n" if($event_coincidence !~ /^\d+$/);
#die "Error: Event coincidence level ($event_coincidence) must be greater than the channel coincidence ($channel_coincidence) times the detector coincidence ($detector_coincidence).\n" if($event_coincidence < ($channel_coincidence*$detector_coincidence));


#Print a header
print OUT1 ("#gatewidth=$gate ($h{'gate'} nanoseconds), detector coincidence=$detector_coincidence, channel coincidence=$channel_coincidence, event coincidence=$event_coincidence\n");
print OUT1 ("#[event number] [num events] [num hit detectors] [ID1.chan] [JD1] [Rising edge 1], [ID2.chan] [JD2] [Rising edge 2], ...\n");

#initialy our gate is closed and the shower array is empty
$gateOpen=0;
@potential_shower = ();

$event_num = 0;         #event counting
%hit_detectors = ();    #different detectors hit in an event

while(<IN>) {
    #if the first character is a'#', then we know it's a comment and we can ignore it.
    if(m/^\s*#/){
        next;
    }

	my($IDChan, $jd, $partial) = split(/\s+/, $_);
    my($id, $chan) = split(/\./, $IDChan);

    #initial beginning time of the gatewidth (reading the beginning of the file)
    if(!defined($potential_shower[0][2])){
        $potential_shower[0][0] = $IDChan;
        $potential_shower[0][1] = $jd;
        $potential_shower[0][2] = $partial;
    }
    
    #find how long this event is from the beginning of the gate
	$currentEventWidth = $partial - $potential_shower[0][2];
	if($currentEventWidth < 0){		#if the counter has reset to 0 (start of a new day), and our event is spanning midnight
		$currentEventWidth += 86400;
	}

	#if the gate is open, and it should be closed...: close the gate, and if there are enough events, consider this as a shower, and write it to the file
	if ($gateOpen==1 && ($currentEventWidth > $gate)){
        #close the gate
		$gateOpen=0;

        #check detector coincidence levels
        my @hit_detectors_arr = keys %hit_detectors;
        my $num_hit_detectors = scalar(@hit_detectors_arr);
        if($num_hit_detectors >= $detector_coincidence){
            #check channel coincidence within each detector
            my $hit_channels_ok = 1;    #assume we have the coincidence we need until proven otherwise
            foreach my $i (@hit_detectors_arr){
                my $channels = $hit_detectors{$i};
                my $num_hit_channels = scalar keys %{$channels};

                $hit_channels_ok = 0 if($num_hit_channels < $channel_coincidence);
            }

            if($hit_channels_ok){
                #check total event coincidence level
                if ($num_events >= $event_coincidence){
                    #increment the global event number count
                    $event_num++;

                    #output to file
                    print OUT1 ("$event_num\t$num_events\t$num_hit_detectors");
                    for(my $i=0; $i<$num_events; $i++){
                        #id.chan jd partial_jd
                        print OUT1 ("\t$potential_shower[$i][0]\t$potential_shower[$i][1]\t$potential_shower[$i][2]");
                    }
                    print OUT1 ("\n");
                }
            }
        }
            

		#clear the shower array and number of events
		@potential_shower = ();
		$num_events=0;
	}

    # if the gate is open and it should stay open...
	if($gateOpen==1 && ($currentEventWidth <= $gate)){
        #record the event
		$potential_shower[$num_events][0] = $IDChan;
		$potential_shower[$num_events][1] = $jd;
		$potential_shower[$num_events][2] = $partial;

        #number of events in this gate
		$num_events++;

        #channel numbers which fired for this detector
        $hit_detectors{$id}{$chan} = 1;
	}

	# if gate is closed...
	if($gateOpen==0){
        #open the gate
		$gateOpen=1;

        #clear number of events in this gate to 0
        $num_events=0;

        #clear the hit detectors and channels in those detectors
        %hit_detectors = ();

        #record the beginning of the gatewidth
		$potential_shower[$num_events][0] = $IDChan;
		$potential_shower[$num_events][1] = $jd;
		$potential_shower[$num_events][2] = $partial;
		$num_events++;
        $hit_detectors{$id}{$chan} = 1;
	}
}

die "No events found with gatewidth: $h{'gate'}ns, detector coincidence: $detector_coincidence, channel coincidence: $channel_coincidence and event coincidence: $event_coincidence. Try changing your parameters.\n" if($event_num == 0);
close OUT1;

#FIXME: hack to sort output file by num_events
if(-x "/opt/sort/sort-2.0/bin/sort"){
    $sort_file = "/opt/sort/sort-2.0/bin/sort";
}
else{
    $sort_file = "sort";
}
`$sort_file -n -k 2,2 -r -o $outfile $outfile`;
