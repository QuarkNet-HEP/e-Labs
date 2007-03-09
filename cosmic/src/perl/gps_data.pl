#!/usr/bin/perl
# distance
#
# Program used to analyze GPS data
# 
# Run the raw data through to pick out the DG data and analyze current position
#
# Written by Nick Dettman, FNAL 7-13-04
# Updated 1-12-05 to take out Date, Time, Validity, and Sats from raw data instead of DG in case no DG is run
if($#ARGV < 3){
	print "usage: [datafile being analyzed] [filename for gps and graph data]\n[# of satellites being analyzed] [percent of data closest to average position]\n";
	exit 1;
} 
$infile = $ARGV[0];
$outfile_data = $ARGV[1];
$outfile_graph = $outfile_data.".graph";
$sats = $ARGV[2];
$percent = $ARGV[3];

open (IN, "$infile") || die "Cannot open file $infile\n";
open (OUT, ">$outfile_data") || die "Cannot open file $outfile_data\n";
print OUT ("# Date Time Validity Latitude Longitude Altitude Sats\n");
# start writing to the general gps data file

while(<IN>){
	# take out all of the DG data from the raw data script to use for gps data
    # if no DGs are run, take the data possible from the raw data
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
	if($split_line[1] eq "Latitude:"){
		$data[4] = $split_line[2];
		$data[5] = $split_line[3];
        # check to see if there are any DGs present in the data
        $DG_count++;
    }
	elsif($split_line[1] eq "Longitude:"){
		$data[6] = $split_line[2];
		$data[7] = $split_line[3];
	}
	elsif($split_line[1] eq "Altitude:"){
		$data[8] = $split_line[2];
	}
	next if($sec == $second);
	$second = $sec;
	if ($data[3] >= $sats){
        $total_val_count++;
    }
    # only print out valid data
    if(defined($data[3])){
		if($data[2] eq "A"){
			foreach $i (@data){
				print OUT "$i ";
			}
			print OUT "\n";
		}
	}
    # clear out the data array in order to not print out DG data if there is none on the next line
    @data = ();
}

close (OUT);
close (IN);
# open the file you just wrote to
# format for this file should look like this:
# 12/01/05 14:52:33.746 A 04 41:50.2946 N 088:15.6977 W 253.8m
# 12/01/05 15:05:11.697 A 05 41:50.2950 N 088:15.6978 W 261.9m
open (IN, "$outfile_data") || die "Cannot open file $outfile_data\n";
open (OUT, ">$outfile_graph") || die "Cannot open file $outfile_graph\n";

while($line=<IN>){
	next if($line=~m/#/);
	@data = split(/\s+/, $line);
	@lat = split(/:/, $data[4]);
	@long = split(/:/, $data[6]);
	$alt = $data[8];
	$alt =~ s/m/0/;
	
	$sum_lats += $lat[1];
	$lat_count++;

	$sum_longs += $long[1];
	$long_count++;

	if($data[3] > $maxsats){
		$maxsats = $data[3];
	}
}
close (IN);
$avg_lat = $sum_lats/$lat_count;
$avg_long = $sum_longs/$long_count;

$avg_lat = $avg_lat/60;
$avg_lat = &deg2meters($avg_lat,0);

$avg_long = $avg_long/60;
$avg_long = &deg2meters($avg_long,41.83823);

open (IN, "$outfile_data");

# start writing to the file used for the plotting script

while($line=<IN>){
	next if($line=~m/#/);
    @data = split(/\s+/, $line);
	@lat = split(/:/, $data[4]);
    @long = split(/:/, $data[6]);
    $alt = $data[8];
    $alt =~ s/m//;
	
    $sat_count++;

	next if($data[3] < $sats);

    $sat_counts++;
    $val_count++;

    if(defined($data[8])){
        $sum_alt += $alt;
        $alt_count++;
        
        $degreeslat = $lat[0];
        $degreeslong = $long[0];
        
        $total_lat += $lat[1];
        $total_long += $long[1];
        $total_lat_count++;
        $total_long_count++;

        $long[1] = &deg2meters($long[1]/60,41.83823);
        $lat[1] = &deg2meters($lat[1]/60,0);

        # find the distance away from the average

        $dist = (($lat[1] - $avg_lat)**2 + ($long[1] - $avg_long)**2)**(1/2);

        push @percent1,$dist;

        if($dist > $max_dist){
            $max_dist = $dist;
        }

        print OUT "$lat[1] $long[1] $alt\n";
    }
}
# arrange the distances by number to take the closest percent
@percent = sort { $a <=> $b } @percent1;
$length = $#percent1 + 1;
for($i = 0; $i < $length*($percent/100); $i++){
	$total_dist += $percent1[$i];
	$total++;
}
close(IN);
close(OUT);
# makes sure there are no "illegal division by zero" errors if no DG data is present
if ($DG_count != 0){
    $avg_alt = $sum_alt/$alt_count;
    $lat_avg = $total_lat/$total_lat_count;
    $long_avg = $total_long/$total_long_count;
    $dist_avg = $total_dist/$total;
}
$val_perc = $val_count/$total_val_count*100;
$number_sats = $sat_count;
$sat_count = $sat_counts/$sat_count*100;
##          RESULTS NOTES:
## max dist: maximum distance away from average
## percent dist avg: the average distance using the closest specified 
# percent of data
## amt of data with sats: the amount of data using the specified amount of 
# satellites
## amt of total data: the amount of all the data
## percent of data: the percent of data that uses the specified amount of 
# satellites
## max sats: the maximum amount of satellites seen at any given time in the data
## avg lat: the average latitude
## avg long: the average longitude
## avg alt: the average altitude
## val perc: the percent of data with specified satellites that was valid
if ($DG_count == 0){
    print "max dist, percent dist avg, and avg lat, long, and alt cannot be obtained unless DG is run during data collection\n";
}
else {
    print "max dist: $max_dist\n";
    print "percent dist avg ($percent): $dist_avg\n";
}
print "amt of data with sats: $sat_counts\n";
print "amt of total data: $number_sats\n";
print "percent of data: $sat_count\n";
print "max sats: $maxsats\n";
print "val perc: $val_perc\n";
if ($DG_count != 0){
    print "avg lat: $degreeslat".":$lat_avg\n";
    print "avg long: $degreeslong".":$long_avg\n";
    print "avg alt: $avg_alt\n";
}

sub deg2meters {
    # arguments: longitude degrees, latitude degrees
    # returns: length in meters which corresponds to the longitude degrees
    # NOTE: to get latitude degrees for anyplace on the earth, pass 0 for the latitude
    my $deg = $_[0];
    my $latitude = $_[1];
    my $pi=3.1415926535897932;
    my $RADIUS="6378137.0";     #radius of the earth
    my $P=$RADIUS*2*$pi;        #perimeter of the earth
    return $deg*(cos($latitude*$pi/180)*$P/360);
}   
    
