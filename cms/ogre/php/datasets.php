<?php

// Include the DB connection information
include "DBDefs.php";

// Connect to the database...
$conn = mysql_connect($dbhost, $dbuser, $dbpass) or 
  die ('Error connecting to mysql');

if ( !mysql_select_db($dbname, $conn) ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

// Read the bootstrap table in the ogredb to find the main XML file
$query = "SELECT name,description from datasets";

$result = mysql_query($query, $conn);
if ( !$result ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

// Figure out which selector we're putting up...
if ( !isset($footer) ) {
  print "<!-- Selector for switching between datasets -->\n";
  print "<select name='button' id='dsSelection'\n";
  print "\tonChange='javascript:changeDataset(this.options[this.selectedIndex].value);'>\n";
} else {
  print "<!-- Selector for switching between datasets -->\n";
  print "<select name='button' id='dsSelectionBtm'\n"; 
  print "\tonChange='javascript:changeDataset(this.options[this.selectedIndex].value);'\n";
  print "\tonMouseOver='javascript:showogreToolTip(dsTip);' onMouseOut='javascript:UnTip();'>\n";
}

while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
  $name = $row['name'];
  $desc = $row['description'];

  print "\t<option value='$name'>$desc</option>\n";
}

print "</select>\n";

?>
