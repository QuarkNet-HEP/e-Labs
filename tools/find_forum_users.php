<?php
/***********************************************************************\
 * find_forum_users.php
 * 
 * This script looks through the e-lab teacher tables for anybody who
 * does not yet have an "authenticator" for the forums.
 * It then looks through the forum user database for a user with the
 * same e-mail address.  If found, it sets the teacher's authenticator
 * to that of the same user in the forums.
 * 
 * Run this once from the command line with
 *   $  php find_forum_users.php
 * Or you can run it from cron every hour to find new forum accounts.
 *
 * Eric Myers <myers@spy-hill.net>  -  27 May 2009
 * @(#) $Id: find_forum_users.php,v 1.1 2009/05/28 16:27:02 myers Exp $
\***********************************************************************/

// mySQL database (for forums):

require_once("../inc/db.inc");
db_init();

// pgSQL databse (for e-lab):
require_once("../ops/eLabDatabase.php");

if( empty($db_pass) ) {
  die("Need password prompt here.");
}


$conn_string="host=$db_host dbname=$db_name user=$db_user password=$db_pass";
$db = pg_pconnect("$conn_string") 
	or die("! Failed to connect to database $db_name as user $db_user");

echo "<p><b>Connected to database $db_name as user $db_user</b> <br><br>\n";

$pg_query = "SELECT * FROM teacher WHERE authenticator IS NULL ";
$pg_query .= "AND email IS NOT NULL ORDER BY id";

echo "<tt>$pg_query</tt><p>\n";

$pg_result = pg_query($pg_query)
	    or die("Query failed: $query");

$Nteachers=0;
$Nfound=0;
while ($teacher = pg_fetch_array($pg_result, null, PGSQL_ASSOC)) {
  $id=$teacher['id'];
  $name=$teacher['name'];
  $email=$teacher['email'];
  $Nteachers++;
  // $forum_id=$teacher['forum_id']; 


  if( empty($email) ) continue;

  $my_query ="SELECT * FROM user WHERE email_addr=\"$email\" ";
  //echo "<br><tt>$my_query</tt></br>\n";
  $my_result = mysql_query($my_query);
  while ($forum_user = mysql_fetch_object($my_result)) {
    echo "<br>$id) $name &lt;$email&gt; ";
    $forum_id=$forum_user->id;
    $authenticator = $forum_user->authenticator;
    echo " [$forum_id] $authenticator <br>\n";

    $pg_query  = "UPDATE teacher SET authenticator = '$authenticator' ";
    $pg_query .= " , forum_id = $forum_id ";
    $pg_query .= " WHERE id=$id ";
    echo "<tt>$pg_query</tt><br>\n";
    $rc = pg_query($pg_query);
    if($rc===FALSE) {
      echo "! Update failed. <br>\n";
      echo "<font color=RED><tt>" .pg_last_error(). "</tt></font><br>\n";
      continue;
    }
    $Nfound++;
  }
 }

echo "<P> There were $Nteachers teachers processed, <br>\n"; 
echo "Of which there were $Nfound new forum accounts found. <br>\n"; 

pg_close($db);

?>
