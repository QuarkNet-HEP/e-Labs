#!/usr/bin/perl -w 
# Written by Paul Nepywoda, FNAL 1-15-04
#
# Takes a datafile from the web and puts it into a directory. Also calls split.pl
  
use CGI; 
  
$upload_dir = "/Users/paul/Sites/scratch/upload"; 
  
$query = new CGI; 
  
$filename = $query->param("file"); 
$loc = $query->param("loc");
$filename =~ s/.*[\/\\](.*)/$1/;	#strip off path into (in case of absolute paths)
$upload_filehandle = $query->upload("file"); 
 

open UPLOADFILE, ">$upload_dir/$filename";
binmode UPLOADFILE;

while ( <$upload_filehandle> ) 
{ 
	print UPLOADFILE;
}

close UPLOADFILE;

`perl split.pl $upload_die/$filename`;


print $query->header; 
print <<BLOCK; 

<HTML> 
<HEAD> 
<TITLE>WEEEEE!</TITLE> 
</HEAD> 

<BODY> 

<P>WOW, you just uploaded a file!</P> 
<P>Your Location Variable: $loc;</P>

BLOCK

print "</BODY></HTML>"; 
