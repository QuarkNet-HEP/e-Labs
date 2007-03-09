#!/usr/bin/perl
#Grabs only the data (output from ThresholdTimes.pl) from the specified channel and writes the output to a file
#
#Written by Paul Nepywoda, FNAL on 1-13-04
#Assume: system has 'grep' and 'echo' in $PATH for executables (standard on UNIX systems)
# nepywoda 7-13-04: argument tests and correct warning/error output

use Getopt::Long;
if($#ARGV < 2){
	die "usage: SingleChannel.pl -in [input-file] -out [output-file1] -out [output-file2 etc.] -chan [channel-#1] -chan [channel-#2 etc.]\n";
}
my %h = ();
my $result = GetOptions(\%h, 'in=s', 'out=s@', 'chan=s@');

use Digest::MD5 qw(md5_hex);

#Set the command line arguments
$infile = $h{'in'};
@ofile = @{$h{'out'}};
@chan = @{$h{'chan'}};

#md5 input/output file comparison
my $arg_str = join " ", @ARGV[0..$#ARGV];
my $mtime1 = (stat($0))[9];         #this script's timestamp
my $mtime2 = (stat($infile))[9];    #input file's timestamp
$arg_str = "$mtime1 $mtime2 $arg_str $mtime3";
my $md5 = md5_hex($arg_str);
if(-e $ofile){
    $outmd5 = `head -n 1 $ofile`;
    $outmd5 = substr($outmd5, 1);
    chomp $outmd5;
    print "md5s COMPUTED:$md5 FROMFILE:$outmd5\n";
    if($md5 eq $outmd5){
        print "input argument md5's match, not re-calculating output file: $ofile\n";
        exit;
    }
}

##PERFORMANCE:
# It is actualy ~20% faster to call grep from the shell than use perl's internal m// iterating over the file
#FIXME: that is...unless grep is *broken* on the machine(evitable)....so weird!
#`grep -E '^[0-9]{1,4}\\.$chan' $infile >> $ofile`;
for ($i = 0; $i <= $#chan; $i++){
`echo "#$md5" > $ofile[$i]`;
`echo "#md5_hex($arg_str)" >> $ofile[$i]`;
`echo "#ThresholdTimes for only channel $chan[$i]" >> $ofile[$i]`;
`perl -n -e 'if(/^[0-9]{1,4}\\.$chan[$i]/){ print}' $infile >> $ofile[$i]`;
die "No data for channel $chan[$i] found anywhere in the file $infile!\n" if($?/256 == 1);
}
