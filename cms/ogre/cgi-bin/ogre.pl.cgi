#!/usr/bin/perl
use strict;
use warnings;

#
#############################################################################
# Start main here                                                           #
#############################################################################
#
### Define the namespace of this routine
#
package ogre;

#
### Include the modules holding the main routines
#
require ogreXML;
require cgi;
use MySQL;
require root;

#
### First, process our XML file ogre.xml (class defined in ogreXML.pm)
#

# Create a global instance of ogreXML
$ogre::ogreXML = new ogreXML();

#
### Get the CGI Query (class defined in cgi.pm)
#

# Create a global instance of the cgi class
$ogre::cgi = new cgi();

# And process the CGI query we've just recieved
# if there's no CGI query, it's a command line run
# the CGI class includes a cmdLine class from 
# cmdLine.pm and it will process the command 
# line as though it were a CGI query
$ogre::cgi->procCGI();

#
# Process the MySQL query passed in on the CGI/CMD Line request
#
my $metaData = $ogre::ogreXML->getOgreParam('MetaDataSource');
if (  lc($metaData) eq "mysql" ) {

  # Create a global instance of the MySQL class
  $ogre::MySQL = new MySQL();
  
  # Build and process the MySQL DB query
  $ogre::MySQL->procDBRequest();
}

#
### Next, process the data XML file based on command line arguments
#
$ogre::ogreXML->procXML();

#
### Build and run the root script (class defined in root.pm)
#

# Create a gloabl instance of the root class
$ogre::root = new root();

# Build & process the root script
$ogre::root->makeRootScript();

# Once root is done we're done.
# The output of the makeRootScript call is a 
# temp directory (based on a random number thrown in cgi())
# and located in tmpDir from ogre.xml. All further
# processing happens from the output web page and calls
# to applyLinearCut.pl.cgi


#
### Clean up and exit gracefully
#

exit 0;
