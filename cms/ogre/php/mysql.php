<?php

if ( !isset($dataset) ) {
  if ( isset($_GET['dataset']) ) {
    $dataset = $_GET['dataset'];
  } else {
    $dataset = "mc09";
  }
}

// DB connection information
$dbhost = "localhost";
$dbuser = "ogre";
$dbpass = null;
$dbname = "ogredb";
$table  = "datasets";

// Connect to the database...
$conn = mysql_connect($dbhost, $dbuser, $dbpass) or 
  die ('Error connecting to mysql');

if ( !mysql_select_db($dbname, $conn) ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

// Read the bootstrap table in the ogredb to find the main XML file
$query = "SELECT * from bootstrap";

$result = mysql_query($query, $conn);
if ( !$result ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
  $ogrexml = $row['ogreXML'];
}

//create xml parser object
$ogre_parser = xml_parser_create();

//this option ensures that unneccessary white spaces
//between successive elements would be removed
xml_parser_set_option($ogre_parser,XML_OPTION_SKIP_WHITE,1);

//to use XML code correctly we have to turn case folding
//(uppercasing) off. XML is case sensitive and upper 
//casing is in reality XML standards violation
xml_parser_set_option($ogre_parser,XML_OPTION_CASE_FOLDING,0);

//read XML file into $data
$data = implode("",file($ogrexml));

//parse XML input $data into two arrays:
//$i_ar - pointers to the locations of appropriate values in
//$d_ar - data value array
xml_parse_into_struct($ogre_parser, $data, $d_ar, $i_ar);

// Read the ogre.xml file (in the cgi-bin directory) and assemble the 
// path to the XML data description files
for($i=0; $i<count($i_ar['parameter']); $i++) {
  $name = $d_ar[$i_ar['parameter'][$i]]['attributes']['name'];
  if ( $name == "baseDir" ) {
    $baseDir = $d_ar[$i_ar['parameter'][$i]]['attributes']['value'];
  } else if ( $name == "xmlDir" ) {
    $type = $d_ar[$i_ar['parameter'][$i]]['attributes']['type'];
    $xmlDir = $d_ar[$i_ar['parameter'][$i]]['attributes']['value'];
  }
}

if ( $type == "relpath" ) {
  $path = $baseDir . "/" . $xmlDir;
} else {
  $path = $xmlDir;
}

$query = "SELECT xml from $table where name='$dataset'";

$result = mysql_query($query, $conn);
if ( !$result ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
  $xmlFile = $path . "/" . $row['xml'];
  $xmlFileName = $row['xml'];
}

?>
