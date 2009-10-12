<%
use CGI; 
use DBI;
use DBDefs;

# Get the basic data for connecting to the local database
my $dbdefs = new DBDefs();

my $host = $dbdefs->getHost();
my $dbtype = $dbdefs->getType();
my $db = $dbdefs->getDB();
my $user = $dbdefs->getUser();

my $table  = "settings";
my $dbh;

my $query;
my $data;

my $response = "";

my $cgi       = new CGI();
my $sessionID = $cgi->param('sessionID')  || die "Unable to find a session ID";
my $page      = $cgi->param('page')       || "data";

$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";

$query = "select userLevel from $table where sID='$sessionID'";
$data = $dbh->prepare($query);
$data->execute();
my ($userLevel) = $data->fetchrow_array();
$data->finish();

$query = "select dataSet from $table where sID='$sessionID'";
$data = $dbh->prepare($query);
$data->execute();
my ($dataset) = $data->fetchrow_array();
$data->finish();

my @lines = `php ../php/$page.php userLevel=$userLevel dataset=$dataset`;

$response = "$page\n";
for ( my $i=2; $i<$#lines-2; $i++ ) {
    $response .= $lines[$i];
}

$Response->Write($response);
%>
