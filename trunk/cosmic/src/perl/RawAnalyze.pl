#!/usr/bin/env perl
#
# RawAnalyze.pl
# written by Paul Nepywoda - FNAL 6-29-04
#
# Analyzes raw data from the DAQ board and outputs useful statistics about:
# - total events (based on a user-defined event gatewidth or 240 by default)
# - total hits per channel
# - number of orphan rising/falling edges
# - number of good/bad GPS data-lines
# - number of events with N-fold coincidences
# - falling edges that happen before rising edges
# - number of coincidences for a channel in a single event
# - number of coincidences for permutations of all combinations of [1234]
#note: authorative copy now in CVS

if($#ARGV < 1){
	die "usage: $0 [input file] [output file] {[event gatewidth]}\n";
}

BEGIN { $SIG{'__WARN__'} = sub { warn $_[0] if $DOWARN } };		#warn sig handler
$DOWARN=1;

$infile = $ARGV[0];
$outfile = $ARGV[1];
$gatewidth = defined($ARGV[2]) ? $ARGV[2] : 240;	#default gatewidth of 240ns if not specified

die "Error: gatewidth must be a positive integer.\n" if($gatewidth !~ /^\d+$/);

open (IN, "$infile") || die "Cannot open $infile for input\n";
open (OUT, ">$outfile") || die "Cannot open $outfile for output\n";

%event_coincidences = ();
$avg_hits=0;
$total_events=0;
$valid_daq_lines=$gps_line_good=$gps_line_bad=$gps_event_good=$gps_event_bad=0;
$last_PPS=$last_CPLD=$no_CPLD_update=$no_CPLD_update_line=$PPS_seconds=0;
@REorphan=@FEorphan=@total_hits=@FEbeforeRE=(0,0,0,0,0);
#the "only" channel coincidences we want to count (permutations of all combinations of [1234] ):
push(@comb, join("", @$_)) for combinations(1,2,3,4);
foreach(@comb){
	push(@perm, permute2([split ""])) unless /^$/;
}
foreach my $k (@perm){
	$coinc{$k} = 1;
}

#convert MAC OS line breaks to UNIX (same code as in Split.pl)
#Mac OS only has \r for new lines, so Unix reads it as all one big line. We first need to replace
# the \r with \n and then re-read the file, hence the "redo" command
$newline_fixing=1;
while(<IN>){
	$_ =~ s/\r\n?/\n/g;	#see http://www.westwind.com/reference/OS-X/commandline/text-files.html#text-formats
	if($newline_fixing){
		$newline_fixing = 0;
		redo;
	}

    $re="^(.{8}).(..).(..).(..).(..).(..).(..).(..).(..).(.{8}).(.{10}).(.{6}).(.).(..).(.).(.{5})\$";
	if(/$re/o){
		@row = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16);
	}
	else{
        #warn "WARNING! Junk on line $.. Ignoring line:\n $_";
		next;
	}

	$valid_daq_lines++;
	for my $i (1..4){
		&chan_calc($i);
	}
	@matched_chans = sort {$a->{retime} <=> $b->{retime}} @matched_chans;
	while($chandata = shift @matched_chans){
		&analyze_re(\%$chandata);
	}

	#check if we have a good/bad GPS dataline
	$row[12] eq "A" ? $gps_line_good++ : $gps_line_bad++;

	#check if the GPS CPLD updates every second
	if($row[9] ne $last_CPLD){
		$CPLD_updated = 1;
		$last_CPLD = $row[9];
	}
	if($row[10] > $last_PPS or ($row[10] - $last_PPS) < -10000){	#PPS second incremented
		$PPS_seconds++;
		if($CPLD_updated == 0){
			$no_CPLD_update++;
            $no_CPLD_update_line = $.;
		}
		$CPLD_updated = 0;	#reset the check since the PPS incremented
		$last_PPS = $row[10];
	}
}

if($total_events <= 1){
    die "Not enough data in the file for a full gatewidth of analysis.\n";
}


#XML output
for my $c(1..4){ $total_hits_all += $total_hits[$c];};
my $avg_hits_rounded = sprintf("%.2f", $avg_hits);
use File::Basename;
$basename = basename($infile);

for(my $i=1; $i<=4; $i++){
    $REorphan_percent[$i] = ($total_hits[$i] > 0) ? $REorphan[$i]/$total_hits[$i] : 0;
    $REorphan_percent[$i] = sprintf("%.2f", $REorphan_percent[$i]*100);
}
for(my $i=1; $i<=4; $i++){
    $FEorphan_percent[$i] = ($total_hits[$i] > 0) ? $FEorphan[$i]/$total_hits[$i] : 0;
    $FEorphan_percent[$i] = sprintf("%.2f", $FEorphan_percent[$i]*100);
}
for(my $i=1; $i<=4; $i++){
    $FEbeforeRE_percent[$i] = ($total_hits[$i] > 0) ? $FEbeforeRE[$i]/$total_hits[$i] : 0;
    $FEbeforeRE_percent[$i] = sprintf("%.2f", $FEbeforeRE_percent[$i]*100);
}
print OUT "<?xml version=\"1.0\"?>
<file>
    <filename>$basename</filename>
    <events>$total_events</events>
    <lines>$.</lines>
    <gatewidth>$gatewidth</gatewidth>
    <average>$avg_hits_rounded</average>
    <channel>
        <num>1</num>
        <hits>
            <count>$total_hits[1]</count>
        </hits>
        <orphan>
            <rising>
                <count>$REorphan[1]</count>
                <percent>$REorphan_percent[1]</percent>";
for $i (@{$REorphan_line[1]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </rising>
            <falling>
                <count>$FEorphan[1]</count>
                <percent>$FEorphan_percent[1]</percent>";
for $i (@{$FEorphan_line[1]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </falling>
        </orphan>
        <FBR>
            <count>$FEbeforeRE[1]</count>
            <percent>$FEbeforeRE_percent[1]</percent>";
for $i (@{$FEbeforeRE_line[1]}){
    print OUT "
            <line>$i</line>";
}
print OUT "
        </FBR>";
for $key (sort {$a <=> $b} keys %{$chan_coincidences[1]}){
    print OUT "
        <fold>
            <num>$key</num>
            <count>$chan_coincidences[1]{$key}</count>
        </fold>";
}
print OUT "
    </channel>
    <channel>
        <num>2</num>
        <hits>
            <count>$total_hits[2]</count>
        </hits>
        <orphan>
            <rising>
                <count>$REorphan[2]</count>
                <percent>$REorphan_percent[2]</percent>";
for $i (@{$REorphan_line[2]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </rising>
            <falling>
                <count>$FEorphan[2]</count>
                <percent>$FEorphan_percent[2]</percent>";
for $i (@{$FEorphan_line[2]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </falling>
        </orphan>
        <FBR>
            <count>$FEbeforeRE[2]</count>
            <percent>$FEbeforeRE_percent[2]</percent>";
for $i (@{$FEbeforeRE_line[2]}){
    print OUT "
            <line>$i</line>";
}
print OUT "
        </FBR>";
for $key (sort {$a <=> $b} keys %{$chan_coincidences[2]}){
    print OUT "
        <fold>
            <num>$key</num>
            <count>$chan_coincidences[2]{$key}</count>
        </fold>";
}
print OUT "
    </channel>
    <channel>
        <num>3</num>
        <hits>
            <count>$total_hits[3]</count>
        </hits>
        <orphan>
            <rising>
                <count>$REorphan[3]</count>
                <percent>$REorphan_percent[3]</percent>";
for $i (@{$REorphan_line[3]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </rising>
            <falling>
                <count>$FEorphan[3]</count>
                <percent>$FEorphan_percent[3]</percent>";
for $i (@{$FEorphan_line[3]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </falling>
        </orphan>
        <FBR>
            <count>$FEbeforeRE[3]</count>
            <percent>$FEbeforeRE_percent[3]</percent>";
for $i (@{$FEbeforeRE_line[3]}){
    print OUT "
            <line>$i</line>";
}
print OUT "
        </FBR>";
for $key (sort {$a <=> $b} keys %{$chan_coincidences[3]}){
    print OUT "
        <fold>
            <num>$key</num>
            <count>$chan_coincidences[3]{$key}</count>
        </fold>";
}
print OUT "
    </channel>
    <channel>
        <num>4</num>
        <hits>
            <count>$total_hits[4]</count>
        </hits>
        <orphan>
            <rising>
                <count>$REorphan[4]</count>
                <percent>$REorphan_percent[4]</percent>";
for $i (@{$REorphan_line[4]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </rising>
            <falling>
                <count>$FEorphan[4]</count>
                <percent>$FEorphan_percent[4]</percent>";
for $i (@{$FEorphan_line[4]}){
    print OUT "
                <line>$i</line>";
}
print OUT "
            </falling>
        </orphan>
        <FBR>
            <count>$FEbeforeRE[4]</count>
            <percent>$FEbeforeRE_percent[4]</percent>";
for $i (@{$FEbeforeRE_line[4]}){
    print OUT "
            <line>$i</line>";
}
print OUT "
        </FBR>";
for $key (sort {$a <=> $b} keys %{$chan_coincidences[4]}){
    print OUT "
        <fold>
            <num>$key</num>
            <count>$chan_coincidences[4]{$key}</count>
        </fold>";
}
print OUT "
    </channel>
    <coincidence>
        <multichan>";
#find max key for each length string
@event_chan_coincidences_maxkey = (0,1,12,123,1234);
for $key (sort {$a <=> $b} keys %event_chan_coincidences){
    my $len = length($key);
    if($event_chan_coincidences{$key} > $event_chan_coincidences{$event_chan_coincidences_maxkey[$len]}){
        $event_chan_coincidences_maxkey[$len] = $key;
    }
}
for $key (sort {$a <=> $b} keys %event_chan_coincidences){
    my $len = length($key);
    my $total = $event_chan_coincidences_total[$len];
    my $percent = $total > 0 ? $event_chan_coincidences{$key} / $total : 0;
    $percent = sprintf("%.2f", $percent*100);
    print OUT "
            <sequence>
                <string>$key</string>";
    if($key == $event_chan_coincidences_maxkey[$len]){
        print OUT "
                <count id=\"max\">$event_chan_coincidences{$key}</count>";
    }
    else{
        print OUT "
                <count>$event_chan_coincidences{$key}</count>";
    }
    print OUT "
                <percent>$percent</percent>
            </sequence>";
}
print OUT "
        </multichan>";
for $key (sort {$a <=> $b}  keys %event_coincidences){
    print OUT "
        <fold>
            <num>$key</num>
            <count>$event_coincidences{$key}</count>
            <line>$event_coincidences{$key}{line}</line>
        </fold>";
}
my $gps_line_good_percent = sprintf("%.2f", $gps_line_good/$valid_daq_lines*100);
my $gps_line_bad_percent = sprintf("%.2f", $gps_line_bad/$valid_daq_lines*100);
my $gps_event_good_percent = sprintf("%.2f", $gps_event_good/$total_events*100);
my $gps_event_bad_percent = sprintf("%.2f", $gps_event_bad/$total_events*100);
my $no_CPLD_update_percent = sprintf("%.2f", $no_CPLD_update/($PPS_seconds-1)*100);
print OUT "
    </coincidence>
    <gps>
        <good>
            <byline>
                <count>$gps_line_good</count>
                <percent>$gps_line_good_percent</percent>
            </byline>
            <byevent>
                <count>$gps_event_good</count>
                <percent>$gps_event_good_percent</percent>
            </byevent>
        </good>
        <bad>
            <byline>
                <count>$gps_line_bad</count>
                <percent>$gps_line_bad_percent</percent>
            </byline>
            <byevent>
                <count>$gps_event_bad</count>
                <percent>$gps_event_bad_percent</percent>
            </byevent>
        </bad>
        <noupdate>
            <count>$no_CPLD_update</count>
            <line>$no_CPLD_update_line</line>
            <percent>$no_CPLD_update_percent</percent>
        </noupdate>
    </gps>
</file>";
            

#print OUT "Total Events: $total_events, from a $.-line file, using $gatewidth as a gatewidth\n";
#printf OUT "Average hits per Event: %.2f\n", $avg_hits;
#printf OUT "Total hits in Channel 1: %d\n", $total_hits[1];
#printf OUT "Total hits in Channel 2: %d\n", $total_hits[2];
#printf OUT "Total hits in Channel 3: %d\n", $total_hits[3];
#printf OUT "Total hits in Channel 4: %d\n", $total_hits[4];
#for my $c(1..4){ $total_hits_all += $total_hits[$c];};
#printf OUT "Total hits in all channels: %d\n", $total_hits_all;
#print OUT "Orphan Rising Edges Chan 1: $REorphan[1]\n";
#print OUT "Orphan Rising Edges Chan 2: $REorphan[2]\n";
#print OUT "Orphan Rising Edges Chan 3: $REorphan[3]\n";
#print OUT "Orphan Rising Edges Chan 4: $REorphan[4]\n";
#print OUT "Orphan Falling Edges Chan 1: $FEorphan[1]\n";
#print OUT "Orphan Falling Edges Chan 2: $FEorphan[2]\n";
#print OUT "Orphan Falling Edges Chan 3: $FEorphan[3]\n";
#print OUT "Orphan Falling Edges Chan 4: $FEorphan[4]\n";
#for $key (sort {$a <=> $b}  keys %event_coincidences){
#	printf OUT "%d-fold coincidences: %-7d last seen on line:%d\n", $key, $event_coincidences{$key}, $event_coincidences{$key}{line};
#}
#printf OUT "Number of good GPS data-lines: %-8d percent of file: %.2f%%\n", $gps_line_good, $gps_line_good/$valid_daq_lines*100;
#printf OUT "Number of bad GPS data-lines: %-9d percent of file: %.2f%%\n", $gps_line_bad, $gps_line_bad/$valid_daq_lines*100;
#printf OUT "Number of good GPS Events: %-6d percent of file: %.2f%%\n", $gps_event_good, $gps_event_good/$total_events*100;
#printf OUT "Number of bad GPS Events: %-7d percent of file: %.2f%%\n", $gps_event_bad, $gps_event_bad/$total_events*100;
#printf OUT "Number of times the GPS CPLD didn't update for at least a second: %-6d percent of total seconds: %.2f%%\n", $no_CPLD_update, $no_CPLD_update/($PPS_seconds-1)*100;
#printf OUT "Falling edge happens before Rising edge Chan 1: %-5d last seen on line:%d\n", $FEbeforeRE[1], $FEbeforeRE_line[1];
#printf OUT "Falling edge happens before Rising edge Chan 2: %-5d last seen on line:%d\n", $FEbeforeRE[2], $FEbeforeRE_line[2];
#printf OUT "Falling edge happens before Rising edge Chan 3: %-5d last seen on line:%d\n", $FEbeforeRE[3], $FEbeforeRE_line[3];
#printf OUT "Falling edge happens before Rising edge Chan 4: %-5d last seen on line:%d\n", $FEbeforeRE[4], $FEbeforeRE_line[4];
#for $chan (1..4){
#	print OUT "Single channel coincidences $chan -";
#	for $key (sort {$a <=> $b} keys %{$chan_coincidences[$chan]}){
#		print OUT " $key: $chan_coincidences[$chan]{$key}";
#	}
#	print OUT "\n";
#}
#for $key (sort {$a <=> $b} keys %event_chan_coincidences){
#	printf OUT "Channel coincidences:%5s - %d\n", $key, $event_chan_coincidences{$key};
#}


sub chan_calc {
	$ch_num = $_[0];
	$RE = $ch_num*2 - 1;
	$FE = $ch_num*2;
	$decFE=hex($row[$FE]);
	$decRE=hex($row[$RE]);
	$decRow0=hex($row[0]);

	if(hex($row[1]) & 0b10000000){
        if(exists($chan[$ch_num]{retime})){
            #orphan rising edge
            $REorphan[$ch_num]++;
            push @{$REorphan_line[$ch_num]}, $.;
        }
        $chan[$ch_num] = ();
	}
	if($decFE & 0b100000 and !($decRE & 0b100000) and !exists($chan[$ch_num]{retime})){	#orphan falling edge
		$FEorphan[$ch_num]++;
        push @{$FEorphan_line[$ch_num]}, $.;
	}

	#if there's a vaild (6th bit in binary is 1) rising edge we need to match
	if(exists($chan[$ch_num]{retime}) and ($decFE & 0b100000)){
		$chan[$ch_num]{fetime} = $decRow0*24 + ($decFE%32)*(3/4);
		#if there's a full event...
		if(exists($chan[$ch_num]{retime}) and exists($chan[$ch_num]{fetime})){
			$chan[$ch_num]{num} = $ch_num;		#save the channel number
			if($chan[$ch_num]{retime} > $chan[$ch_num]{fetime}){	#REtime > FEtime
				$FEbeforeRE[$ch_num]++; 
				push @{$FEbeforeRE_line[$ch_num]}, $.;
			}
			push @matched_chans, $chan[$ch_num];	#the array of channels with RE-FE pairs which end on this line
			$chan[$ch_num] = ();	#clear the hash since the RE-FE match is complete
		}

		#now, if there's rising edge data on the same line, it's the start of a new event (unrelated to the falling edge on this line)
		if($decRE & 0b100000){
			$chan[$ch_num]{retime} = $decRow0*24 + ($decRE%32)*(3/4);
		}
	}
	#else, this rising edge is unmatched and is the start of a new event
	elsif($decRE & 0b100000){
		$chan[$ch_num]{retime} = $decRow0*24 + ($decRE%32)*(3/4);
		
		#now, if there's rising edge data (on the same line) and a valid falling edge
		if(exists($chan[$ch_num]{retime}) and ($decFE & 0b100000)){
			$chan[$ch_num]{fetime} = $decRow0*24 + ($decFE%32)*(3/4);
			$chan[$ch_num]{num} = $ch_num;		#save the channel number
			if($chan[$ch_num]{retime} > $chan[$ch_num]{fetime}){	#REtime > FEtime
				$FEbeforeRE[$ch_num]++; 
				push @{$FEbeforeRE_line[$ch_num]}, $.;
			}
			push @matched_chans, $chan[$ch_num];	#the array of channels with RE-FE pairs which end on this line
			$chan[$ch_num] = ();	#clear the hash since the RE-FE match is complete
		}
	}
}


sub analyze_re {
	$chandata = $_[0];
	
	#first, since this is a RE-FE pair, increment the channel's total hits
	$total_hits[$chandata->{num}]++;
	
	#the start of this event will be defined as the first rising edge it sees
	if(!defined($event_start)){
		$event_start = $chandata->{retime};
		$gps_for_event_start = $row[12];
		$total_events = 1;
		$gps_for_event_start eq "A" ? $gps_event_good++ : $gps_event_bad++;
	}

	$diff = $chandata->{fetime} - $event_start;
	if($diff < 0){		#if internal counter rolls over
		$event_start -= hex(FFFFFFFF)*24 if($diff < 0);
		$diff = $chandata->{fetime} - $event_start;
	}
	if($diff <= $gatewidth){	#this event is within the current event
		$event_hits[$chandata->{num}]++;	#increment the total hits in this channel for this event

		#add this channel to the array of channeldata for this event
		push @event_chans, $chandata;	#already sorted from sorting @matched_chans
	}
	else{	#start of a new event: analyze what's in the already made "bucket" of a event
		
		#first, find how many hits were in this event
		my $event_total_hits=0;
		for my $i (1..4){
			if(defined($event_hits[$i])){
				#record how many hits were in this event (for all channels)
				$event_total_hits += $event_hits[$i];
				#record how many times this coincidence in an event for this channel occured
				$chan_coincidences[$i]{$event_hits[$i]}++;
			}
		}
		$event_coincidences{$event_total_hits}++;	#increment the total times this coincidence happened
		$event_coincidences{$event_total_hits}{line} = $.-1;    #$.-1 since we're on the NEXT line now

		#second, update the average hits per event for the whole file
		$avg_hits = ($avg_hits*$total_events + $event_total_hits)/($total_events+1);
		$total_events++;

		#third, find out whether the GPS was good or bad for the event
		$gps_for_event_start eq "A" ? $gps_event_good++ : $gps_event_bad++;

		#fourth, calculate the coincidences between the channels for this event
		for my $i (0..$#event_chans){	#1-fold
			for my $j ($i+1..$#event_chans){	#2-fold
				for my $k ($j+1..$#event_chans){	#3-fold
					for my $l ($k+1..$#event_chans){	#4-fold
						my $coin4 = $event_chans[$i]->{num}.$event_chans[$j]->{num}.$event_chans[$k]->{num}.$event_chans[$l]->{num};
						$event_chan_coincidences{$coin4}++ if($coinc{$coin4});
						$event_chan_coincidences_total[4]++ if($coinc{$coin4});   #total num of 4-fold
					}
					my $coin3 = $event_chans[$i]->{num}.$event_chans[$j]->{num}.$event_chans[$k]->{num};
					$event_chan_coincidences{$coin3}++ if($coinc{$coin3});
					$event_chan_coincidences_total[3]++ if($coinc{$coin3});   #total num of 3-fold
				}
				my $coin2 = $event_chans[$i]->{num}.$event_chans[$j]->{num};
				$event_chan_coincidences{$coin2}++ if($coinc{$coin2});
				$event_chan_coincidences_total[2]++ if($coinc{$coin2});   #total num of 2-fold
			}
			#TODO - should we output 1-fold events? (it's already counted in total channel hits)
			my $coin1 = $event_chans[$i]->{num};
			$event_chan_coincidences{$coin1}++ if($coinc{$coin1});
			$event_chan_coincidences_total[1]++ if($coinc{$coin1});   #total num of 1-fold
		}

		#cleanup:
		@event_chans = ();
		@event_hits = ();

		#this hit is the start of a new event
		$event_start = $chandata->{retime};
		$gps_for_event_start = $row[12];
		push @event_chans, $chandata;	#already sorted from sorting @matched_chans
		$event_hits[$chandata->{num}]++;  #increment the total hits in this channel for this (new) event
	}
}


sub permute {
  my $last = pop @_;
  unless (@_) {
    return map [$_], @$last;
  }
  return map { my $left = $_; map [@$left, $_], @$last } permute(@_);
}
sub combinations {
  return [] unless @_;
  my $first = shift;
  my @rest = combinations(@_);
  return @rest, map { [$first, @$_] } @rest;
}

sub permute2 {	#modified from http://iis1.cps.unizar.es/Oreilly/perl/cookbook/ch04_20.htm
    my @items = @{ $_[0] };
    my @perms = @{ $_[1] } if(defined($_[1]));
    unless (@items) {
		$string = "";
		foreach $s (0..$#perms){
			$string .= $perms[$s];
		}
        return ($string);
    } else {
        my(@newitems,@newperms,$i);
		my @permutations = ();
        foreach $i (0 .. $#items) {
            @newitems = @items;
            @newperms = @perms;
            unshift(@newperms, splice(@newitems, $i, 1));
            unshift(@permutations, permute2([@newitems], [@newperms]));
        }
		return @permutations;
    }
}
