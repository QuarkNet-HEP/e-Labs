<%
use CGI;

my $cgi = new CGI();
my $sessionID = $cgi->param('id');

open(HIST, "<../tmp/$sessionID/history.html");
my @history = <HIST>;
close (HIST);
$Response->Write(@history);
%>
