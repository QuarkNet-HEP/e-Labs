<%

use DBI;
use CGI;

# Basic data for connecting to the local database
my $host   = "localhost";
my $dbtype = "mysql";
my $db     = "ogredb";
my $user   = "ogre";
my $dbh;

my $cgi = new CGI();
my $sessionID = $cgi->param('sessionID') || die "Unable to read session ID!";

my $query = "select selection from settings where sID='$sessionID'";

$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";

my $data = $dbh->prepare($query);
$data->execute();

my ($selection) = $data->fetchrow_array();
$data->finish();

if ( $selection && $selection ne "blah" ) {
   $Response->Write($selection);
} else {
  $Response->Write("null");
}

%>
