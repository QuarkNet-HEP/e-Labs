#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use Archive::Tar;
use File::chdir;

my $query = new CGI;
my $sessionID = $query->param('sessionID');
my $path    = "/home/ogre/public_html/";

if ( !$sessionID ) {
  # Start with the header so browsers know it's html
  # But we shouldn't ever get here...
  print "Content-type: text/html\n\n";
  print "<html><body><script>alert('No session to restore');window.history.go(-1);</script></body></html>\n";
  exit 0;
}

# So we have a valid session ID... try and find the archive
if ( -f "$path/archives/study-$sessionID.tar.gz" ) {

  my $archive = "$path/archives/study-$sessionID.tar.gz";
  chdir("$path/tmp");
  my $tar = Archive::Tar->new($archive);
  $tar->extract();
  chdir("-");

} elsif (-f "$path/results/study-$sessionID.tar.gz") {

  my $archive = "$path/results/study-$sessionID.tar.gz";
  chdir("$path/tmp");
  my $tar = Archive::Tar->new($archive);
  $tar->extract();
  chdir("-");


} else {
  # Not found... announce to the user that they've failed.
  # Start with the header so browsers know it's html
  print "Content-type: text/html\n\n";

  print "<html><body><script>alert('No such saved session ID = $sessionID');window.history.go(-1);</script></body></html>\n";
  exit 0;
}

#################### Redirect the results page to the temp file we just created ################

# Get the URL encoded string that was made to produce this run
my $url = $query->self_url;

# Chop off the parameter list
($url) = split(/\?/, $url);

# And reform it to point to the correct tmp directory
$url =~ s/cgi-bin\/restore.pl.cgi/tmp\/$sessionID\/index.html/;

# Start with the header so browsers know it's html
print "Content-type: text/html\n\n";

my $tmpSite = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n";
$tmpSite .= "<html>\n";
$tmpSite .= "<head><meta http-equiv=\"REFRESH\" content=\"0;url=$url\"></head>\n";
$tmpSite .= "</html>\n";
print "$tmpSite";

################################################################################################

exit 0;
