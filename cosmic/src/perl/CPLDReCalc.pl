#!/usr/bin/perl

#
#
# Re-calculates the CPLD frequency for a file.
# VDS must be properly set and its bin dir must be in the path
# for this to work.
#
#

#if($#ARGV < 1) {
#	die "usage: CPLDReCalc.pl [LFN] [data DIRECTORY] [-update]\n";
#}

if($#ARGV < 2) {
	die "usage: CPLDReCalc.pl [File with list of LFNs] [data DIRECTORY] [File to log results] [-update]\n";
}

#$lfn = shift;
$infile = shift;
$dir = shift;
$outfile = shift;
$update = shift;

open (IN, $infile);
open (OUT, ">$outfile");

while (<IN>) {

	$lfn = $_;
	chomp $lfn;
	if ($_ =~ m/(\d+)\./) {
	$bid = $1;
	#print $bid, "\n";
}
else {
	die "Failed to get board id from file name";
}

#print "Board id: $bid\n";

$vdcfreq = `showmeta -f $lfn dummy|grep cpldfrequency`;

if ($vdcfreq =~ m/\w+\s+\w+\s+([\w\.\-]+)/) {
	$vdcfreq = $1 + 0; #I'm guessing this is a reasonable way to force conversion to numeric
}
else {
	$vdcfreq = "none";
	# print "Warning: no cpldfrequency found in the VDC for $lfn\n";
}


#print "CPLD frequency from VDC: $vdcfreq\n";

#print "$dir/$bid/$lfn", "\n";
$out=`./CPLDCalc.pl $dir/$bid/$lfn " $bid"`;

if ($out =~ m/average frequency is: ([\d\.]+)/) {
	$freq = $1;
}
else {
	die "Invalid output from CPLDCalc.pl on LFN: $lfn:\n $out \n";
}

if ($out =~ m/standard deviation: ([\d\.]+)/) {
	$stddev = $1;
}
else {
	die "Failed to get standard deviation from CPLDCalc output\n";
}

if ($stddev > 1000000) {
	print "Suspiciously large standard deviation detected: $stddev on LFN: $lfn\n";
}

#print "Calculated frequency:    $freq\n";
#print OUT $freq, "\n"; #write the new frequency to the log
print OUT $lfn, "\t", $vdcfreq, "\t", $freq, "\n";
#print $lfn, "\t", $vdcfreq, "\t", $freq, "\n";

if ($update eq "-update") {	#update the VDC
	#there's a bug in the way the VDS tools process their command line
	#arguments. Hence the two "cpldfrequency"es
	if ($vdcfreq ne "none") {
		#print "Deleting old cpldfrequency... ";
		system("deletemeta",  "-f", $lfn, "cpldfrequency", "cpldfrequency");
		#print "\n";
	}
	
	$tmp = `mktemp`;
	
	$tmp =~ s/\s+$//;
	
	open(META, ">$tmp");
	print META "cpldfrequency float $freq\n";
	close(META);
	
	#print "Inserting new cpldfrequency... ";
	system("insertmeta", "-f", $lfn, $tmp);
	#print "\n";
	unlink($tmp);
	#Write the LFN, old freq and new freq to the log file--this only happens if the VDC has been updated
	
 
}

next; #get the next LFN from infile

}