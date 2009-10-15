<%
use DBI;
use CGI;
use lib "../cgi-bin";
use DBDefs;

$Response->{expires} = -1;

# Get the basic data for connecting to the local database
my $dbdefs = new DBDefs();

my $host = $dbdefs->getHost();
my $dbtype = $dbdefs->getType();
my $db = $dbdefs->getDB();
my $user = $dbdefs->getUser();

my $table  = "bootstrap";
my $dbh;

my $query = "select xmlURL from $table";
$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";
my $data = $dbh->prepare($query);
$data->execute();

$Response->Write( ($data->fetchrow_array) );
%>
