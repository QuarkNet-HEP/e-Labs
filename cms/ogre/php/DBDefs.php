<?php
// DB connection information
$dbhost = "localhost";
$dbuser = "ogre";
$dbpass = null;
$dbname = "ogredb";

$dbconstfile = "cgi-bin/dbconst.inc";
$counter=0;
while ( !is_file($dbconstfile) && $counter < 5 ) {
  $dbconstfile = "../" . $dbconstfile;
  $counter++;
}

if ( $counter >= 5 ) {
  print "Unable to find DB connection information!\n";
  print "Bailing right the heck now!\n";
  exit;
}

$fh = fopen($dbconstfile, 'r');
$dbparams = fread($fh, filesize($dbconstfile));
fclose($fh);

$dbparams = str_replace(" ",null,$dbparams);

$lines = explode("\n",$dbparams);

foreach ($lines as $line) {
  $temp = explode("=",$line);

  if ( isset($temp[1]) ) {
    $param = $temp[0];
    $value = $temp[1];

    switch ($param) {
    case "host":
      $dbhost = $value;
      break;
    case "type":
      $dbtype = $value;
      break;
    case "db":
      $dbname = $value;
      break;
    case "user":
      $dbuser = $value;
      break;
    case "pass":
      if ( $value != "undef" && $value != "null" ) {
	$dbpass = $value;
      } else {
	$dbpass = null;
      }
    }
  }
}

?>
