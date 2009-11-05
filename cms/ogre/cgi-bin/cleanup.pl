#!/usr/bin/perl

use strict;
use warnings;
use MySQL;
use ogreXML;
use archive;

use File::Path;
use Data::Dumper;

my $db  = new MySQL();
my $xml = new ogreXML();

######################### Stuff that might need modification ##############
use lib qw(/home/ogre/public_html/cgi-bin);

### Access times are used to check if files/DB records should be deleted
### or archived. Times are in days (i.e. 1 => 1 day, 0.25 => 6 hours, etc)
my $guestTime = 0.0125;   # Access time after which guest records are deleted
my $userTime  = 7;        # Access time after which user records are archived
my $archTime  = 180;      # Access time after which user archives/records are deleted

my $verbose = 0;          # Debugging switch for print statements and such
###########################################################################

# Find out where the tmp & archive directories are...
my $tmpDir     = $xml->getOgreParam('tmpDir');
my $archDir    = $xml->getOgreParam('archiveDir');
my $resultsDir = $xml->getOgreParam('resultsDir');

# Build a DB query for the data we need
my $query = "select sID,username from settings";
my %dbHash = $db->processDBQuery($query);

# Parse the return (a hash of arrays keyed on the first field)
for my $sID (keys %dbHash) {
    my @results = @{$dbHash{$sID}};
    my $user = $dbHash{$sID}[0];
    
    if ( !$user ) {
	$user = "guest";
    }

    if ( $verbose ) {
	print "Checking session $sID for user $user\n";
	if ( -d "$tmpDir/$sID" ) {
	    print -A "$tmpDir/$sID", "\n";
	}
    }

    # Now we have the user and the session ID...
    # Start doing the cleanup routines....
    if ( $user eq "guest" ) {
	if ( $verbose ) {
	    print "Cleaning up $user $sID\n";
	}

	# If we have a guest user... whack the tmp directory
	if ( -d "$tmpDir/$sID" && -A "$tmpDir/$sID" > $guestTime ) {
	    my $dir = Cwd::getcwd();

	    chdir("$tmpDir") || warn "Unable to chdir($tmpDir): $!\n";
	    rmtree($sID) || warn "Unable to rmtree($sID): $!\n";;
	    chdir($dir) || warn "Unable to chdir: $!";

	    # And any archives they created along the way
	    if ( -e "$archDir/study-$sID.tar.gz" ) {
		unlink("$archDir/study-$sID.tar.gz");
		unlink("$archDir/canvas-$sID.*");
	    }
	    if ( -e "$resultsDir/study-$sID.tar.gz" ) {
		unlink("$resultsDir/study-$sID.tar.gz");
		unlink("$resultsDir/canvas-$sID.*");
	    }

	    # And delete the DB entry
	    $query = "delete from settings where sID='$sID'";
	    $db->processDBQuery($query);

	}
	next;
    }  # Done handling guest accounts.... 



    # Check if this study is in the tmp directory
    if ( -d "$tmpDir/$sID" && -A "$tmpDir/$sID" > $userTime ) {

	if ( $verbose ) {
	    print "Archiving study $sID for $user\n";
	}

	# Archive the study....
	my $arch = new archive("$sID",0,'png',1,0);
	$arch->archiveStudy();

	# And remove the study directory
	my $dir = Cwd::getcwd();
	chdir($tmpDir) || warn "Unable to chdir($tmpDir): $!\n";
	rmtree($sID) || warn "Unable to rmtree($sID): $!\n";
	chdir($dir) || warn "Unable to chdir: $!";

	undef $arch;

	next;
    }

    # Check the archives and see if any are left laying about
    if ( -e "$archDir/study-$sID.tar.gz" && -A "$archDir/study-$sID.tar.gz" > $archTime ) {
	if ( $verbose ) {
	    print "Found old archive $sID\n";
	}
	unlink("$archDir/study-$sID.tar.gz");
	unlink("$archDir/canvas-$sID.*");

	$query = "delete from settings where sID='$sID'";
	$db->processDBQuery($query);

	next;
    }

    # Check for orphaned records in the DB
    if ( ! (-d "$tmpDir/$sID") && ! (-e "$archDir/study-$sID.tar.gz") ) {
	if ( $verbose ) {
	    print "Found orphaned record for $user $sID\n";
	}
	$query = "delete from settings where sID='$sID'";
	$db->processDBQuery($query);
    }
}

# Now flip the process... look for orphaned directories in tmpDir
opendir(DIR,"$tmpDir");
my @tmpFiles = readdir(DIR);
closedir(DIR);

foreach my $dir (@tmpFiles) {

    if ( $dir eq "." || $dir eq ".." || $dir eq ".svn" ) {
	next;
    }

    $query = "select sID,username from settings where sID='$dir'";
    %dbHash = $db->processDBQuery($query);

    if ( !keys(%dbHash) ) {
	if ( $verbose ) {
	    print "Found orphan $dir\n";
	}
	my $thisDir = Cwd::getcwd();
	chdir ( $tmpDir ) || warn "Unable to chdir($tmpDir): $!\n";
	rmtree( $dir ) || warn "Unable to rmtree( $dir ): $!\n";
	chdir ( $thisDir ) || warn "Unable to chdir( $thisDir ): $!\n";
    }
}

undef $db;
undef $xml;

exit 0;
