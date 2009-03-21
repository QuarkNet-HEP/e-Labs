#!/usr/bin/perl
#Frequency.pl
# Outputs a frequency-analysis for the specified column with given bin width)
#
#	Requires the Statistics::Descriptive module
#
#by Paul Nepywoda, FNAL 5/17/04
# nepywoda 7-14-04: argument tests and correct warning/error output
# ndettman 6/27/05 added a third column to the output that displays the channel number, so I can grab it in Plot.pl when running a Performance Study.  Also changed the arguments so it can take multiple infiles and output an outfile for each infile passed in.

BEGIN {
	$dirname=`dirname $0`;
	chomp($dirname);
	push(@INC, $dirname);
}
use Statistics::Descriptive;

if($#ARGV < 4){
	die "usage: Frequency.pl \"[file to read from1 file to read from2 etc.]\" \"[file to output1 file to output2 etc.]\" [column number of file (start at 1)] [1/0 1:binwidth 0:number of bins] [binwidth or number of bins, depending on what you chose]\n";
}

@infile = split(/\s+/, $ARGV[0]);
@outfile = split(/\s+/, $ARGV[1]);
$col=$ARGV[2]-1;
$binType=$ARGV[3];		#set to 1 if using binwidth, 0 if using numberOfBins
#[Mihael] disabled in the interest of safety
#$binValue=eval $ARGV[4];
$binValue=$ARGV[4];

#@colarray = split /\./, $ARGV[3];
die "Error: column number ($ARGV[2]) must be a positive integer > 1.\n" if($col !~ /^\d+$/);

for($i = 0; $i <= $#infile; $i++){
    open (IN, "$infile[$i]") || die "Cannot open $infile[$i] for input";
    open (OUT, ">$outfile[$i]") || die "Unable to open $outfile[$i] for output";

    @data = ();
    @bins = ();
    %freq = ();

    while(<IN>){
        next if m/\s*#/;
        @row = split /\s+/;

        #$combined_cell = $row[$colarray[0]-1];
        #map { $combined_cell .= "." . $row[$_-1] } @colarray[1..$#colarray];

        push @data, $row[$col] if($row[$col]);
        @IDChan = split(/\./, $row[0]);  # this way of getting the channel is dependent on Single Channel running before Frequency
        $chan = $IDChan[1];
    }
    die "Error: no data found in column $ARGV[2] in file: $infile[$i]\n" if($#data < 0);
    $num_elements = scalar(@data);
    if($num_elements > 1){
        @data = sort {$a <=> $b} @data;
    }

#setup the bins array
    if($binType == 1){
        $step = $binValue;
        die "Please enter a positive number for the bin width.\n" if($step <= 0);
        $data_min = (sprintf "%d", $data[0]/$step)*$step;	#truncate the min to the nearest multiple of $step
        $data_max = (sprintf "%d", $data[$#data]/$step)*$step + $step;	#truncate the max to the nearest multiple of $step
        $numbins = ($data_max - $data_min) / $step;
        die "The computed number of bins ($numbins) exceeds 10,000. Please enter a larger binwidth ($binValue).\n" if($numbins > 10000);
    }
    elsif($binType == 0){
        $numbins = $binValue;
        die "Please enter a positive integer for the number of bins.\n" if($numbins !~ /^[1-9]\d*$/);
        die "The number of bins ($numbins) exceeds 10,000. Please enter a smaller number.\n" if($numbins > 10000);

        $data_min = $data[0];
        $data_max = $data[$#data];
        $step = ($data_max - $data_min)/$numbins;
        die "Error: Only 1 bin of width zero returned. (You have $num_elements elements of value $data_min)\n" if($step == 0);
        print "min max step num bin $data_min $data_max $step |$numbins|$binValue|\n";
    }
    else{
        die "Error: choose either binwidth (1) or number of bins (0).\n";
    }

    for(my $i=$data_min+$step; $i<$data_max+$step; $i=$i+$step){
        push @bins, $i;
    }

    print "numbins: $numbins #bins: $#bins||\n";
    foreach $k(@bins){
        #print "$k|\n";
    }
    foreach $k(@data){
        #print"$k|data\n";
    }

    $freq = Statistics::Descriptive::Full->new();
#$freq->presorted(1);	#doesn't seem to make a difference in performance
    $freq->add_data(@data);


#keys %freq = int($numbins)+1;		#pre-allocate hash structure
# any value of a key from %freq contains the number of elements that are equal to or less than the current key, and greater than the previous key
    %freq = $freq->frequency_distribution(\@bins);

#the key is now the midpoint of each bin: usefull for histogram programs like gnuplot
    for $key (sort { $a <=> $b } keys %freq){
#for $key (keys %freq){
        printf OUT "%f\t%d\t%d\n", $key-($step/2), $freq{$key}, $chan;
    }
    printf "DEBUG: %s %s %s %s\n", $data_min, $data_max, $data[0], $data[$#data];
}
