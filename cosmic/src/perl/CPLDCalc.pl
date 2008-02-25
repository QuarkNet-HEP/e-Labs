#!/usr/bin/perl
#
# Written by Nick Dettman FNAL 1-5-05
#
# Takes a split data file and finds the actual CPLD freq that the DAQ board is set to.

if ($#ARGV < 0){
    print "usage: CPLDCalc.pl [input-file]";
}

$infile = $ARGV[0] || die "Cannot open $infile";
#$outfile = $ARGV[1] || die "Cannot open $outfile";

$fg1 = 41666667;					
$fg2 = 25000000;						

$N = 0xffffffff + 1;
$Nover2 = int($N/2);


open (IN, "$infile");
#open (OUT, ">$outfile");

$ssum = 0;
$minf = 2*$fg;
$maxf = 0;

while (<IN>) {
    @split_line = split(/\s+/, $_);
    if ($#split_line != 15) {
    	#print "Invalid line: $_. Skipping.\n";
    	next;
    }
    # calculates the number of seconds from the time and CPLD offset
    $hour = substr($split_line[10], 0, 2);
    $min = substr($split_line[10], 2, 2);
    $sec = substr($split_line[10], 4, 6);
    $sec_offset = int($sec + ($split_line[15]/1000));
    #$sec_offset = $sec + ($split_line[15]/1000);

    $day_seconds = $hour*3600 + $min*60 + $sec_offset;
    if ($day_seconds == 86400){
        $day_seconds = 0;
    }
    if ($hex == $split_line[9] || $seconds == $day_seconds){ # both columns must advance to calculate the change
        next;
    }
    if (defined($hex)){
        $ticks_new = hex($split_line[9]);
        $ticks_old = hex($hex);
            
        $dc = ($ticks_new - $ticks_old) % $N;
   		$dt = ($day_seconds - $seconds);
   		    
   		#calculate CPLD frequency with first guess
        $cpld_freq = $fg1 + (($dc - $fg1*$dt + $Nover2) % $N - $Nover2)/$dt;
        
        #$k = int($cpld_freq*$dt/$N);
        
        #print "dc=$dc, dt=$dt, k=$k, f=$cpld_freq\n";
        	
        $cpld_freq_tot1 += $cpld_freq;
        push @cpld_frequency1, $cpld_freq;
        
        #calculate CPLD frequency with second guess
        $cpld_freq = $fg2 + (($dc - $fg2*$dt + $Nover2) % $N - $Nover2)/$dt;
        	
        $cpld_freq_tot2 += $cpld_freq;
        push @cpld_frequency2, $cpld_freq;
            
        $cpld_count++;
    }
    # redefines variables for checking to see if the next line has the same data as this line
    $time = $split_line[10];
    $hex = $split_line[9];
    $seconds = $day_seconds;
}

calculate_cpld_frequency();

$low = $freq - $sigma;
$high = $freq + $sigma;
foreach $i (@frequency){ # only calculates the "real" average frequency using data within one standard deviation of average
    if ($i > $low && $i < $high){
        $real_freq_tot += $i;
        $real_count++;
    }
}
$real_freq = $real_freq_tot/$real_count;
$perc = $real_count/$cpld_count*100;
    
print "  standard deviation: $sigma\n";
print "average frequency is: $real_freq\n";
print "percentage: $perc\n";

sub stddev {
	 my $avg = shift;
	 my $n = shift;
	 
	 my $s = 0;
	 foreach $x (@_) {
	 	$s += ($avg - $x)**2;
	 }
	 return sqrt($s/$n);
}

sub calculate_cpld_frequency {
	# calculate averages for both guesses
	$cpld_freq1 = $cpld_freq_tot1/$cpld_count;
	$cpld_freq2 = $cpld_freq_tot2/$cpld_count;
	# calculate standard deviations for both CPLD frequency guesses
			
	$cpld_sigma1 = stddev($cpld_freq1, $cpld_count, @cpld_frequency1);
	$cpld_sigma2 = stddev($cpld_freq2, $cpld_count, @cpld_frequency2);
				
	# select the one with the lowest stddev
	# now, the guesses are only used when the
	# CPLD clock counter wraps around in weird ways
	# If that doesn't happen at all, both calculations
	# will yield the same result, so it doesn't matter
	# which one is chosen
	if ($cpld_sigma1 > $cpld_sigma2) {
		$sigma = $cpld_sigma2;
		$freq = $cpld_freq2;
		@frequency = @cpld_frequency2;
	}
	else {
		$sigma = $cpld_sigma1;
		$freq = $cpld_freq1;
		@frequency = @cpld_frequency1;
	}
}
