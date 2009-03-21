#!/usr/bin/perl
#Flux.pl
#
# Outputs the particles per time per area (flux)
#
#	Requires the Statistics::Descriptive module
#
#	ASSUMES:
#	Given a *SORTED*-by-REtime ThresholdTimes file with *ONE* channel and *ONE* board ID. Multiple julian days in the file is fine.
#
# by Paul Nepywoda, FNAL 5/25/04
# Changed by TJ on 5 Dec. 2004 want $current_flux to be in units of *seconds* always. User input can smooth the plot by putting more values in the bin but the flux *must* have time units in seconds. Just divided the $my_flux by the user input of time in line #141.
# Wait! Paul already did this on line 140 so I'll just uncomment 140, put line 141 back the way that it was and comment out that lline.
# Changed by ndettman, FNAL 6/7/2007 to put flux in units of counts/min/sec^2, the way it should be plotted

BEGIN {
	$dirname=`dirname $0`;
	chomp($dirname);
	push(@INC, $dirname);
}
use Statistics::Descriptive;

if($#ARGV < 3){
	die "usage: Flux.pl [file to read from] [file to output] [bin width (in seconds)] [base geometry directory path]\n";
}

#for all_geo_data()
$dirname=`dirname $0`;
chomp($dirname);
$commonsubs_loc=$dirname."/CommonSubs.pl";
unless ($return = do $commonsubs_loc) {
	warn "couldn't parse $commonsubs_loc $@" if $@;
	warn "couldn't do $commonsubs_loc: $!"    unless defined $return;
	warn "couldn't run $commonsubs_loc"       unless $return;
	die;
}

$infile=$ARGV[0];
open (IN, "$infile") || die "Cannot open $infile for input";
$outfile=$ARGV[1];

#[Mihael] disabled in the interest of safety
#$binwidth=(eval $ARGV[2])/86400;	#convert seconds to partial days
$binwidth=$ARGV[2]/86400;

$fluxFound=0;
$geo_dir=$ARGV[3];


use Digest::MD5 qw(md5_hex);

#md5 input/output file comparison
my $arg_str = join " ", @ARGV[0..$#ARGV];
my $mtime1 = (stat($0))[9];         #this script's timestamp
my $mtime2 = (stat($infile))[9];    #input file's timestamp
#NOTE: if the geo file changed, it will have been taken account for in ThresholdTimes
$arg_str = "$mtime1 $mtime2 $arg_str";
my $md5 = md5_hex($arg_str);
if(-e $outfile){
    $outmd5 = `head -n 1 $outfile`;
    $outmd5 = substr($outmd5, 1);
    chomp $outmd5;
    print "md5s COMPUTED:$md5 FROMFILE:$outmd5\n";
    if($md5 eq $outmd5){
        print "input argument md5's match, not re-calculating output file: $outfile\n";
        exit;
    }
}

open (OUT, ">$outfile") || die "Unable to open $outfile for output";

print OUT ("#$md5\n");
print OUT ("#md5_hex($arg_str)\n");


die "Error: The geometry directory ($geo_dir) does not exist. Have you setup the geometry file for you detector yet?\n" if(! -e $geo_dir);
die "Please enter a positive number for the bin width.\n" if($binwidth <= 0);

$dayNumber=0;

while(<IN>){
	next if m/\s*#/;    #skip over comments
	@row = split /\s+/;

	#setup an array of "N" Julian Days from the threshold file to create "N" different frequency outputs
	($id, $chan) = split /\./, $row[0];

	#create the array of geometry data for detector $id (only once)
	@geodata = &all_geo_info($id, $geo_dir) unless defined($geodata[0]);
	if(scalar(@geodata) == 0){
		die "No geometry information returned from $geo_dir/$id/$id.geo\n";
	}

	#We need to split the julian day by some multiple of bin width, from an initial RE.
	$firstRe=$row[2] unless defined($firstRe);
	$firstJd=$row[1] unless defined($firstJd);
    $numBinsToUseInOneDay=(1 + int(1.0/$binwidth)) unless defined ($numBinsToUseInOneDay); 
	$dayWBinOffset=($numBinsToUseInOneDay*$binwidth) unless defined($dayWBinOffset);
	@range=($firstRe+$dayNumber*$dayWBinOffset,$firstRe+(1+$dayNumber)*$dayWBinOffset) unless defined(@range);
    
	if(($row[1]-$firstJd+$row[2])<=$range[1] && ($row[1]-$firstJd+$row[2])>=$range[0]) {
		push @data,( $row[2]+($row[1]-$firstJd)) if($row[2]);    #only add RE times if they are defined in the file (in 3rd column
	} elsif(($row[1]-$firstJd+$row[2]) > $range[1]){    #time to do a new day's analysis
        	#analyze what is already in memory
            #if the next signal that would go into the next batch of analysis is farther than one binwidth away we know that 
            #the last bin of this analysis might not be full and we need to not display it (that is why 1 is passed into the 
            #freq_analyze routine.
            if(($row[1]-$firstJd+$row[2])> $range[1]+ $binwidth){
                &freq_analyze(1);
            } else {
        	    &freq_analyze(0);
            }
	    	@data = ();		#clear out the data array for the next freq analysis
            #we need to adjust the dayNumber to fit the next input
            $dayNumber= int(($row[2]+$row[1]-$firstJd-$firstRe)/$dayWBinOffset);
            @range=($firstRe+$dayNumber*$dayWBinOffset,$firstRe+(1+$dayNumber)*$dayWBinOffset);
            push @data,( $row[2]+($row[1]-$firstJd)) if($row[2]);
	} elsif (($row[1]-$firstJd+$row[2]) < $range[0]){
        #this script assumes data comes in sorted order.
        print "data Not sorted\n";
        die "error data file not sorted\n";
    }
}
die "Error: no data found in column $ARGV[2] in file: $infile\n" if($#data < 0);
#This is the last time freq_analyze is called, meaning this is the end of the file. If data 
#stopped before the last bin, then get_full_binsAnd_areas will get rid of the probably partially
#filled bin. If the last of the data falls into the last bin &get_full_binsAnd_areas will not 
#filter it, but even if it is the end of the data file, it probably will be a full bin.
&freq_analyze(1);
die "Error: no Flux found, try getting a file with more data, or lessen the bin widths\n" if($fluxFound <=1);

# Setup the bins, and analyze what's in the @data array. Print results to file.
# The only argument tells the function if this is the end of the data file, if so
# # the last binwidth should be thrown out because it will most likely not be full.
sub freq_analyze {
    if($#data != 0){ #frequency module doesn't work with one data point
        my $throwOutLastBin= $_[0];
        my $numbins = ($range[1]-$range[0]) / $binwidth;  # range contains one more binwidth than needed
        die "The computed number of bins ($numbins) exceeds 10,000. Please enter a larger binwidth ($binwidth).\n" if($numbins > 10000);

        #setup the bins array
        @bins = ();
        for(my $i=$range[0]+$binwidth; $i<$range[1]+$binwidth; $i+=$binwidth){
            push @bins, $i;
        }
        $freq = Statistics::Descriptive::Full->new();
        #$freq->presorted(1);	#doesn't seem to make a difference in performance
        $freq->add_data(@data);

        #keys %freq = int($numbins)+1;		#pre-allocate hash structure
        # any value of a key from %freq contains the number of elements that are equal to or less than the current key, and greater than the previous key
        %freq = $freq->frequency_distribution(\@bins);

        @keysOfHash=(sort keys(%freq));
        &get_full_binsAnd_areas($throwOutLastBin);

        $keyIterator=0;
        while($keyIterator<= $#keysWanted){
			#[Mihael] disabled in the interest of safety
            #my $current_flux = ($freq{($keysWanted[$keyIterator])}/(eval $ARGV[2])/$areaArray[$keyIterator]);
            # Flux should be in units of counts/min/m^2, not counts/sec/m^2, hence the extra factor of 60
			my $current_flux = ($freq{($keysWanted[$keyIterator])}/($ARGV[2]/60)/$areaArray[$keyIterator]);
			
            my $binmiddle = $keysWanted[$keyIterator]-($binwidth/2);     #gnuplot plots values at the middle of bins
            ($day, $month, $year, $hour, $min, $sec) = &jd_to_gregorian($firstJd+ int($binmiddle), $binmiddle-int($binmiddle));
            printf OUT "%02d/%02d/%02d %02d:%02d:%02d %f\n", $month, $day, $year, $hour, $min, $sec, $current_flux;
            $fluxFound++;
            $keyIterator++;
        }
    }
}

sub get_full_binsAnd_areas {
    #Only data that is surrounded by non-zero bins should be displayed. 
    ##Because if a nonzero bin, is adjacent to a zero bin, then the nonzero bin is probably not full.
    ###And since not full bins lower our flux, they should be ignored.

    $deleteLastBin=$_[0];
    @keysWanted=();
    @areaArray=();
    #if there is no daya then do nothing.
    if($#keysOfHash==-1){
    } elsif ($#keysOfHash==0) {
    #if there is only one key then just make sure area doesn't change in geo file
        $binArea=&detectorRangeArea($firstJd+$keysOfHash[0]-$binwidth,$firstJd+$keysOfHash[0]);
        if($binArea !=0){
            push @keysWanted, $keysOfHash[0];
            push @areaArray,$binArea;
        }
    } else {
        #if there is only one bin, then only check to make sure geometry file is constant
        #first and last keys have special conditions they only have one neighbor
        if($freq{$keysOfHash[0]}!=0 && $freq{$keysOfHash[1]} !=0) {
            $binArea=&detectorRangeArea($firstJd+$keysOfHash[0]-$binwidth,$firstJd+$keysOfHash[0]);
            if($binArea !=0){
                push @keysWanted, $keysOfHash[0];
                push @areaArray,$binArea;
            }
        }
        #for all other bins
        for($a=1;$a<$#keysOfHash; $a++){
            if($freq{$keysOfHash[$a]}!=0 && $freq{$keysOfHash[$a-1]} !=0 && $freq{$keysOfHash[$a+1]} !=0){
                $binArea=&detectorRangeArea($firstJd+$keysOfHash[$a-1],$firstJd+$keysOfHash[$a]);
                if($binArea !=0){
                    push @keysWanted, $keysOfHash[$a];
                    push @areaArray,$binArea;
                }
            }
        }
        #last bin check
        if($freq{$keysOfHash[$#keysOfHash-1]}!=0 && $freq{$keysOfHash[$#keysOfHash]} !=0) {
            $binArea=&detectorRangeArea($firstJd+$keysOfHash[$#keysOfHash-1],$firstJd+$keysOfHash[$#keysOfHash]);
            if($binArea !=0){
                push @keysWanted, $keysOfHash[$#keysOfHash];
                push @areaArray,$binArea;
            }
        }
    }
    if(($deleteLastBin==1)  && ($#keysWanted>-1) && ($keysWanted[$#keysWanted] eq $bins[$#bins]) ){
        pop @keysWanted; 
    }
}

sub detectorRangeArea {
    #INPUT: 2 julian days. first one is always smaler than the second one.
    #Output: detector area if area exits in that range, and it doesn't change.
    #Output: if geofile doesn't have information, then stop program

    my $startTime=$_[0];
    my $endTime=$_[1];
    my $geoPlaceStartTime=-1;
    my $geoPlaceEndTime=-1;
    my $iterator = 0;
    for $iterator (0..$#geodata){
        if($geodata[$iterator]{'jd'} > $startTime){
            #if the geo data we see is greater than the date we're analyzing, we know there's no applicable geometry information after this point
            last;
        }
        #else, this geometry JD was less than the JD in the file
        $geoPlaceStartTime= $iterator;
    }
    for $iterator ($geoPlaceStartTime..$#geodata){
        if($geodata[$iterator]{'jd'} > $endTime){
            #if the geo data we see is greater than the date we're analyzing, we know there's no applicable geometry information after this point
            last;
        }
        #else, this geometry JD was less than the JD in the file
        $geoPlaceEndTime= $iterator;
    }
    if($geoPlaceStartTime== -1 || $geoPlaceEndTime==-1){    #we didn't find any geo data for this date
        if($geoPlaceStartTime==-1){
            @date = jd_to_gregorian(int($startTime), $startTime-int($startTime));
        } else {
            @date = jd_to_gregorian(int($endTime), $endTime-int($endTime));
        }
        $data_time = "$date[0]/$date[1]/$date[2] $date[3]:$date[4]:$date[5]";
        @date_arr = split /\./, $geodata[$iterator]{jd};
        @date = jd_to_gregorian($date_arr[0], $date_arr[1]);
        $geo_time = "$date[0]/$date[1]/$date[2] $date[3]:$date[4]:$date[5]";
        die "The only geometry information found for detector #$id was later than your data's date. (Your data's date: $data_time. Earliest geometry information for: $geo_time)\n";
    }
    my $start_chan_area = $geodata[$geoPlaceStartTime]{'chan'.$chan}{'area'};
    my $end_chan_area = $geodata[$geoPlaceEndTime]{'chan'.$chan}{'area'};
    die "The area for channel $chan in detector #$id is $start_chan_area or $end_chan_area. Please edit the geometry file and give channel $chan an area > 0.\n" if($start_chan_area<= 0 || $end_chan_area<=0);
    if($start_chan_area==$end_chan_area) {
        return $start_chan_area;
    } else {
        return 0;
    }
}
