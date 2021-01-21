#!/usr/bin/perl

# EPeronja - 2020-12-28
# This program looks for decays according to the following logic:
# 1-Read the input file ordered by rising edge
# 2-Create a buffer based on a time window provided by the gatewidth
# 3-Look for muons in selected buffer: select first muon and define muon buffer using the muon gate
# 4-Test muon buffer against user parameters for coincidence, require and veto
# 5-Find electron and electron buffer using the electron gate and minimun delay
# 6-Test electron buffer against user parameters for coincidence, require and veto
# 7-Test if the muon found and the electron found for decay
# 8-Write decay to output file

if($#ARGV < 13){    
    die "usage: lifetime.pl [filename to open] [filename to save to] [file to save feedback] [gatewidth in seconds] ".
    	"[lifetime_muon_coincidence] [lifetime_muon_gate] [lifetime_muon_singleChannel_require]".
    	"[lifetime_muon_singleChannel_veto] [lifetime_electron_coincidence] [lifetime_electron_gate]".
    	"[lifetime_electron_singleChannel_require] [lifetime_electron_singleChannel_veto]".
    	"[lifetime_minimum_delay] [geometry directory]\n";
}

# Retrieve command line arguments
$infile=$ARGV[0];
open(IN, "$infile") || die "Cannot open $infile for input";
$ofile= $ARGV[1];
$feedback = $ARGV[2];
open(OUT, ">$ofile")  || die "Unable to open $ofile for output";
open(LIFEOUT,">$feedback") || die "Unable to open $ofile_feedback for feedback";
$gatewidth=$ARGV[3];
$muonCoincidence=$ARGV[4];
$muonGate=$ARGV[5];
$muonChannelRequireString=$ARGV[6];
@muonChannelRequire = split " ", $muonChannelRequireString;
$muonChannelVetoString=$ARGV[7];
@muonChannelVeto = split " ", $muonChannelVetoString;
$electronCoincidence=$ARGV[8];
$electronGate=$ARGV[9];
$electronChannelRequireString=$ARGV[10];
@electronChannelRequire = split " ", $electronChannelRequireString;
$electronChannelVetoString=$ARGV[11];
@electronChannelVeto = split " ", $electronChannelVetoString;
$minimumDelay=$ARGV[12];

# Constants
$numSecondsInADay=86400;
$constantTimeErrorAllowed=1e-9/$numSecondsInADay;
$offset=$gatewidth/$numSecondsInADay; 
$debugger = 1;

print OUT ("# channelNumb JulianDay PossibleDecayLength(MicroSeconds) StartDecay EndDecay ".
			"FirstSignalTimeOverThreshold(nanoseconds) SecondSignalTimeoverThreshold(nanoseconds) PossibleDecayNumber\n");

print LIFEOUT "Lifetime analysis - User parameters:\n";
print LIFEOUT "Gatewidth: $gatewidth secs\n";
print LIFEOUT "Muon Coincidence: $muonCoincidence\n";
print LIFEOUT "Muon Gate: $muonGate ns\n";
print LIFEOUT "Muon Channel Require: @muonChannelRequire\n";
print LIFEOUT "Muon Channel Veto: @muonChannelVeto\n";
print LIFEOUT "Electron Coincidence: $electronCoincidence\n";
print LIFEOUT "Electron Gate: $electronGate ns\n";
print LIFEOUT "Electron Channel Require: @electronChannelRequire\n";
print LIFEOUT "Electron Channel Veto: @electronChannelVeto\n";
print LIFEOUT "Minimum Delay: $minimumDelay ns\n";
print LIFEOUT "Offset: $offset\n";

# Read lines into a big buffer and ignore lines with comments when beginning to read the file
while (<IN>) {
	next if m/^\s*#/;
	push(@remainingbuffer, $_);
}# End of reading the file into a large buffer

# main routine
$buffercounter = 1; #remove later
$bufferwithgoodmuons = 0;
$totaldecaysfound = 0;
$electrontail = 0;
$buffersize = @remainingbuffer;
@buffersummary = ();
while($buffersize > 0) {
	@buffersummary = ();
	if ($debugger == 1) {
		push(@buffersummary, "\n\nBuffer: $buffercounter\n");
		#print LIFEOUT "\n\nBuffer: $buffercounter\n";
	}
	@buffer = createBuffer();
	if (@buffer > 1) {
		($foundmuon, @muonbuffer) = findMuon(@buffer);
		if ($debugger == 1) {
			push(@buffersummary, "Muon Found: $foundmuon");
		}
		$muonbuffersize = @muonbuffer;
		if ($foundmuon ne "") {
			$bufferwithgoodmuons += 1;
			$lastmuon = $muonbuffer[$muonbuffersize-1];
			@electronbuffer = getElectronBuffer(\@buffer,$foundmuon,$lastmuon);
			($foundelectron, @subbuffer)  = findElectron(\@electronbuffer);
			if ($debugger == 1) {
				push(@buffersummary,"Electron Found: $foundelectron\n");
			}
			if ($foundelectron ne "") {
				($decayfound, $cnt) = findDecay($foundmuon, $foundelectron, \@subbuffer);
				if ($decayfound == 1) {
					$totaldecaysfound += 1;
					$electrontail += $cnt;
					$buffersummarysize = @buffersummary;
					for my $i (0..$buffersummarysize-1) {
					print LIFEOUT "$buffersummary[$i]";
					}	
				}
			}
		}
	}
	#$buffersummarysize = @buffersummary;
	#for my $i (0..$buffersummarysize-1) {
	#print LIFEOUT "$buffersummary[$i]";
	#}	
	$buffersize = @remainingbuffer;
	if ($buffersize <= 0) {
		last;
	}
	$buffercounter += 1;
}# end of main routine
print LIFEOUT ("#SUMMARY:\n");
print LIFEOUT ("#-Number of buffers that pass a good muon: ",$bufferwithgoodmuons,"\n");
print LIFEOUT ("#-Total decays found: ", $totaldecaysfound, "\n");
print LIFEOUT ("#-Number of electrons between the min decay and 6ms: ", $electrontail, "\n");

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

sub findDecay() {
	$decayfound = 0;
	$tail = 0;
	if ($debugger == 1) {
		push(@buffersummary,"Find Decay:\n");
	}
	my ($localmuon,$localelectron,$subbuff) = @_;
	@localsubbuffer = @{$subbuff};
	@localmuonparts = split(/\s+/,$localmuon);
	@localelectronparts = split(/\s+/,$localelectron);
	$muonchannel = $localmuonparts[0];
	$muonjulian = $localmuonparts[1];
	$muontime = $localmuonparts[2];
	$juliandaydiff = $localelectronparts[1] - $muonjulian;
	$timedifference = ($juliandaydiff + $localelectronparts[2]) - $muontime;
	if (3.4e-12 < $timedifference && $timedifference < $offset) {
		$diffinms = $timedifference*($numSecondsInADay*1e6);
		if ($debugger == 1) {
			push(@buffersummary, "$muonchannel $muonjulian $diffinms $muontime $localelectronparts[2] $localmuonparts[4] $localelectronparts[4] 1");
		}
		printf OUT ("%s\t%s\t%.5f\t%.16f\t%.16f\t%s\t%s\t%s\n", $muonchannel,$muonjulian, $diffinms, $muontime,$localelectronparts[2],$localmuonparts[4],$localelectronparts[4], 1);
		$decayfound = 1;
		$buffsize = @localsubbuffer;
		for my $x (0..$buffsize-2) {
			$timediffmicro = getTimeDifferenceMicro($localelectron, $localsubbuffer[$x+1]);
			if ($timediffmicro < 6) {
				$tail += 1;
			}
		}
	}	
	return $decayfound, $tail;
}# end of decay calculation

sub findMuon() {
	my @localbuffer = @_;
	$muon = "";
	$foundmuon = $localbuffer[0];
	$firstmuon = $localbuffer[0];
	@muonbuffer = ();
	push(@muonbuffer, $firstmuon);
	if ($debugger == 1) {
		push(@buffersummary,"\nMuon Analysis:\n");
		push(@buffersummary,"$foundmuon");
	}
	$buffersize = @localbuffer;
	for my $i (0..($buffersize-2)) {
		$possiblemuon = $localbuffer[$i+1];
		$timedifferenceinns = getTimeDifference($firstmuon, $possiblemuon);
		$cleanline = $possiblemuon;
		$cleanline =~ s/\r|\n//g;
		if ($debugger == 1) {
			push(@buffersummary,"$cleanline $timedifferenceinns $muonGate ns\n");
		}
		if ($timedifferenceinns < $muonGate) {
			push(@muonbuffer, $possiblemuon);
		}
	}
	# get the counters to check for coincidence
	$muonbuffersize = @muonbuffer;
	@muoncounters = ();
	for my $x (0..($muonbuffersize-1)) {
		@muonparts = split(/\s+/, $muonbuffer[$x]);
		@counterparts = split(/\./, $muonparts[0]);
		push(@muoncounters, $counterparts[1]) if ("@muoncounters" !~ /\b$counterparts[1]\b/ );
	}
	#print LIFEOUT "muoncounters: @muoncounters\n";
	# check muon coincidence
	$muonbuffercoincidence = @muoncounters;
	if ($debugger == 1) {
		push(@buffersummary,"Number of hit counters in muon buffer: $muonbuffercoincidence\n");
	}
	if ($muonbuffercoincidence >= $muonCoincidence) {
		if ($debugger == 1) {
			push(@buffersummary,"Multiplicity is greater than or equal to muon coincidence required.\n");
		}
		$keepgoingofornow = 1;
	} else {
		if ($debugger == 1) {
			push(@buffersummary,"Muon coincidence is not satisfied.\n");
		}
		$muon = "";
		return ($muon,@muonbuffer);
	}
	
	# check if any counter has been vetoed in the muon buffer
	if ($debugger == 1) {
		push(@buffersummary,"Muon channel veto parameter:@muonChannelVeto -Channels in buffer: @muoncounters\n");
	}
	$answer = checkVetoedChannels(\@muonChannelVeto, \@muoncounters);
	if ($answer == 0) {
		if ($debugger == 1) {
			push(@buffersummary,"Channel(s) from buffer found in -MUON CHANNEL VETO- parameter. Goodbye\n");
		}
		$muon = "";
		return ($muon,@muonbuffer);		
	} else {
		if ($debugger == 1) {
			push(@buffersummary,"The -MUON CHANNEL VETO- parameter does not interfere with the buffer. Continue.\n");
		}
		$keepgoingofornow = 1;
	}
	
	# check if the required channels are in the muon buffer
	$answer = checkRequiredChannels(\@muonChannelRequire, \@muoncounters);
	if ($answer == 0) {
		if ($debugger == 1) {
			push(@buffersummary,"Channel(s) in -MUON CHANNEL REQUIRE- parameter not found. Goodbye\n");
		}
		$muon = "";
		return ($muon,@muonbuffer);
	} else {
		if ($debugger == 1) {		
			push(@buffersummary,"Channel(s) in -MUON CHANNEL REQUIRE- parameter OK. Continue\n");
		}
		$keepgoingfornow = 1;
	}
	
	return ($foundmuon,@muonbuffer);
}# end of finding muon

sub getElectronBuffer() {
	my ($localbuff,$localmuon,$locallast) = @_;
	if ($debugger == 1) {
		push(@buffersummary,"Electron analysis:\n");
	}
	@electronbuffer = ();
	$startposition = 0;
	@localbuffer = @{$localbuff};
	$localsize = @localbuffer;
	for my $i (0..$localsize-1) {	
		if ($localbuffer[$i] eq $locallast) {
			#print LIFEOUT "comparing: $localbuffer[$i]";
			#print LIFEOUT "local last: $locallast";
			$startposition = $i+1;
		}
	}
	if ($debugger == 1) {
		push(@buffersummary,"We need to satisfy the minimum delay between the muon and the electron\n");
	}
	for my $i ($startposition..$localsize-1) {
		$candidateelectron = $localbuffer[$i];
		$timedifferenceinns = getTimeDifference($localmuon,$candidateelectron);
		$cleanline = $candidateelectron;
		$cleanline =~ s/\r|\n//g;
		if ($timedifferenceinns > $minimumDelay) {
			if ($debugger == 1) {
				push(@buffersummary,"$cleanline $timedifferenceinns $minimumDelay ns\n");
			}
			push(@electronbuffer, $candidateelectron);
		}
	}	
	return @electronbuffer;
}# end of getting the electron buffer

sub findElectron() {
	my ($localelecbuff) = @_;
	$electron = "";
	@subbuffer = ();
	if ($debugger == 1) {
		push(@buffersummary,"Check candidate electron buffer for the electron gate first if there is more than one electron.\n");
	}
	@localelectronbuffer = @{$localelecbuff};
	$localelectronbuffersize = @localelectronbuffer;
	if ($localelectronbuffersize > 0) {
		$foundelectron = $localelectronbuffer[0];
		push(@subbuffer, $foundelectron);
		for my $i (0..$localelectronbuffersize-2) {
			$possibleelectron = $localelectronbuffer[$i+1];
			$timedifferenceinns = getTimeDifference($foundelectron,$possibleelectron);
			$cleanline = $possibleelectron;
			$cleanline =~ s/\r|\n//g;
			if ($debugger == 1) {
				push(@buffersummary,"$cleanline, $timedifferenceinns, $electronGate\n");
			}
			if ($timedifferenceinns < $electronGate) {
				push(@subbuffer, $possibleelectron);
			} 
		}
		#checkelectronbuffer
		$answer = checkElectronBuffer(\@subbuffer);
		if ($answer == 0) {
			$electron = "";
			return ($electron,@subbuffer);
		} else {
			$electron = $foundelectron;
		}		
	}
	return ($electron,@subbuffer);
}# end of finding electron

sub checkElectronBuffer() {
	my ($localbuff) = @_;
	# get the counters to check for coincidence
	@localelectronbuff = @{$localbuff};
	#print LIFEOUT "\nBegin electron buffer:\n";
	#while( my ($i,$line) = each @localelectronbuff) {
	#	print LIFEOUT $line;
	#}
	#print LIFEOUT "End electon buffer\n";
	$electronbuffersize = @localelectronbuff;
	@electroncounters = ();
	for my $x (0..$electronbuffersize-1) {
		@electronparts = split(/\s+/, $localelectronbuff[$x]);
		@counterparts = split(/\./, $electronparts[0]);
		push(@electroncounters, $counterparts[1]) if ("@electroncounters" !~ /\b$counterparts[1]\b/ );
	}

	if ($debugger == 1) {
		push(@buffersummary,"electroncounters: @electroncounters\n");
	}
	# check electron coincidence
	$electronbuffercoincidence = @electroncounters;
	if ($electronbuffercoincidence >= $electronCoincidence) {
		if ($debugger == 1) {
			push(@buffersummary,"Multiplicity is greater than or equal to electron coincidence required.\n");
		}
		$keepgoingofornow = 1;
	} else {
		if ($debugger == 1) {
			push(@buffersummary,"Electron coincidence is not satisfied.\n");
		}
		return 0;
	}
	
	# check if any counter has been vetoed in the electron buffer
	$answer = checkVetoedChannels(\@electronChannelVeto, \@electroncounters);
	if ($answer == 0) {
		if ($debugger == 1) {
			push(@buffersummary,"Channel(s) from buffer found in -ELECTRON CHANNEL VETO- parameter. Goodbye\n");
		}
		return 0;
	} else {
		if ($debugger == 1) {
			push(@buffersummary,"The -ELECTRON CHANNEL VETO- parameter does not interfere with the buffer. Continue.\n");
		}
		$keepgoingofornow = 1;
	}
	
	# check if the required channels are in the electron buffer
	$answer = checkRequiredChannels(\@electronChannelRequire, \@electroncounters);
	if ($answer == 0) {
		if ($debugger == 1) {
			push(@buffersummary,"Channel(s) in -ELECTRON CHANNEL REQUIRE- parameter not found. Goodbye\n");
		}
		return 0;
	} else {
		if ($debugger == 1) {
			push(@buffersummary,"Channel(s) in -ELECTRON CHANNEL REQUIRE- parameter OK. Continue\n");
		}
		$keepgoingfornow = 1;
	}
	return 1;
}# end of checking the electron buffer against user parameters

sub getTimeDifference() {
	my ($current, $candidate) = @_;
	@currentparts = split(/\s+/, $current);
	@candidateparts = split(/\s+/, $candidate);
	$currenttime = $currentparts[2];
	$currentjulian = $currentparts[1];
	$juliandaydifference = $candidateparts[1] - $currentjulian;
	$timedifference = $juliandaydifference + $candidateparts[2] - $currenttime;
	$timediffinns = $timedifference*$numSecondsInADay*(1e9);
	return $timediffinns;
}# end of getting the time difference between two lines

sub getTimeDifferenceMicro() {
	my ($current, $candidate) = @_;
	@currentparts = split(/\s+/, $current);
	@candidateparts = split(/\s+/, $candidate);
	$currenttime = $currentparts[2];
	$currentjulian = $currentparts[1];
	$juliandaydifference = $candidateparts[1] - $currentjulian;
	$timedifference = $juliandaydifference + $candidateparts[2] - $currenttime;
	$timediffinmacro = $timedifference*$numSecondsInADay*(1e6);
	return $timediffinmacro;
}# end of getting the time difference between two lines

sub checkVetoedChannels() {
	my ($vetoparameters, $localcounters) = @_;
	$channelfound = 1;
	@veto = @{$vetoparameters};
	@counters = @{$localcounters};
	$paramlength = @veto;
	#print LIFEOUT "IN CHECK VETOED CHANNELS\n";
	#print LIFEOUT "veto: @veto\n";
	#print LIFEOUT "counters: @counters\n";
	
	if ($paramlength == 1 && $veto[0] == "0") {
		$channelfound = 1;
	} else {
    	my %exists = map { $_ => 1 } @$vetoparameters;
    	foreach my $ts ( @{$localcounters} ) {
 			#print LIFEOUT "$ts\n";
        	if ($exists{$ts}) {
        		$channelfound = 0;
        		return $channelfound;
        	}
    	}
	}
	return $channelfound;
}# end of checking vetoed channels

sub checkRequiredChannels() {
	my ($requireparameters, $localcounters) = @_;
	$channelfound = 1;
	@require = @{$requireparameters};
	@counters = @{$localcounters};
	$paramlength = @require;
	if ($paramlength == 1 && $require[0] == "0") {
		$channelfound = 1;
	} else {
		my %exists = map {$_ => 1} @$localcounters;
		foreach my $ts (@{$requireparameters}) {
			if ($exists{$ts}) {
				$keepgoingfornow = 1;
			} else {
				$channelfound = 0;
				return $channelfound;
			}
		}
	}
	return $channelfound;
}# end of checking required channels
