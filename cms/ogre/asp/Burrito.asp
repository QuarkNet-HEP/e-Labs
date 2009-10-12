<%

use DBI;
use CGI;
use DBDefs;

my $dbdefs = new DBDefs();

my $i;
my $host = $dbdefs->getHost();
my $dbtype = $dbdefs->getType();
my $db = $dbdefs->getDB();
my $user = $dbdefs->getUser();
my $dbh;
my $cgi = new CGI();
my $query;
my $data;
my $sessId = $cgi->param('sessid');

my %mysql_data = ();
my $Nacho;

$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";

if ($cgi->param('iotype') eq "retrieve")
{
	$query = "SELECT * FROM settings WHERE sID = '$sessId';";
	$data = $dbh->prepare($query);
	$data->execute();
	my @row = $data->fetchrow_array();
	$Nacho = $row[1];
	for ($i = 2; $i < 16; $i++)
	{
		$Nacho = join ":", $Nacho, $row[$i];
	}
	$Response->Write ($Nacho);
}

if ($cgi->param('iotype') eq "getUser") {
   $query = "SELECT userName FROM settings WHERE sID = '$sessId';";
   $data = $dbh->prepare($query);
   $data->execute();
   ($Nacho) = $data->fetchrow_array();
   $Response->Write ($Nacho);
}

if ($cgi->param('iotype') eq "getID") {
   @row = @{$dbh->selectcol_arrayref("SELECT sID FROM settings WHERE username = '$sessId';")};
   $Nacho = @row;
   for ($i = 0; $i < $Nacho; $i++) {
       $Nacho = join ":", $Nacho, $row[$i];
   }
   $Response->Write ($Nacho);
}

if ($cgi->param('iotype') eq "create")
{
	my $userName = $cgi->param('userName') || 'default';
	$query = "INSERT INTO settings VALUES ('$userName','$sessId', 0, 'mc09', 12, 1, 1, 0, 10, 10, 20, 20, 30, 30, 'histWin', 'blah');";
	$data = $dbh->prepare($query);
	$data->execute();
	$Nacho = "$sessId:0:mc09:12:1:1:0:10:10:20:20:30:30:histWin:blah";
	$Response->Write($Nacho);
}

if ($cgi->param('iotype') eq "send")
{
	$query = "UPDATE settings SET ".$cgi->param('parameter')."=".$cgi->param('value')." WHERE sID = '$sessId';";
	$Response->Write($query);
	$data = $dbh->prepare($query);
	$data->execute();
}

%>
