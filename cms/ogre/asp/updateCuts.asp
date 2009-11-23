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
my $sessId = $cgi->param('sessionID');
my $cut = $cgi->param('selection');

my %mysql_data = ();

$dbh = DBI->connect("DBI:$dbtype:$db:$host", "$user")
     or die "Unable to access DB server!: $!";

my @cuts = split(/,/, $cut);
for ( my $i=0; $i<=$#cuts; $i++ ) {
    $query = "update settings set cut$i='$cuts[$i]' where sID='$sessId'";
    $data = $dbh->prepare($query);
    $data->execute();
}

#my @cuts = split(/&&/, $cut);
#my $j = 0;

#for ( my $i=0; $i<=$#cuts; $i++ ) {
#    if ( $cuts[$i] =~ /\:/ ) {
#        my @temp = split(/\:/, $cuts[$i]);
#    	$cuts[$i] = $temp[1];
#    }
#}


#for ( my $i=0; $i<$#cuts; $i+=2 ) {
#    my $thisCut = $cuts[$i]."&&".$cuts[$i+1];

#    $query = "update settings set cut$j='$thisCut' where sID='$sessId'";
#    $data = $dbh->prepare($query);
#    $data->execute();

#    $j++;
#}

%> 
