<%

use CGI;
my $cgi= new CGI();
my $sessionID = $cgi->param('sessionID')  || die "Unable to find a session ID";
my $iotype = $cgi->param('iotype');

if ( $iotype eq "study" ) {
   if ( -d "tmp/$sessionID/" ) {
     $Response->Write(1);
   } else {
     $Response->Write(0);
   }
} elsif ( $iotype eq "archive" ) {
  if ( -e "archives/study-$sessionID.tar.gz" ) {
    $Response->Write(1);
  } else {
    $Response->Write(0);
  }
}

%>
