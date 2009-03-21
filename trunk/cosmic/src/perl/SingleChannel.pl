#!/usr/bin/perl
#Grabs only the data (output from ThresholdTimes.pl) from the specified channel and writes the output to a file
#
#Written by Paul Nepywoda, FNAL on 1-13-04
#Assume: system has 'grep' and 'echo' in $PATH for executables (standard on UNIX systems)
# nepywoda 7-13-04: argument tests and correct warning/error output
# dettman 6/29/05 - changed arguments so it can take multiple channels and output one file for each channel (for Performance Study)

if($#ARGV < 2){
	die "usage: SingleChannel.pl [input file] \"[output file1 output file2 etc.]\" \"[channel #1 channel #2 etc.]\"\n";
}

use Digest::MD5 qw(md5_hex);

#Set the command line arguments
$infile = $ARGV[0];
@ofile = split (/\s+/, $ARGV[1]);
@chan = split (/\s+/, $ARGV[2]);

##PERFORMANCE:
# It is actualy ~20% faster to call grep from the shell than use perl's internal m// iterating over the file
#`echo "#ThresholdTimes for only channel $chan" >> $ofile`;
#FIXME: that is...unless grep is *broken* on the machine(evitable)....so weird!
#`grep -E '^[0-9]{1,4}\\.$chan' $infile >> $ofile`;
for ($i = 0; $i <= $#chan; $i++){
`perl -n -e 'if(/^[0-9]{1,4}\\.$chan[$i]/){ print}' $infile >> $ofile[$i]`;
die "No data for channel $chan[$i] found anywhere in the file $infile!\n" if($?/256 == 1);
}
