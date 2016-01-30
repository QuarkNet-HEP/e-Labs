<?php
/***********************************************************************\
 * List all the teachers in the e-Lab database
 *
 * Eric Myers <myers@spy-hill.net>  -  23 April 2009
 * @(#) $Id:$
\***********************************************************************/

require_once("../ops/eLabDatabase.php");


$table = $_GET['table'];
if( empty($table) ) $table = "teacher";
 
$sort = $_GET['sort'];
if( empty($sort) ) $sort = "name";

$query = "SELECT * FROM $table ORDER BY $sort, id DESC";

$conn_string="host=$db_host dbname=$db_name user=$db_user password=$db_pass";
$db = pg_pconnect("$conn_string") 
	or die("! Failed to connect to database $db_name as user $db_user");


 echo "<p>Connected to database $db_name (as user $db_user) <br>\n";

echo "<h2><tt>psql> $query</tt></h2>\n";

$result = pg_query($query);
if( $result===FALSE ){
      echo "<font color=RED>! Query failed. <br>\n";
      echo "<tt>" .pg_last_error(). "</tt></font><br>\n";
      die;
}


// get headers

$row = pg_fetch_assoc($result);

// Printing results in HTML



echo "<table cellpadding=3>\n";
$n=0;
$prev_value='none';

while ($line = pg_fetch_array($result, null, PGSQL_ASSOC)) {
  echo "\t<tr>\n";

  if( ($n++ % 25)==0 ) {
    foreach ($line as $col_name => $col_value) {
      echo "\t\t<th>$col_name</th>\n";
    }
    echo "\t</tr>\n";
  }
  foreach ($line as $col_name => $col_value) {
    $x1=''; $x2='';
    if( $col_name == $sort ){
      if( $col_value == $prev_value ){
	$x1="<font color=RED>"; $x2="</font>";
      }
      $prev_value = $col_value;
    }
    echo "\t\t<td>$x1 $col_value $x2</td>\n";
  }
  echo "\t</tr>\n";
 }

echo "</table>\n";


echo "<h2><tt>$query</tt></h2>\n";

echo "<P> There were $n items in the table. <br>\n"; 



pg_close($db);

?>
