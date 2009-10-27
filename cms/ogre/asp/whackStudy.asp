<%
use lib "../cgi-bin";
use archive;
use CGI;

$Response->{expires} = -1;

my $cgi  = new CGI();
my $dir  = $cgi->param('directory');
my $study  = new archive($dir,0,2,0,0);
$study->deleteStudy();

%>
