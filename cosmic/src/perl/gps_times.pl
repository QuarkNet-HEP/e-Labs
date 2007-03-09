#!/usr/bin/perl
## gps_times.pl
##
## created by Nick Dettman, FNAL 08/04/04
##
## Program used to study the relationship between the number of satellites and the time of day and print out a plotting file
## Updated on 1/12/05 to take out Date, Time, Validity, and Sats from raw data instead of DG in case no DG is run

if($#ARGV < 3){
	print "usage: [datafile being analyzed] [file being written to]\n[look at a specific date (type 'day') or look at all dates together (type 'all')]\n[whether you want a plot by hours (type 'hours') or minutes (type 'minutes')]\n[date to look at (if 'day' chosen)]\n";
	exit 1;
}

# the time choice only pertains to the data printed to the outfile.  The data ouputted onto the screen will always be in hours.

$infile = $ARGV[0];
$outfile = $ARGV[1];
$choice = $ARGV[2];
$timesplit = $ARGV[3];

if($choice eq "day"){
	$day = $ARGV[5];
}
# makes sure the arguments are correct
if($choice ne "all" && $choice ne "day"){
	die "Must choose either 'all' or 'day'\n";
}
if($timesplit ne "hours" && $timesplit ne "minutes"){
	die "Must choose either 'hours' or 'minutes'\n";
}

open (IN, "$infile") || die "Cannot open file $infile\n";
open (OUT, ">$outfile") || die "Cannot open file $outfile\n";

while (<IN>){
	# takes the data from the raw data file
	@split_line = split(/\s+/, $_);
    $day = substr($split_line[11], 0, 2);    
    $month = substr($split_line[11], 2, 2);    
    $year = substr($split_line[11], 4, 2);    
    $hour = substr($split_line[10], 0, 2);    
    $min = substr($split_line[10], 2, 2);    
    $sec = substr($split_line[10], 4, 6);	
    $data[0] = "$day/$month/$year";
    $data[1] = $hour.":$min".":$sec";
    $data[2] = $split_line[12];
    $data[3] = $split_line[13];
    next if($min == $minute);
	next unless defined($data[3]);
	$minute = $min;
	$sats = $data[3];
	# makes the change from Greenwich Mean Time to Central Time (will need to tweak if in a different time zone)
	# GMT is 5 hours ahead of CT
	$hour = $hour - 5;
	if($hour < 0){
		$hour = 24 - (5 + $hour);
		$day[0] = $day[0] - 1;
	}
	# sets up an array of all dates in the data in case you chose a date that is not in the data
	if($choice eq "day"){
		if($day != $days){
			$datadays[$day] = $day;
		}
		$days = $day;
		next if($day != $day);
	}
	# prints out the file which can be used for plotting purposes
	if($timesplit eq "minutes"){
		$min1 = ($hour*60) + $minute;
		print OUT "$min1 $sats\n";
	}
	else {
		print OUT "$hour $sats\n";
	}
	# sets up a 2-D array in which to store data for satellites versus time of day
	for($i = 0; $i <= 23; $i++){
		if($hour == $i){
			# makes it so the program outputs data as greater than or equal to N satellites instead of just equal to
			for($j = $sats; $j > 0; $j--){
				$k = $i + (24*($j - 1));
				# makes the validity and sats counts
				$val_count[$k] ++;
				if($data[2] eq "A"){
					$total_count[$j] ++;
					$val[$k] ++;
					$count[$k] ++;
				}
			}
		}
	}
	$count++;
    if ($sats > $max_sats){
        $max_sats = $sats;
    }
}
@datadays = sort { $a <=> $b } @datadays;
shift (@datadays);
# dies if no data for the selected date
if($count == 0){
	die "No data for selected date\ndates for this file are: @datadays\n";
}
# calculates the percents for validity and sat sightings
for($j = 1; $j <= $max_sats; $j++){
	for($i = 0; $i <= 23; $i++){
		$k = $i + (24*($j - 1));
		if($total_count[$j] == 0){
			$total_count[$j] ++;
		}
		$perc_count[$k] = $count[$k]/$total_count[$j]*100;
		if($val_count[$k] == 0){
			$val_count[$k] ++;
		}
		$perc_val[$k] = $val[$k]/$val_count[$k]*100;
	}
}
# sets up the grid to print the data out to
print " AM:   12 - 1   1 - 2    2 - 3    3 - 4    4 - 5    5 - 6    6 - 7    7 - 8    8 - 9    9 - 10   10 - 11  11 - 12\n";
for($j = 1; $j <= $max_sats; $j++){
	print "$j sats:\n";
	print " sats  ";
	# finds the data from the appropriate location and prints it
	for($i = 0; $i <= 11; $i++){
		$k = $i + (24*($j - 1));
		printf "%3.4f\%  ", "$perc_count[$k]";
	}
	print "\n";
	print " valid ";
	for($i = 0; $i <= 11; $i++){
		$k = $i + (24*($j - 1));
		printf "%3.3f\%  ", "$perc_val[$k]%";
	}
	print "\n"
}
print "\n";

print " PM:   12 - 1   1 - 2    2 - 3    3 - 4    4 - 5    5 - 6    6 - 7    7 - 8    8 - 9    9 - 10   10 - 11  11 - 12\n";

for($j = 1; $j <= $max_sats; $j++){
	print "$j sats:\n";
	print " sats  ";
	for($i = 0; $i <= 11; $i++){
		$k = ($i + 12) + (24*($j - 1));
		printf "%3.4f\%  ", "$perc_count[$k]%";
	}
	print "\n";
	print " valid ";
	for($i = 0; $i <= 11; $i++){
		$k = ($i + 12) + (24*($j - 1));
		printf "%3.3f\%  ", "$perc_val[$k]%";
	}
	print "\n";
}
