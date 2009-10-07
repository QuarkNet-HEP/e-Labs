<%
use lib "../cgi-bin";
use archive;
use CGI;

$Response->{expires} = -1;

my $cgi  = new CGI();
my $dir  = $cgi->param('directory');
my $prev = $cgi->param('version');
my $type = $cgi->param('type');
my $ovr  = $cgi->param('overwrite');
my $fin  = $cgi->param('finalize');

my $save = new archive($dir, $prev, $type, $ovr, $fin);
my $retVal = $save->archiveStudy();

if ( $retVal == 0 ) {
   $Response->Write("Study saved");
} elsif ( $retVal == 1 ) {
   $Response->Write("Unable to find any files to archive in $dir");
} elsif ( $retVal == 2 ) {
  $Response->Write("Unable to create an archive");
} elsif ( $retVal == 3 ) {
  $Response->Write("Unable to copy current canvas $prev to the archives");
}

%>
