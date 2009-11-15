<%

use DBI;
use CGI;
use lib "../cgi-bin";
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

	# First... see if this user already has defined sessions
	# If so... assign the existing userLevel to the new session
	$query = "select userLevel from settings where userName='$userName' order by userLevel desc";
	$data = $dbh->prepare($query);
	$data->execute();
	my ($userLevel) = $data->fetchrow_array();
	if ( !$userLevel ) {
	  $userLevel = 0;
	}
	$data->finish();

	$query = "INSERT INTO settings VALUES ('$userName','$sessId', $userLevel, 'mc09', 
	  12, 1, 1, 0, 10, 10, 20, 20, 30, 30, 'graphWin', 'blah',1,1,1,1,1,1,1,1,0);";
	$data = $dbh->prepare($query);
	$data->execute();
	$Nacho = "$sessId:$userLevel:mc09:12:1:1:0:10:10:20:20:30:30:histWin:blah";
	$Response->Write($Nacho);
}

if ($cgi->param('iotype') eq "send") {
   if ($cgi->param('parameter') eq "userLevel") {
	$query = "SELECT userName FROM settings WHERE sID = '$sessId'";
	$data = $dbh->prepare($query);
	$data->execute();
	my ($userName) = $data->fetchrow_array();
	
	$query = "UPDATE settings SET ".$cgi->param('parameter')."=".$cgi->param('value')." WHERE userName = '$userName'";
	$Response->Write($query);
	$data = $dbh->prepare($query);
	$data->execute();

} elsif ($cgi->param('parameter') eq "appendCut") {

  # See what the current cut is...
  $query = "select selection from settings where sID='$sessId'";
  $data = $dbh->prepare($query);
  $data->execute();
  my ($selection) = $data->fetchrow_array();
  $data->finish();

  # If it's undefined the just do a replace....
  if ( $selection eq "blah" || $selection eq "1" || !$selection ) {
    $query = "update settings set selection='" . $cgi->param('value') . "' where sID='$sessId'";
  } else { # Otherwise, append it to the current selection
    $query = "update settings set selection=concat(selection,'&&" . $cgi->param('value') . "') where sID='$sessId'";
  }

  $data = $dbh->prepare($query);
  $data->execute();

} elsif ($cgi->param('parameter') eq "replaceCut") {

  $query = "update settings set selection=" . $cgi->param('value') . " where sID='$sessId'";
  $data = $dbh->prepare($query);
  $data->execute();

} elsif ($cgi->param('parameter') eq "selection") {

     # Get the new cuts the user wants...
     my $cuts  = $cgi->param("value");
     
     if ( $cuts =~ m/'/ ) {
       # Remove the ' from the string
       my @temp = split(/'/,$cuts);
       $cuts = $temp[1]; 
     }

     # If we're flushing the cuts... just do it and be done with it
     if ( $cuts eq "blah" ) {
       $query = "UPDATE settings SET selection='' WHERE sID='$sessId'";
       $data = $dbh->prepare($query);
       $data->execute();
       return;
     }

     # And get the name of the variable being cut upon
     my ($var) = split(/>/, $cuts);
     
     $query = "SELECT selection from settings where sID='$sessId'";
     $data = $dbh->prepare($query);
     $data->execute();
     my ($curSel) = $data->fetchrow_array();

     # If this variable exists in the current cuts... replace it with the new ones
     if ( $curSel =~ m/$var/ ) {

       $curSel =~ /.*$var>(.*)&&$var<(.*)/;
       my $upper = $2;
       my $lower = $1;

       if ( $upper =~ m/&&/ ) {
         ($upper) = split /&&/, $upper;
       }

       my $compval = "$var>$lower&&$var<$upper";

       $curSel =~ /.*($compval).*/;
       $newSel = $curSel;
       $newSel =~ s/$1/$cuts/;

       $query = "UPDATE settings SET selection='$newSel' WHERE sID='$sessId'";
       $data = $dbh->prepare($query);
       $data->execute();

     # Otherwise just append it to the current cuts if any
     } elsif (length($curSel) > 0 ) {

       my $newSel = $curSel . "&&" . $cuts;
       $query = "UPDATE settings SET selection='$newSel' WHERE sID='$sessId'";
       $data = $dbh->prepare($query);
       $data->execute();
     } else {

       $query = "UPDATE settings SET selection='$cuts' WHERE sID='$sessId'";
       $data = $dbh->prepare($query);
       $data->execute();

     }

   } else {
	$query = "UPDATE settings SET ".$cgi->param('parameter')."=".$cgi->param('value')." WHERE sID = '$sessId';";
	$Response->Write($query);
	$data = $dbh->prepare($query);
	$data->execute();
   }
}

%>
