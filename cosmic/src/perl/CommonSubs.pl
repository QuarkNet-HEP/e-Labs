# This is a file of common subroutines for our purposes
# These can be included and used in other scripts with the line: do "[PATH]/CommonSubs.pl"

sub curr_jd{ 
    # arguments: none
    # returns: the current julian day as a double (down to the second)
 
	my ($sec,$min,$hour,$day,$month,$year) = gmtime(time);
	
	return jd($day, $month+1, $year+1900, $hour, $min, $sec);
}

sub curr_line_jd{
	# arguments: current offset (in sec) and @row array of raw data
	# returns: the julian day for this row with this offset
	my ($offset, @row) = @_;

	my @dmy=split(//, $row[11]);
	my @hms=split(//, $row[10]);
	my $day=$dmy[0] . $dmy[1];
	my $month=$dmy[2] . $dmy[3];
	my $year=$dmy[4] . $dmy[5];
	my $hour=$hms[0] . $hms[1];
	my $min=$hms[2] . $hms[3];
	my $sec=$hms[4] . $hms[5];
	my $msec=$hms[7] . $hms[8] . $hms[9];
	#my $offset = $row[15];
	$year = $year+2000; # Assume no records before 2000

	#my $sec_offset = sprintf("%.0f", $sec + $msec/1000 + $offset/1000);		#add in GPS offset
	my $sec_offset = sprintf("%.0f", $sec + $msec/1000 + $offset);		#add in GPS offset

	my $jd = jd($day, $month, $year, $hour, $min, $sec_offset);
	$jd = sprintf("%0.f", $jd*86400);	#convert to seconds to round to nearest second
	$jd = int($jd/86400);				#convert back to days and truncate the fraction
	return $jd;
}

sub curr_line_time_setup{
    # arguments: @row array from raw data
	# returns: array of (sec, min, hour, day, month, year) with the word 16 offset taken into account
	my @row=@_;

    #*performance*: substr is around 30% faster than modulus
    my $day = substr($row[11], 0, 2);
    my $month = substr($row[11], 2, 2);
    my $year = substr($row[11], 4, 2) + 2000;   # Assume no records before 2000
    my $hour = substr($row[10], 0, 2);
    my $min = substr($row[10], 2, 2);
    my $sec = substr($row[10], 4, 2);
    my $msec = substr($row[10], 7, 3);
    
	my $offset = $row[15];
	my $CPLDdifference = (hex($row[0])-hex($row[9]))/41666667;
	my $sec_offset = sprintf("%.0f", $sec + $msec/1000 + $offset/1000);
	$sec_offset += $CPLDdifference;

	return ($sec_offset, $min, $hour, $day, $month, $year);
}

sub big_curr_jd{
    # arguments: none
    # returns: a BigFloat instance containing the current julian day
	my $sec = `date -u +%S`;
	my $min = `date -u +%M`;
	my $hour = `date -u +%H`;
	my $day = `date -u +%d`;
	my $month = `date -u +%m`;
	my $year = `date -u +%Y`;
	
	return big_jd($day, $month, $year, $hour, $min, $sec);
}


sub jd{	
	# arguments: day[1..31], month[1..12], year[..2004..], hour[0..23], min[0..59], sec[0..59]
	#(sec min and hour can be omitted and the JD will be calculated for the day at midnight)
    # returns: the julian day as a double down to the second

	#The integer JD: on 6 May 2002 this information sat on:http://quasar.as.utexas.edu/BillInfo/JulianDatesG.html

	(my $day, my $month, my $year, my $hour, my $min, my $sec) = @_;
	if($#_ < 3){
		$sec = $min = $hour = 0;
	}
	if ($month < 3) {
		$month = $month + 12;
		$year = $year-1;
	}

	return (2 -(int($year/100))+(int($year/400))+ $day + int(365.25*($year+4716)) + int(30.6001*($month+1)) - 1524.5) + ($hour + $min/60 + $sec/3600)/24;
}

sub big_jd{	
	# arguments: day[1..31], month[1..12], year[..2004..], hour[0..23], min[0..59], sec[0..59]
	#(sec min and hour can be omitted and the JD will be calculated for the day at midnight)
    # returns: a BigFloat instance containing the julian day

	(my $day, my $month, my $year, my $hour, my $min, my $sec) = @_;
	if($#_ < 3){
		$sec = $min = $hour = 0;
	}
	if ($month < 3) {
		$month = $month + 12;
		$year = $year-1;
	}

	Math::BigFloat->precision(-10);
	my $jd = Math::BigFloat->new(2 -(int($year/100))+(int($year/400))+ $day + int(365.25*($year+4716)) + int(30.6001*($month+1)) - 1524.5);
	my $decjd = Math::BigFloat->new(($hour + $min/60 + $sec/3600)/24);
	$jd->badd($decjd);

	return $jd;
}

sub jd_to_gregorian{
	# arguments: an integer julian day, optionally the partial julian day. Example: jd_to_gregorian(2453283, .098888)
	# returns: (day[1..31], month[1..12], year[..2004..]) array
    # returns: a (day, month, year, hour, min, sec, millisec, microsec, nanosec) array if the partial julian day is passed
    $Z = $_[0] + 0.5;
    if($_[1]){
        $Z += $_[1];
    }
	$Z = int($Z);
	$W = int(($Z - 1867216.25)/36524.25);
 	$X = int($W/4);
	$A = $Z+1+$W-$X;
	$B = $A+1524;
	$C = int(($B-122.1)/365.25);
	$D = int(365.25*$C);
	$E = int(($B-$D)/30.6001);
 	$F = int(30.6001*$E);
	$day = $B-$D-$F;
	$month = $E-1 <= 12 ? $E-1 : $E-13;	#Month = E-1 or E-13 (must get number less than or equal to 12)
	$year = $month <= 2 ? $C-4715 : $C-4716;	#Year = C-4715 (if Month is January or February) or C-4716 (otherwise)

	if($_[1]){
		$hour = int($_[1]*24);
		$min = int(($_[1]*24-$hour)*60);
		$sec = int((($_[1]*24-$hour)*60-$min)*60);
		$msec = int(((($_[1]*24-$hour)*60-$min)*60-$sec)*1000);
		$micsec = int((((($_[1]*24-$hour)*60-$min)*60-$sec)*1000-$msec)*1000);
		$nsec = int(((((($_[1]*24-$hour)*60-$min)*60-$sec)*1000-$msec)*1000)*1000);

		return ($day, $month, $year, ($hour+12)%24, $min, $sec, $msec, $micsec, $nsec);
	}

	return ($day, $month, $year);
}

sub meters2deg {
    # arguments: meters, latitude
    # returns: a float containing the longitude degrees this translates into
    # NOTE: to get latitude degrees for anyplace on the earth, pass 0 for the latitude
	my $meters = $_[0];
	my $latitude = $_[1];
	my $pi=3.1415926535897932;
	my $RADIUS="6378137.0";		#radius of the earth
	my $P=$RADIUS*2*$pi;		#perimeter of the earth
	return $meters/(cos($latitude*$pi/180)*$P/360);
}
sub deg2meters {
    # arguments: longitude degrees, latitude degrees
    # returns: length in meters which corresponds to the longitude degrees
    # NOTE: to get latitude degrees for anyplace on the earth, pass 0 for the latitude
	my $deg = $_[0];
	my $latitude = $_[1];
	my $pi=3.1415926535897932;
	my $RADIUS="6378137.0";		#radius of the earth
	my $P=$RADIUS*2*$pi;		#perimeter of the earth
	return $deg*(cos($latitude*$pi/180)*$P/360);
}


sub geo_info {
	# arguments: ID, julian date, base geometry directory
	# returns: a hash of the most recent geometry information before the specified julian date
	my $id=$_[0];
	my $jd=$_[1];
	my $geo_dir=$_[2];
	my %info;

	open(GEO, "$geo_dir/$id/$id.geo") or die("Cannot open the .geo file: $geo_dir/$id/$id.geo (it may not exist yet)\n");
	while($geoline=<GEO>){
		next until $geoline =~ /^[0-9]{7}(\.[0-9]*)*$/;	#skip lines until you hit a julian day timestamp (JD will have 7 numbers left of the decimal)

		#if the current geometry jd is later than the specified jd, return the info hash (if $geoline > $jd initially, then the hash's values will be undefined)
		if($geoline > $jd){
			return %info;
		}
		
		$line[0]=$geoline;	#jd
		$line[1]=<GEO>;		#lat
		$line[2]=<GEO>;		#long
		$line[3]=<GEO>;		#alt
		$line[4]=<GEO>;		#stacked
		$line[5]=<GEO>;		#chan1
		$line[6]=<GEO>;		#chan2
		$line[7]=<GEO>;		#chan3
		$line[8]=<GEO>;		#chan4
        # If the next line is a JD, there is no entry for gps cable length, and we'll make it 0
		if ($line[9] =~ /^[0-9]{7}(\.[0-9]*)*$/) { $gpsCabLen = 0; }
        else { $gpsCabLen = <GEO>; }
        
		chomp(@line);

		@chan1 = split /\s+/, $line[5];
		@chan2 = split /\s+/, $line[6];
		@chan3 = split /\s+/, $line[7];
		@chan4 = split /\s+/, $line[8];
        #this code is a hack, if cable length is not in the geo file, then we will add we will assume it is zero
        if(!exists($chan1[4])){
            $chan1[4]=0;
        }
        if(!exists($chan2[4])){
            $chan2[4]=0;
        }
        if(!exists($chan3[4])){
            $chan3[4]=0;
        }
        if(!exists($chan4[4])){
            $chan4[4]=0;
        }       
        #info is changed to hold the cable length 12-21-04 Evgeni
        #info changed to hold gps cable length 6/12/07 ndettman
		%info = (	'jd' => $line[0],
					'lat' => $line[1],
					'long' => $line[2],
					'alt' => $line[3],
					'stacked' => $line[4],

					'chan1' => { 'x' => $chan1[0], 'y' => $chan1[1], 'z' => $chan1[2], 'area' => $chan1[3], 'cabLen' => $chan1[4] },
					'chan2' => { 'x' => $chan2[0], 'y' => $chan2[1], 'z' => $chan2[2], 'area' => $chan2[3], 'cabLen' => $chan2[4] },
					'chan3' => { 'x' => $chan3[0], 'y' => $chan3[1], 'z' => $chan3[2], 'area' => $chan3[3], 'cabLen' => $chan3[4] },
					'chan4' => { 'x' => $chan4[0], 'y' => $chan4[1], 'z' => $chan4[2], 'area' => $chan4[3], 'cabLen' => $chan4[4] },
                    'gpsCabLen' => $gpsCabLen);
		$i++;
	}
	close GEO;
	return %info;
}


sub all_geo_info {
	# arguments: detector ID, base geometry directory
	# returns: an array of hashes of all the data in the geometry file
	my $id=$_[0];
	my $geo_dir=$_[1];
	my @info;

	open(GEO, "$geo_dir/$id/$id.geo") or die("Cannot open the .geo file: $geo_dir/$id/$id.geo (it may not exist yet)\n");

	my $i=0;
	while($geoline=<GEO>){
		next until $geoline =~ /^[0-9]{7}(\.[0-9]*)*$/;	#skip lines until you hit a julian day timestamp (JD will have 7 numbers left of the decimal)
		
		$line[0]=$geoline;	#jd
		$line[1]=<GEO>;		#lat
		$line[2]=<GEO>;		#long
		$line[3]=<GEO>;		#alt
		$line[4]=<GEO>;		#stacked
		$line[5]=<GEO>;		#chan1
		$line[6]=<GEO>;		#chan2
		$line[7]=<GEO>;		#chan3
		$line[8]=<GEO>;		#chan4
        # If the next line is a JD, there is no entry for gps cable length, and we'll make it 0
		if ($line[9] =~ /^[0-9]{7}(\.[0-9]*)*$/) { $gpsCabLen = 0; }
        else { $gpsCabLen = <GEO>; }

		chomp(@line);

		@chan1 = split /\s+/, $line[5];
		@chan2 = split /\s+/, $line[6];
		@chan3 = split /\s+/, $line[7];
		@chan4 = split /\s+/, $line[8];
        #if cable length is not in the geo file, then we will add we will assume it is zero
        $chan1[4] = 0 if($chan1[4] eq "");
        $chan2[4] = 0 if($chan2[4] eq "");
        $chan3[4] = 0 if($chan3[4] eq "");
        $chan4[4] = 0 if($chan4[4] eq "");
 
		$info[$i] = {	'jd' => $line[0],
						'lat' => $line[1],
						'long' => $line[2],
						'alt' => $line[3],
						'stacked' => $line[4],
                        'chan1' => { 'x' => $chan1[0], 'y' => $chan1[1], 'z' => $chan1[2], 'area' => $chan1[3], 'cabLen' => $chan1[4] },
					    'chan2' => { 'x' => $chan2[0], 'y' => $chan2[1], 'z' => $chan2[2], 'area' => $chan2[3], 'cabLen' => $chan2[4] },
					    'chan3' => { 'x' => $chan3[0], 'y' => $chan3[1], 'z' => $chan3[2], 'area' => $chan3[3], 'cabLen' => $chan3[4] },
					    'chan4' => { 'x' => $chan4[0], 'y' => $chan4[1], 'z' => $chan4[2], 'area' => $chan4[3], 'cabLen' => $chan4[4] },
                        'gpsCabLen' => $gpsCabLen};

		$i++;
	}
	close GEO;
	return @info;
}



#needs to be here:
1
