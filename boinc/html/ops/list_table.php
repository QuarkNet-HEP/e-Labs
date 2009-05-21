<?php
/***********************************************************************\
 * List all the teachers in the e-Lab database
 *
 * Eric Myers <myers@spy-hill.net>  -  23 April 2009
 * @(#) $Id:$
\***********************************************************************/

// Edit here to change query:

$query = "SELECT * FROM research_group"; 
$query = "SELECT * FROM research_group WHERE role='user' ";
$query = "SELECT * FROM school";
$query = "SELECT * FROM teacher ORDER BY name";
$query = "SELECT * FROM research_group WHERE role='teacher' ORDER BY teacher_id";


// Production:
//
$db_host="data1.i2u2.org";
$db_name="userdb2006_1022";
$db_user="portal2006_1022";
$db_pass="elab";

// Development and testing:
//
$db_host="data1.i2u2.org";
$db_name="userdb_cosmic2_testing";
$db_user="portal2006_1022";
$db_pass="portal2006_1022";


$conn_string="host=$db_host dbname=$db_name user=$db_user password=$db_pass";
$db = pg_pconnect("$conn_string") 
	or die("! Failed to connect to database $db_name as user $db_user");


echo "<p>Connected to database $db_name as user $db_user <br>\n";

$result = pg_query($query)
	    or die("Query failed: $query");

// get headers

$row = pg_fetch_assoc($result);

// Printing results in HTML

echo "<h2><tt>$query</tt></h2>\n";

echo "<table>\n";
$n=0;


while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
  echo "\t<tr>\n";

  if( ($n++ % 25)==0 ) {
    foreach ($line as $col_name => $col_value) {
      echo "\t\t<th>$col_name</th>\n";
    }
    echo "\t</tr>\n";
  }
  foreach ($line as $col_name => $col_value) {
    echo "\t\t<td>$col_value</td>\n";
  }
  echo "\t</tr>\n";
 }

echo "</table>\n";


echo "<h2><tt>$query</tt></h2>\n";

echo "<P> There were $n items in the table. <br>\n"; 



pg_close($db);

?>
