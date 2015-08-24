#!/usr/bin/perl
# Takes a line (event) from output of EventSearch.pl, looks up the x, y 
# coordinates, outputs a datafile with (x, y, t) for creating a 3D graph of one event
#
#written by Paul Nepywoda, FNAL on 1-12-04
#
# nepywoda 5-1-05: modified to work with the new output format from EventSearch.pl

if($#ARGV < 4){
	die "usage: EventChoice.pl [input events file] [output file] [event number] [zero-zero-zero point ID] [geometry directory path]\n";
}

#look at first ID.Channel#, Rising edge time
#this Rising edge time will be t=0
#subsequent rising edges will be a time in nanoseconds after the first rising edge time


$infile=$ARGV[0];
$ofile=$ARGV[1];
$event_num=$ARGV[2];
$zerozeroID=$ARGV[3];	#the ID of the detector that we're choosing to be 0-0-0 on the graph that we make
$geo_dir=$ARGV[4];	#base directory for geometry (cosmic.datadir in the Quarknet JSP files)

open(IN, "$infile")  || die "Cannot open $infile for input";
open (OUT, ">$ofile")  || die "Unable to open $ofile for output";

#for deg2meters() and geo_data()
$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
	warn "couldn't parse $commonsubs_loc $@" if $@;
	warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
	warn "couldn't run $commonsubs_loc"       unless $return;
	die;
}

while($line = <IN>){
    if($line =~ /^$event_num\s/){
        $line =~ s/\s*$//;		#remove trailing tabs/whitespace
        @event = split(/\s+/, $line);

        last;
    }
}
die "Error: Event number $event_num not found in the file $infile.\n" if(!defined(@event));
$shift_event_num = shift(@event);
die "Error: Event number found ($shift_event_num) doesn't match event number specified ($event_num).\n" if($shift_event_num != $event_num);

#unused here
$num_events = shift(@event);
$num_hit_detectors = shift(@event);

#print the header
print OUT ("#Event number $event_num in $infile\n");
print OUT ("#x-coord\ty-coord\ttime(nanosec)\tdetector.chan\n");


while (@event) { #while there is still data on the line, consider each id.chan|JD|RE triple
	$IDChan=shift(@event);
	$jd=shift(@event);
	$REtime=shift(@event);
    
	($id, $chan) = split(/\./, $IDChan);  #split apart the ID and channel number

	%zero_info = &geo_info($zerozeroID, $jd+$REtime, $geo_dir) unless defined $zero_info{jd};
	%curr_info = &geo_info($id, $jd+$REtime, $geo_dir);
	%curr_info = &geo_info($id, $jd+$REtime, $geo_dir);
	$startTime = $REtime unless defined($startTime);	#startTime for the rising edge is the first RE in the line

	($x, $y, $z) = &getxyz(\%zero_info, \%curr_info, $startTime, $REtime, $chan);

    #output to the file
	printf OUT ("%0.1f\t%0.1f\t%0.1f\t%s\n", $x, $y, $z, $IDChan);
}



#Functions
sub getxyz {
	#zinforef and inforef are array references
	(my $zero_inforef, my $curr_inforef, my $startTime, my $REtime, my $chan) = @_;

	#compute the offset in x and y where the current detector is located from the zero-zero point
	#x is N/S and y is E/W
	my @latarray = split /\./, $curr_inforef->{'lat'};
	my @longarray = split /\./, $curr_inforef->{'long'};
	my @zero_latarray = split /\./, $zero_inforef->{'lat'};
	my @zero_longarray = split /\./, $zero_inforef->{'long'};
	#pad the last part with trailing zeros to complete 6 digits: this is the maximum allowed in the geometry
	#then we can safely divide by 1000000
	$latarraypadded = substr($latarray[2] . "0" x 6, 0, 6);
	$zerolatarraypadded = substr($zero_latarray[2] . "0" x 6, 0, 6);
	$longarraypadded = substr($longarray[2] . "0" x 6, 0, 6);
	$zerolongarraypadded = substr($zero_longarray[2] . "0" x 6, 0, 6);

	$currlat = $latarray[0]+$latarray[1]/60+$latarraypadded/1000000/60;	#current lattitude for use in deg2meters
	#calculate lalitude offset from zero_zero_zero point (of GPS)
	my $latoff =  $currlat - ($zero_latarray[0]+$zero_latarray[1]/60+$zerolatarraypadded/1000000/60);
	#calculate longitude offset from zero_zero_zero point (of GPS)
	my $longoff = ($longarray[0]+$longarray[1]/60+$longarraypadded/1000000/60) - ($zero_longarray[0]+$zero_longarray[1]/60+$zerolongarraypadded/1000000/60);
	#calculate absolute y offset in meters (of GPS)
	my $yoff = &deg2meters($latoff, $currlat);
	#calculate absolute x offset in meters (of GPS)
	my $xoff = &deg2meters($longoff, $currlat);
	#TODO- we're ignoring altitude for now

	#finally, compute the absolute x-y coordinates for the specified channel
	my $chan_str = "chan"."$chan";
	my $x = $curr_inforef->{$chan_str}{'x'} + $xoff;
	my $y = $curr_inforef->{$chan_str}{'y'} + $yoff;
#printf "chanx chany: %s %s\n", $curr_inforef->{$chan_str}{'x'}, $curr_inforef->{$chan_str}{'y'};
	#TODO- again, ignoring altitude

	my $time=($REtime-$startTime)*1e9*86400;		#time in nanoseconds

	return ($x, $y, $time);
}

