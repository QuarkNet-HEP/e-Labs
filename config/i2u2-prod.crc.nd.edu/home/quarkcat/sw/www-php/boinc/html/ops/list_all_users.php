<?php
 /*  List all users in the database, along with ID#, team and pictures.
 *  This will get very long, but is useful for a small project which is
 * just getting started.
 *
 * Eric Myers <myers@spy-hill.net>  - 9 February 2006
 * @(#) $Id: list_all_users.php,v 1.2 2009/02/13 19:35:20 myers Exp $
 ************************************************************************/

require_once("../inc/db.inc");
require_once("../inc/util_ops.inc");

set_time_limit(0);

db_init();

admin_page_head("List all users");


// Get a list of team names

$q1="SELECT id,name FROM team";
$result = mysql_query($q1);
while ($team = mysql_fetch_object($result)) {
  $team_names[$team->id] = $team->name;
 }



 // List all users

$query="SELECT * FROM user";
$result1 = mysql_query($query);

 if(mysql_num_rows($result1) > 0 ){
   start_table();
   echo "<TR><TH>id#</TH><TH>Name</TH>
         <TH>E-mail  <font size='1'>(
		<font color=GREEN>verified</font>/
		<font color=RED>un-verified</font>
		)</font>
         </TH>
	 <TH>Team</TH><TH>Avatar</TH><TH>Profile</TH></TR>\n";

   $N=0;
   while ($user = mysql_fetch_object($result1)) {
     $id = $user->id;
     
    $C='GREEN';
    if( !$user->email_validated ) $C='RED';

     echo "<TR>
	<TD> $id </TD>
	<TD> $user->name </TD> 
	<TD> <font color='$C'>$user->email_addr </font>
		</TD>
	";
     if($user->teamid>0) {
       $team_name=$team_names[$user->teamid];
     }
     else {
       $team_name=" &nbsp; ";
     }
     echo "
	<TD> " . $team_name. "</TD>\n";

     // Avatar image:
     echo "
	<TD><IMG height='32' src='/user_profile/images/" .$id. "_avatar.jpg'></TD>
	";


     // Profile pictures
     echo "
	<TD><IMG height='32' src='/user_profile/images/" .$id. "_sm.jpg'></TD>
	";


     echo "       </TR>\n";
     $N++;
   }

   end_table();
 }

echo "<P>
	There are a total of " .$N. " users in the database.
	<P>
     ";

admin_page_tail();
?>
