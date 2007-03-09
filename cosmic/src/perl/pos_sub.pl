#!/usr/bin/perl
# Subroutine for calculating latitiude, longitude, and altidue from DG data

$infile = $ARGV[0];

open (IN, "$infile");

sub pos1{
	@split_line = split(/\s+/, $_);
	if($split_line[1] eq "Status:"){
		$valid = $split_line[2];
	}
	if($split_line[1] eq "Latitude:"){
		$data[0] = $split_line[2];
		$NS = $split_line[3];
	}
	if($split_line[1] eq "Longitude:"){
		$data[1] = $split_line[2];
		$EW = $split_line[3];
	}
	if($split_line[1] eq "Altitude:"){
		$alt = $split_line[2];
	}
	if($split_line[1] eq "Sats"){
		$sats = $split_line[3];
	}
	# decided that the best data to use for an accurate average is valid data that uses 6 or more satellites.
	next if($valid eq "V");
	next if($sats < 6);
	@lat = split(/:/, $data[0]);
	@long = split(/:/, $data[1]);
	$alt =~ s/m/0/;

	$latitude = $lat[0] + ($lat[1]/60);
	$longitude = $long[0] + ($long[1]/60);
	
	if($NS eq "S"){
		$latitude = $latitude*(-1);
	}
	if($EW eq "W"){
		$longitude = $longitude*(-1);
	}
	
	$sum_lats = $sum_lats + $latitude;
	$lat_count = $lat_count + 1;
	
	$sum_longs = $sum_longs + $longitude;
	$long_count = $long_count + 1;
	
	$sum_alts = $sum_alts + $alt;
	$alt_count = $alt_count + 1;
}

while(<IN>){

	@pos = pos1($_);
}
print "$sum_lats $sum_longs $sum_alts\n$lat_count $long_count $alt_count\n";
