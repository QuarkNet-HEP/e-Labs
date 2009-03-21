#!/usr/bin/perl

use Getopt::Long;
use warnings;

if($#ARGV < 2){
	print "usage: $0 -in [input-file1] -in [input-file2 ...] -id [board-ID1] -id [board-ID2 ...] ";
	print "-pre [output filenames prefix] \n";
	exit 1;
}

my %h = ();
my $result = GetOptions(\%h, 'in=s@', 'id=i@', 'pre=s');

#!!change if necessary!!
#$geo_dir = "/usr/local/quarknet-test/portal/cosmic";
$geo_dir = ".";

use constant RUNTIME => eval "use Time::SoFar qw( runinterval )" || !$@;
use File::Basename;

#manualy change these if you wish...
$gatewidth = 1e-5;
$num_bins = 10;

@infile = @{$h{'in'}};
@serialNumber = @{$h{'id'}};
$prefix = $h{'pre'};
#automatic file naming
foreach $k (@infile){
    my $file = basename($k);
	push @thresh_out, "$prefix$file.thresh";        #ThresholdTimes.pl output
	push @wd_in, "$prefix$file.thresh";             #WireDelay.pl input
	push @wd_out, "$prefix$file.thresh.wd";         #WireDelay.pl output
	push @combine, " $prefix$file.thresh.wd";       #Combine.pl input
}

#rest of the derived files will be $prefix.TR1.TR2.TR3...
$combine_out = $prefix.".combine";
$sort_out = $combine_out.".sort";
$lifetime_out = $sort_out.".lifetime";
$freq_out = $lifetime_out.".freq";
$extrafunctions_out = $freq_out.".extra";
$extrafunctions_temp = $extrafunctions_out."__gnuplot";
$plot_param = $extrafunctions_out.".param";
$plot_png = $extrafunctions_out.".png";


#run ThresholdTimes.pl on each input file
while($infile=shift(@infile)){
	$ofile=shift (@thresh_out);
	$serialNumber=shift (@serialNumber);

    $TR = "getopt_ThresholdTimes.pl -in $infile -out $ofile -id $serialNumber";
    print "Running: $TR\n";
    `perl $TR`;
    print "ret: $?\n";
    die "Error!\n" if(($? & 256) or ($? & 512));
    if(RUNTIME){
        my $t = runinterval();
        print "Runtime: $t\n";
    }
}

#run WireDelay.pl on each output file from ThresholdTimes.pl
while($infile=shift(@wd_in)){
	$ofile=shift (@wd_out);
	$serialNumber=shift (@serialNumber);

    $TR = "getopt_WireDelay.pl -in $infile -out $ofile -geo $geo_dir";
    print "Running: $TR\n";
    `perl $TR`;
    print "ret: $?\n";
    die "Error!\n" if(($? & 256) or ($? & 512));
    if(RUNTIME){
        my $t = runinterval();
        print "Runtime: $t\n";
    }
}
$combineTR = "getopt_Combine.pl";
foreach $f (@combine){
    $combineTR .= " -in $f";
}

@TRs = (
"$combineTR -out $combine_out",
"getopt_Sort.pl -in $combine_out -out $sort_out -col1 2 -col2 3",
"getopt_Lifetime.pl -in $sort_out -out $lifetime_out -gate $gatewidth -check 0 -coin 1 -geo .",
"getopt_Frequency.pl -in $lifetime_out -out $freq_out -col 5 -binType 0 -binValue $num_bins",
"getopt_ExtraFunctions.pl -in $freq_out -extra $extrafunctions_out -inter $extrafunctions_temp -type 0 -fit yes",
"getopt_Plot.pl -in $freq_out -extra $extrafunctions_out -param $plot_param -svg $plot_png -type 3"
);

#loop through all TRs and execute
while($TR = shift(@TRs)){
	print "Running: $TR\n";
	`perl $TR`;
	print "ret: $?\n";
    die "Error!\n" if(($? & 256) or ($? & 512));
	if(RUNTIME){
		my $t = runinterval();
		print "Runtime: $t\n";
	}
}
