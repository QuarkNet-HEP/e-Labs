<?php
/***********************************************************************\
 * List our most recent users
 *  
 * Provides links to the user management page for each.
 * Put this in html/ops and make sure it's properly protected.
 *
 * Eric Myers <Eric.Myers@ligo.org> - 26 Sept. 2007
 * @(#) $Id: list_new_users.php,v 1.3 2008/11/13 19:29:10 myers Exp $
\***********************************************************************/

require_once("../inc/util.inc");
require_once("../inc/user.inc");
require_once("../inc/util_ops.inc");
//require_once("../inc/forum.inc");
//require_once("../inc/profile.inc");

require_once("../project/project.inc");
require_once("../include/roles.php");


$self = $_SERVER['PHP_SELF'];
$Nbf = sizeof($special_user_bitfield);
$is_I2U2 = (PROJECT == "I2U2") || (PROJECT == "QuarkNet");

db_init();

/*******************************\
 * Authorization
\*******************************/

$logged_in_user = get_logged_in_user(true);
$logged_in_user = getForumPreferences($logged_in_user);

$is_mod =   isSpecialUser($logged_in_user, S_MODERATOR);  
$is_admin = isSpecialUser($logged_in_user, S_ADMIN)
         || isSpecialUser($logged_in_user, S_DEV);


if( !is_admin && !$is_mod ){
    error_page("You must be a project administrator or special user to use this page.");
 }


/*******************************\
 * Functions
\*******************************/

// none yet



/***********************************************************************\
 * Action: Process form info & controls
\***********************************************************************/

$limit = get_int('limit', true);
if (! $limit >0 ) $limit=30;

// TODO allow limit to be set from the form page.
// TODO allow select qualified by school or state



/***********************************************************************\
 * Display the page:
\***********************************************************************/

admin_page_head("New Users");
echo "\n<link rel='stylesheet' type=text/css href='". URL_BASE. "new_forum.css'>\n";

echo "<h2>Recently joined:</h2>\n";

echo "These are the most recent $limit users to join the project. \n";
echo "<br/>\n";
echo "Unverified e-mail addresses are shown in red.\n";
echo "Clicking on a name opens a user managment page
                <i>in another window or tab</i>.\n";

// For when we turn this into an interactive form.
echo "<form name='new_users' action='$self' method='POST'>\n";

$query="SELECT * FROM user ORDER BY create_time DESC LIMIT $limit";
$result = mysql_query($query);
if( mysql_num_rows($result)< 1 ) {
    echo "There are no new users.";
    admin_page_tail();
    exit(0);
 }   

start_table();
echo "<tr><th> ID# </th><th> Name </th><th> e-mail address</th>\n";

echo "    <th> ".  ( $is_I2U2 ? "School" : "Team") . "</th>";
echo "    <th> ".  ( $is_I2U2 ? "State" : "Country") . "</th>";
echo "    <th>Date joined</th></tr>\n";


while( $row = mysql_fetch_object($result) ){ 
    $id = $row->id;
    $name = $row->name;
    $addr = $row->email_addr;
    $country = $row->country; 
    $joined = date_str($row->create_time);
    $email_validated = $row->email_validated;

    // Team (school) name:
    //
    $team_name="";
    $teamid = $row->teamid;
    if($teamid > 0){
        $team = lookup_team($row->teamid);
        $team_name = $team->name;
    }

    // Special Users:
    //
    $roles="";
    $user=getForumPreferences($row);
    $special_bits = $user->special_user;
    if( $special_bits != "0") {
        for($i=0; $i < $Nbf;$i++) {
            $bit = substr($special_bits, $i, 1);
            if( $bit == '1' ){
                $p = strpos($special_user_bitfield[$i],' ');
                if($p === false) $p=-1;
                $x = substr($special_user_bitfield[$i],$p+1);
                if(!empty($roles)) $roles .=", ";
                $roles .= $x;
            }
        }
    }
    if( !empty($roles) ) $roles="\n      <font size='-2'>[$roles]</font>";

    // Banished?
    //
    if( !empty($user->banished_until) ){
        $dt = $user->banished_until - time();
        if( $dt > 0 ) {
            $x = "<font color='RED'><b>!</b></font>";
        }
        else {
            $x = "<font color='ORANGE'><b>*</b></font>";
        }
        $roles .= $x;
    }


    // List row
    //
    echo "<tr><td> $id </td>";
    echo "<td><a href='manage_user.php?userid=$id' target='_user'>"
        ." $name </a> $roles</td>\n";

    $C='GREEN';
    if( !$email_validated ) $C='RED';
    echo "    <td><font size='-1' color='$C'><tt> $addr</tt></font></td>\n";

    echo "    <td> $team_name </td><td> $country </td><td>$joined</td>
         </tr>\n";

 }
mysql_free_result($result);
end_table();

echo "</form>\n";


admin_page_tail();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: list_new_users.php,v 1.3 2008/11/13 19:29:10 myers Exp $"; 
?>
