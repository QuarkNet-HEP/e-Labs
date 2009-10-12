<%
use DBI;
use CGI;

$Response->{expires} = -1;

# Basic data for connecting to the local database
my $host   = "localhost";
my $dbtype = "mysql";
my $db     = "ogredb";
my $user   = "ogre";
my $table  = "bootstrap";

my $dbh;

my $query = "select xmlURL from $table";
$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";
my $data = $dbh->prepare($query);
$data->execute();

$Response->Write( ($data->fetchrow_array) );
%>
