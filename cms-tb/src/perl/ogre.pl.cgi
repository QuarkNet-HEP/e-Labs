#!/usr/bin/perl
use strict;
use warnings;
use Cwd;
#
################################################################################################
# Start main here                                                                              #
################################################################################################


# Get the path to where I'm located
my @temp = split(/\//, $0);
my $path = "";
if ( substr($0,0,1) eq "/" ) {
  $path = "$0";
} else {
  $path=Cwd::cwd();
  $path="$path/$0";
}
$path =~ s/\/$temp[$#temp]//;
$path =~ s/\.$//;
$path =~ s/\/$//;

#
### Include the files holding the main routines
#
require "$path/xml.pl";
require "$path/command_line.pl";
require "$path/mysql.pl";
require "$path/root.pl";
require "$path/cgi.pl";
require "$path/html.pl";
require "$path/save_state.pl";

# Define hash references to the variable containers
my $ogre_hash     = ();
my $cmdl_hash     = ();
my $graphics_hash = ();
my $mysql_hash    = ();

#
### First, process our XML file ogre.xml
#
$ogre_hash = read_ogre_xml($path);                                              # Located in xml.pl

#
### See if this was a CGI POST
#
$cmdl_hash = cgi($ogre_hash->{tmpDir},$ogre_hash->{baseDir});                   # Located in cgi.pl

#
### Second, take the command line and process it if this wasn't a CGI POST
#
if ( !$cmdl_hash ) {
  $cmdl_hash = procCMDLong();                                                   # Located in command_line.pl
}

if ( $cmdl_hash->{DEBUG} ) {
  my $ogre_dump = Dumper($ogre_hash);
  $ogre_dump =~ s/VAR1/ogre_hash/;

  my $cmdl_dump = Dumper($cmdl_hash);
  $cmdl_dump =~ s/VAR1/cmdl_hash/;

  print $ogre_dump, "\n", $cmdl_dump;
}

if (exists($ogre_hash->{MetaDataSource}) && $ogre_hash->{MetaDataSource} eq "MySQL") {
  $mysql_hash = mysql($cmdl_hash);
  if ( $cmdl_hash->{DEBUG} ) {
    my $mysql_dump = Dumper($mysql_hash);
    $mysql_dump =~ s/VAR1/mysql_hash/;
    print $mysql_dump;
  }
}

#
### Next, process the data XML file based on command line arguments
#
$graphics_hash = procXML( $ogre_hash->{xmlDir}, $cmdl_hash, $mysql_hash );      # Located in xml.pl

# Dump the graphics hash if we're running in debug (verbose) mode
if ( $cmdl_hash->{DEBUG} ) {
  my $graphics_dump = Dumper($graphics_hash);
  $graphics_dump =~ s/VAR1/graphics_hash/;

  print $graphics_dump, "\n";
}

#
### Build and run a root script
#
&root( $graphics_hash, $cmdl_hash, $ogre_hash );      # Located in root_script.pl

#
### Once root is done... if & only if we're processing 
### input from a CGI POST request... form up and pop the output
### back to the client browser
#
if ( $cmdl_hash->{isCGI} == 1 ) {
  &html($ogre_hash, $cmdl_hash);
}

#
### Clean up and exit gracefully
#

exit 0;
