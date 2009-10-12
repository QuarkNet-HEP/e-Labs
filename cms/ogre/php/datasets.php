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
$query = "SELECT name,description from $table";

$result = mysql_query($query, $conn);
if ( !$result ) {
  echo mysql_errno($conn) . ":" . mysql_error($conn) . "\n";
}

print "<!-- Selector for switching between datasets -->\n";
print "<select name='button' id='dsSelection'\n";
print "\tonChange='javascript:changeDataset(this.options[this.selectedIndex].value);'>\n";
//print "\t<option value=''    >Data Sets</option>\n";

while ($row = mysql_fetch_array($result, MYSQL_ASSOC)) {
  $name = $row['name'];
  $desc = $row['description'];

  print "\t<option value='$name'>$desc</option>\n";
}

print "</select>\n";

?>
