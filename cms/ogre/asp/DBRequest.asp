<%

use DBI;
use CGI;
use DBDefs;

# Get the basic data for connecting to the local database
my $dbdefs = new DBDefs();

my $host = $dbdefs->getHost();
my $dbtype = $dbdefs->getType();
my $db = $dbdefs->getDB();
my $user = $dbdefs->getUser();
my $dbh;

my $cgi = new CGI();

$Response->{expires} = -1;

my $dataset = $cgi->param('dataset') || "mc09";
my $table;

if ( $dataset eq "tb04" ) {
  $table  = "rundb";
} elsif ( $dataset eq "mc09" ) {
  $table = "mcdb";
} else {
  $table = "mcdb";
}

my $query = "select " . $cgi->param('varlist') . " from $table";
if ( $cgi->param('selection') ) {
    $query .= " where " . $cgi->param('selection');
}

$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";
my %mysql_data = ();

my $string;

my $data = $dbh->prepare($query);
$data->execute();

my $numEvents = 0;

if ( $dataset eq "tb04" ) {
  while ( my (@row) = $data->fetchrow_array() ) {
    $string .= "Run $row[0]: $row[1] events of $row[2] GeV $row[3] at (phi=$row[4], eta=$row[5])\n";
    $numEvents += $row[1];
  }
} elsif ( $dataset eq "mc09" ) {
  while ( my (@row) = $data->fetchrow_array() ) {
    $string .= "Run $row[0]: $row[1] events of simulated $row[2] events\n";
    $numEvents += $row[1];
  }
} else {
  while ( my (@row) = $data->fetchrow_array() ) {
    $string .= "Run $row[0]: $row[1] events of simulated $row[2] events\n";
    $numEvents += $row[1];
  }
}

$string .= "=================================\n";
$string .= "Total: $numEvents events selected\n";

$Response->Write( $string );

%>
