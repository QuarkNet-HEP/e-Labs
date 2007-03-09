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

open (IN, "$infile");
#open (OUT, ">$outfile");

while (<IN>){
    @split_line = split(/\s+/, $_);
    # calculates the number of seconds from the time and CPLD offset
    $hour = substr($split_line[10], 0, 2);
    $min = substr($split_line[10], 2, 2);
    $sec = substr($split_line[10], 4, 6);
    $sec_offset = sprintf("%.0f", $sec + ($split_line[15]/1000));
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
            
        if ($ticks_old > $ticks_new){ # accounts for when the tick counter resets to zero
            $maxticks = hex("FFFFFFFF");
            $ticks_new = $ticks_new + $maxticks;
        }
            
        $ticks_diff = $ticks_new - $ticks_old;
        $time_diff = $day_seconds - $seconds;
        $freq = $ticks_diff/$time_diff;
            
        push @frequency, $freq;
            
        $freq_tot += $freq;
        $count++;
    }
    # redefines variables for checking to see if the next line has the same data as this line
    $time = $split_line[10];
    $hex = $split_line[9];
    $seconds = $day_seconds;
}
# finds overall average frequency to find standard deviation
$freq = $freq_tot/$count;
foreach $i (@frequency){ # calculates the sum for the standard deviation
    $value = ($i - $freq)**2;
    $value_tot += $value;
}
$sigma = sqrt($value_tot/$count);
$low = $freq - $sigma;
$high = $freq + $sigma;
foreach $i (@frequency){ # only calculates the "real" average frequency using data within one standard deviation of average
    if ($i > $low && $i < $high){
        $real_freq_tot += $i;
        $real_count++;
    }
}
$real_freq = $real_freq_tot/$real_count;
$perc = $real_count/$count*100;
    
print "standard deviation: $sigma\n";
print "average frequency is: $real_freq\n";
print "percentage: $perc\n";
