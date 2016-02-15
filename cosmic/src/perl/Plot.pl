#!/usr/bin/perl
# Generic Plotting script using gnuplot
#
# Written by Paul Nepywoda, FNAL 6-10-04
# Edited by Evgeni Peryshkin, FNAL 6-25-04
# nepywoda 7-14-04: argument tests and correct warning/error output
# this is made to work with gnuplot 4.0
# Jordan 3 Nov-2004, changed point shape for 3D plots, location of caption prints for lifetimw with fit and placement of x and y labels for 3D
# Jordan 6 December 2004, changed line plot (type=1) so that it plots both lines and points. I remarked line #70 and added lline #71 in this file.
# ndettman 6/27/05 changing the arguments style to use Getopt, so that this script can handle the dynamic number of datafiles that may need to be plotted.  This is dynamic because we are now plotting multiple channels for the performance study on the same graph.
# Jordan removed error bars from flux plots (type = 1) and set Ymin = 0 for same
# ndettman, FNAL 6/11/07: corrected the Ymin = 0 argument so it works

use Getopt::Long;

if($#ARGV < 4){
	die "usage: Plot.pl -file [datafile 1 to plot] -file [datafile 2 to plot, etc] -extra [extrafunctions file] -param [parameter filename] -svg [.png filename] -type [plot type] optional for all(-title [title label] -ylabel [ylabel] -xlabel [xlabel] -caption [caption] -lowx [x lowerbound] -highx [x upperbound] -lowy [y lowerbound] -highy [y upperbound]) optional for 3D graphs(-zlabel [zlabel] -lowz [z lowerbound] -highz [z upperbound])\n\tplot type: 0 - histogram, 1 - line, 2 - 3d, 3 - lifetime-histogram w/ best-fit line, 4 - Scatter, 5 - TEST. 6 - 3d w/o lines, 7 - histogram with color and multiple files\n";
}

my %h = ();
#my @infile = ();
my $result = GetOptions(\%h, 'file=s', 'extra=s', 'param=s', 'svg=s', 'type=i', 'title=s', 'ylabel=s', 'xlabel=s', 'zlabel=s', 'caption=s', 'lowx=s', 'highx=s', 'lowy=s', 'highy=s', 'lowz=s', 'highz=s');

$infileList = $h{'file'};
@infile = split (/\s+/, $infileList);
$extraFunctionsFile = $h{'extra'};
$outfile_param = $h{'param'};
$outfile_png = $h{'svg'};
$plot_type = $h{'type'};
$title = $h{'title'};
$ylabel = $h{'ylabel'};
$xlabel = $h{'xlabel'};
$caption = $h{'caption'};
$lowX = $h{'lowx'};
$highX = $h{'highx'};
$lowY = $h{'lowy'};
$highY = $h{'highy'};
if($plot_type == 2 or $plot_type == 6){
    $zlabel = $h{'zlabel'};
    $lowZ = $h{'lowz'};
    $highZ = $h{'highz'};
}
$lineWidthSize=1.5;

my $gnuplotVersion = getGnuplotVersion();
print "Gnuplot version: $gnuplotVersion\n";

open (OUT, ">$outfile_param") || die "Unable to open plot parameter file: $outfile_param for output.\n";

#if we're passing a range to gnuplot that has spaces, it needs to be quoted
for my $i (\$lowX, \$highX, \$lowY, \$highY, \$lowZ, \$highZ){
    print $i, "\n";
    if($$i =~ / /){
    	print $$i, "\n";
    	$$i = "\"".$$i."\"" if($$i ne "");
    }
}

#Option Notes:
#size sets relative ratios of x and y axis's
#zlabel ' ' 4 means to move the text 4 chars to the right
#label 2 center refers to previous label set as number 2
#nokey - don't display names of datasets on graph
@options = ("set terminal svg size 700 700 dynamic fname \"Helvetica\" fsize 14 enhanced",
#@options = ("set terminal png",
	"set output '$outfile_png'",
	"set size 1,1", #size of the picture
	"set nokey",
	"set ticslevel 0",
	"set title \"$title\" font \"Helvetica-Bold,26\"",
	"set ylabel \"$ylabel\"",
	"set xlabel \"$xlabel\"",
	"set xrange [$lowX:$highX]",
	"set yrange [$lowY:$highY]");
		
#print "Lowx is $lowX, and HighX is $highX\n";
#see http://t16web.lanl.gov/Kawano/gnuplot/intro/style-e.html for information on plot types
if($plot_type == 0){	#Histogram
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95 right";
	#push @options, "plot '$infile[0]' using 1:2:(sqrt(\$2)) with yerrorbars lw $lineWidthSize, '$infile[0]' using 1:2 with histeps lw $lineWidthSize";
	push @options, "plot '$infile[0]' using 1:2:(sqrt(\$2)) with yerrorbars lw $lineWidthSize, '$infile[0]' using 1:2 with histeps lw $lineWidthSize";
}
elsif($plot_type == 1){	#Line
    #splice(@options, 0, 1, "set terminal svg size 700 700 dynamic fname \"Helvetica\" fsize 15 enhanced");
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95 right";
    unshift @options, "set xdata time";     #needs to come before xlabel
    unshift @options, "set timefmt \"%m/%d/%Y %H:%M:%S\"";  #needs to come before xlabel
    &ticLevels();
    push @options, $setTics;

	#Plot Flux error bars by using pre computer error from column 4.(bz343)
	push @options, "plot '$infile[0]' using 1:3 with points lw $lineWidthSize pt 1, '$infile[0]' using 1:3:4 with yerrorbars";

}
elsif($plot_type == 2){	#3D
    push @options, "set grid";
    push @options, "set zrange [$lowZ:$highZ]";
    push @options, "set zlabel \"$zlabel\" font \"Helvetica,14\"";
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95,.95 right";
    
	&extraFunctions();
    push @options, "splot '$infile[0]' using 1:2:3 with points pt 13, '$infile[0]' using 1:2:3 w i lw $lineWidthSize $functionString";
}
elsif($plot_type == 3) { # lifetime fit
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.90 right";
	&extraFunctions();
    push @options, "plot '$infile[0]' using 1:2 with points, '$infile[0]' using 1:2:(sqrt(\$2)) with yerrorbars lw $lineWidthSize $functionString";
}
elsif($plot_type == 4){	#Scatter plot
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95 right";
	push @options, "plot '$infile[0]' using 1:2";
}
elsif($plot_type == 5) { # TEST
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95 right";
    push @options, "set label 2 \"y=a*e^(-(1/lifetime)*x)\" at graph .95,.85 right\n";
	&extraFunctions();
    push @options, "plot '$infile[0]' using 1:2 with points, '$infile[0]' using 1:2:(sqrt(\$2)) with yerrorbars $functionString" ;
}
elsif($plot_type == 6){ # 3D plot without the lines
    push @options, "set grid";
    push @options, "set zrange [$lowZ:$highZ]";
    push @options, "set zlabel \"$zlabel\" font \"Helvetica,14\"";
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95,.95 right";
    &extraFunctions();
    push @options, "splot '$infile[0]' using 1:2:3 with points ps 2 pt 11";
}
elsif($plot_type == 7){ # Hist w/ color (used for performance study)
    push @options, "set label \"$caption\" font \"Helvetica,14\" at graph .95,.95 right";
    &chanFunctions();
    if($validChan1 == 1){ # need to keep all of the functions you want to plot on the same line; if it's on multiple lines, it will overwrite itself and only the last line will be displayed
        $plot = "plot '$chan1' using 1:2:(sqrt(\$2)) notitle with yerrorbars ls 1, '$chan1' using 1:2 title 'Channel 1' with histeps ls 1, ";
    }
    if($validChan2 == 1){
        if(!defined($plot)){
            $plot = "plot ";
        }
        $plot .= "'$chan2' using 1:2:(sqrt(\$2)) notitle with yerrorbars ls 2, '$chan2'  using 1:2 title 'Channel 2' with histeps ls 2, ";
    }
    if($validChan3 == 1){
        if(!defined($plot)){
            $plot = "plot ";
        }
        $plot .= "'$chan3' using 1:2:(sqrt(\$2)) notitle with yerrorbars ls 3, '$chan3' using 1:2 title 'Channel 3' with histeps ls 3, ";
    }
    if($validChan4 == 1){
        if(!defined($plot)){
            $plot = "plot ";
        }
        $plot .= "'$chan4' using 1:2:(sqrt(\$2)) notitle with yerrorbars ls 4, '$chan4' using 1:2 title 'Channel 4' with histeps ls 4, ";
    }
    chop($plot);
    chop($plot); # in order to take off the ", " on the last entry (gnuplot expects another function if it's left in)
    push @options, $plot;
    @label = split(/\\n/, $caption);
    $y = .95 - (($#label + 1)*.035); # sets the key placement to be dynamic based on how many lines the caption is
    splice(@options, 3, 1, "set key at graph .88,$y");
}
else{
	die "Must choose a plot type (0, 1, 2, 3, 4, 5, 6, or 7)\n";
}

#plot any extra functions
sub extraFunctions(){
	if(-r $extraFunctionsFile){
		#If only two other things have been plotted, the colors wouldn't repeat
		$color=3;
		$labelHeight=.95;
		open(FUNCS, "$extraFunctionsFile");
		$functionString = "";
		while(<FUNCS>){
			if(/^Function:\s(.*)/){
				$functionString .= ", $1 lt $color lw $lineWidthSize";
			}
			elsif(/^Label:\s(.*)/){
				if($plot_type==2){
					push @options, "set label $color \"$1\" at graph 0.99,.95,$labelHeight right tc lt $color";
				}
				else{
					push @options, "set label $color \"$1\" at graph .95,$labelHeight right textcolor lt $color";
				}
				$color++;
				$labelHeight-=.04
			}
		}
	}
	else{
		die "Cannot read the extra functions file $extraFunctionsFile" if($extraFunctionsFile);
	}
}

sub chanFunctions(){ # this is used for the performance study to set the different channel colors
    $validChan1 = 0;
    $validChan2 = 0;
    $validChan3 = 0;
    $validChan4 = 0;
    
    for($i = 1; $i <= 4; $i++){
        push @options, "set style line $i lt $i lw $lineWidthSize";
    }
        
    for $i (@infile){
        open(IN, "$i");
        while(<IN>){
            @row = split(/\s+/, $_);
            $numChan = $row[2];
            if($numChan == 1){
                $chan1 = $i;
                $validChan1 = 1;
            }
            if($numChan == 2){
                $chan2 = $i;
                $validChan2 = 1;
            }
            if($numChan == 3){
                $chan3 = $i;
                $validChan3 = 1;
            }
            if($numChan == 4){
                $chan4 = $i;
                $validChan4 = 1;
            }
        }
    }
}

sub ticLevels(){ # this is used for the flux study to find out where the tic marks should be and set them
    use Time::Local;

    # define all of the variables here to make it easier to read
    @timeDateLow = split(/\s+/, $lowX);
    @timeDateHigh = split(/\s+/, $highX);
    @dateLow = split(/\//, $timeDateLow[0]);
    @dateHigh = split(/\//, $timeDateHigh[0]);
    @timeLow = split(/:/, $timeDateLow[1]);
    @timeHigh = split(/:/, $timeDateHigh[1]);
    $hourLow = $timeLow[0];
    $minuteLow = $timeLow[1];
    $secondLow = substr($timeLow[2], 0, 2); # the quotation marks are appended to the beginning of the date and end of the second from the input
    $monthLow = substr($dateLow[0], 1) - 1; ## we need to take them out or it messes up timegm
    $dayLow = $dateLow[1];
    $yearLow = $dateLow[2];
    $hourHigh = $timeHigh[0];
    $minuteHigh = $timeHigh[1];
    $secondHigh = substr($timeHigh[2], 0, 2);
    $monthHigh = substr($dateHigh[0], 1) - 1;
    $dayHigh = $dateHigh[1];
    $yearHigh = $dateHigh[2];
    $totalSecondsLow = timegm($secondLow, $minuteLow, $hourLow, $dayLow, $monthLow, $yearLow);
    $totalSecondsHigh = timegm($secondHigh, $minuteHigh, $hourHigh, $dayHigh, $monthHigh, $yearHigh);
    $numTics = 11; # this is an arbitrary number of tics that we thought would be good to use based on how much room the x-axis has for tic labels
    $totalSeconds = $totalSecondsHigh - $totalSecondsLow;

    # figure out which interval to use and set up the iteration parameters for finding the first tic
    if($totalSeconds < 30*60*$numTics){ # tic intervals set to 30 minutes
        $interval = 30*60;
        $secondLow = 0;
        $minuteLow = 0;
        $xlabel = "Time UTC (hours:minutes)"; # hard code it here and hope people can find it if they want to change it
    }
    elsif($totalSeconds < 1*60*60*$numTics){ # tic intervals set to  60  minutes/1 hour
        $interval = 60*60;
        $secondLow= 0;
        $minuteLow = 0;
    }
    elsif($totalSeconds < 3*60*60*$numTics){ # tic intervals set to 3 hours
        $interval = 3*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
    }
    elsif($totalSeconds < 6*60*60*$numTics){ # tic intervals set to 6 hours
        $interval = 6*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
    }
    elsif($totalSeconds < 12*60*60*$numTics){ # tic intervals set to 12 hours
        $interval = 12*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
    }
    elsif($totalSeconds < 1*24*60*60*$numTics){ # tic intervals set to 24 hours/1 day
        $interval = 24*60*60;
        $secondLow  = 0;
        $minuteLow =  0;
        $hourLow = 0;
    }
    elsif($totalSeconds < 3*24*60*60*$numTics){ # tic intervals set to 3 days
        $interval = 3*24*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
    }
    elsif($totalSeconds < 1*7*24*60*60*$numTics){ # tic intervals set to 7 days/1 week
        $interval = 7*24*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
    }
    elsif($totalSeconds < 2*7*24*60*60*$numTics){ # tic intervals set to 2 weeks
        $interval = 2*7*20*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
    }
    elsif($totalSeconds < 1*4*7*24*60*60*$numTics){ # tic intervals set to 4 weeks/1 month
        $interval = 4*7*24*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
    }
    elsif($totalSeconds < 3*4*7*24*60*60*$numTics){ # tic intervals set to 3 months
        $interval = 3*4*7*24*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
        $monthLow = 0;
    }
    elsif($totalSeconds < 6*4*7*24*60*60*$numTics){ # tic intervals set to 6 months
        $interval = 6*4*7*24*60*60;
        $secondLow = 0;
        $minuteLow = 0;
        $hourLow = 0;
        $dayLow = 1;
        $monthLow = 0;
    }
    else { # tic intervals set to one year 
        $interval = 365*24*60*60;
        $secondLow = 0; 
        $minuteLow = 0;
        $hourLow = 0; 
        $dayLow = 1; 
        $monthLow = 0; 
    }
    
    # stop here, since 10 tics at 6 months each is 5 years of data, and we don't need to worry about more data than that for a while

    # start at the designated time and iterate through all of the tic marks find the last tic mark before the data starts
    $firstTic = timegm($secondLow, $minuteLow, $hourLow, $dayLow, $monthLow, $yearLow);
    while($firstTic + $interval < $totalSecondsLow){ # this will continue to iterate and exit the loop with the tic mark we want
        $firstTic += $interval;
    }


    # set up the tics so we know where they are, and we can find the middle one of the day and add the date to it
    while($firstTic < $totalSecondsHigh + $interval){
        @temp = gmtime($firstTic);
        $currSecond = $temp[0];
        $currMinute = $temp[1];
        $currHour = $temp[2];
        $currDay = $temp[3];
        $currMonth = $temp[4] + 1; # gmtime's month scale is 0-11, not 1-12
        $currYear = $temp[5] + 1900; # gmtime gives the year since 1900, not since 0
        
        if((($currDay != $lastDay) or ($currMonth != $lastMonth) or ($currYear != $lastYear)) and ($lastDay != "")){ # checking to see if the date has changed
            $ticToChange = int($#tempLabel/2); # finds the middle most tic of each date and adds the date to the label
            $ticToChange += 1 if(($tempLabel[$ticToChange] == "0") and ($#tempLabel > 0)); # for the 12 hour increments, we want the date on the 12 instead of the 0
            $tempLabel[$ticToChange] .= "\\n$lastMonth/$lastDay";
            foreach $j (@tempLabel){
                push @label, $j;
            }
            @tempLabel = ();
        }
        
        $newLowX = "$currMonth/$currDay/$currYear $currHour:$currMinute" unless(defined($newLowX));
        
        if($interval == 30*60){ # only use seconds in the label if the intervals are less than an hour
            $currMinute = "00" if($currMinute == 0); # a time like 7:0 looks goofy
            push @tempLabel, "$currHour:$currMinute";
        }
        else {
            push @tempLabel, "$currHour";
        }
        
        push @time, "$currMonth/$currDay/$currYear $currHour:$currMinute:$currSecond";
        $firstTic += $interval;
        $lastHour = $currHour;
        $lastDay = $currDay;
        $lastMonth = $currMonth;
        $lastYear = $currYear;
    }
    $ticToChange = int($#tempLabel/2); # to get the last day of data onto the array
    $tempLabel[$ticToChange] .= "\\n$lastMonth/$lastDay";
    foreach $j (@tempLabel){
        push @label, $j;
    }
    $newHighX = "$currMonth/$currDay/$currYear $currHour:$currMinute";
    splice(@options, 10, 1, "set xrange [\"$newLowX\":\"$newHighX\"]"); # we need to adjust the xrange of the data so all the tics will show up
    
    # here's where we actually pass the tics we set up into the format that gnuplot uses
    $setTics = "set xtics(";
    for($n = 0; $n <= $#time; $n++){
        $setTics .= "\"$label[$n]\" \"$time[$n]\", ";
    }
    
    chop($setTics);
    chop($setTics);
    $setTics .= ")";
    if ($gnuplotVersion eq "4.0") {
    	splice(@options, 9, 1, "set xlabel \"$xlabel\" ,-1"); # make room for the second row on the tic labels
    }
    else {
    	splice(@options, 9, 1, "set xlabel \"$xlabel\" offset 0,-1"); # make room for the second row on the tic labels
    }
}

foreach $opt (@options){
	print OUT "$opt\n";
}

sub getGnuplotVersion() {
	my $versionString = `gnuplot --version`;
	my @varray = split(/\s+/, $versionString);
	if (not defined @varray[1]) {
		die "Could not get gnuplot version. Tried to parse '$versionString'\n";
	}
	else {
		return $varray[1];
	}
}

`gnuplot $outfile_param`;

die "Error: the plot image is a zero length file.\n" if(-z $outfile_png);
