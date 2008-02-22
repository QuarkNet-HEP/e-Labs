#!/usr/bin/perl

#
#
# Re-calculates the CPLD frequency for a file.
# VDS must be properly set and its bin dir must be in the path
# for this to work.
#
#

if($#ARGV < 1) {
	die "usage: CPLDReCalc.pl [LFN] [data DIRECTORY] [-update]\n";
}

$lfn = shift;
$dir = shift;
$update = shift;

if ($lfn =~ m/(\d+)\./) {
	$bid = $1;
}
else {
	die "Failed to get board id from file name";
}

print "Board id: $bid\n";

$vdcfreq = `showmeta -f $lfn dummy|grep cpldfrequency`;

if ($vdcfreq =~ m/\w+\s+\w+\s+([\w\.\-]+)/) {
	$vdcfreq = $1 + 0; #I'm guessing this is a reasonable way to force conversion to numeric
}
else {
	$vdcfreq = "none";
	print "Warning: no cpldfrequency found in the VDC for $lfn\n";
}

print "CPLD frequency from VDC: $vdcfreq\n";

$out=`./CPLDCalc.pl "$dir/$bid/$lfn"`;

if ($out =~ m/average frequency is: ([\d\.]+)/) {
	$freq = $1;
}
else {
	die "Invalid output from CPLDCalc.pl: $out\n";
}

if ($out =~ m/standard deviation: ([\d\.]+)/) {
	$stddev = $1;
}
else {
	die "Failed to get standard deviation from CPLDCalc output\n";
}

if ($stddev > 1000000) {
	print "Suspiciously large standard deviation detected: $stddev\n";
}

print "Calculated frequency:    $freq\n";

if ($update eq "-update") {
	#there's a bug in the way the VDS tools process their command line
	#arguments. Hence the two "cpldfrequency"es
	if ($vdcfreq ne "none") {
		print "Deleting old cpldfrequency... ";
		system("deletemeta",  "-f", $lfn, "cpldfrequency", "cpldfrequency");
		print "\n";
	}
	
	$tmp = `mktemp`;
	
	$tmp =~ s/\s+$//;
	
	open(META, ">$tmp");
	print META "cpldfrequency float $freq\n";
	close(META);
	
	print "Inserting new cpldfrequency... ";
	system("insertmeta", "-f", $lfn, $tmp);
	print "\n";
	unlink($tmp);
}