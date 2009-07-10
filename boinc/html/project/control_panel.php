<?php
/***********************************************************************\
 * I2U2/BOINC control panel:  html/ops/index.php
 *
 * This is the control panel page, taken from the BOINC version
 * and then gutted to leave only the things of interest for I2U2.
 *
 * 
 * @(#) $Id: control_panel.php,v 1.2 2009/06/24 17:44:31 myers Exp $
\***********************************************************************/

require_once("../inc/db_ops.inc");
require_once("../inc/util_ops.inc");
require_once("../project/project.inc");
require_once("../project/roles.php");


$config = get_config();

$external="<img src='/library/skins/monobook/external.png'>";


db_init();

// Verify Authorization (above and beyond .htaccess)
//
if( !user_has_role('admin') && !user_has_role('dev') ){
   error_page("You must be an <b>Administrator</b> or <b>project developer</b>"
                   ." to view this page.");
}

$title = "Project Management";
admin_page_head($title);

echo "
    <p>
    <TABLE align='center' cell-padding='20' class='noborder' style='right-margin: 2em;'>
     <tr>
     <td><a href='../Help.php'>General Help</a></td>
        <td> &nbsp; | &nbsp; </td>
     <td><a href='./ControlsHelp.php'>Control Panel Help</a></td>
     </tr>
    </TABLE>
        \n";



// Special user bits testing:
//
if(1){

    echo "<P>Special user bits for user ". $logged_in_user->userid. ": <tt>"
        . $logged_in_user->special_user . "</tt>\n";

    $N = sizeof($special_user_bitfield);
    for($i=0;$i<$N;$i++){
        if( isSpecialUser($logged_in_user, $i) ){
            echo "<br>* You are a " . $special_user_bitfield[$i]. "\n";
        }
    }
    echo "\n</p>\n";
 }



// Some status information  (silent if okay)
//
check_ops_secured();
check_account_creation();
check_uotd_candidates();


/*********************
 * Control panel table:
 */

echo "
    <p>
    <TABLE class='border' width='90%' align='center' cellpadding='7'>
    <tr><TH>Users</TH><TH>Forums</TH><TH>Site Management</TH>
				<TH>Status</TH></tr>
    <tr valign='top'>
	<td class='border' width='25%'>
    <ul>
    <li><a href='/ops/manage_user.php'>Manage a user</a></li>
    <li><a href='/ops/list_new_users.php'>List new users</a></li>
	<P>
    <li><a href='/ops/profile_screen_form.php'>Screen user profiles </a></li>
    <li><a href='/ops/list_uotd_candidates.php'>List UOTD candidates</a>
    <li><a href='list_all_users.php'>List ALL users</a></li>
	<hr>
    <li><a href='/ops/manage_special_users.php'>Manage special users</a>[OLD!]</li>
    <li><a href='mass_email.php'>Send mass email to a selected set of users</a>
    </ul>
    </td> 

	<td class='border' width='25%'>
    <ul>
    <li><a href='../forum_index.php'>View all Forums</a>
    <LI><a href='../forum_forum.php?id=43'>Developer's Workroom</a>
    <LI><a href='../forum_forum.php?id=51'>Boiler Room</a>

    <li><a href='./create_forum.php'>Create new forum room</a>
	<hr>
    <li><a href='./manage_forums.php'>Manage Forums</a>
    <li><a href='./forum_repair.php'>Forum repair</a>
    </ul>
    </td>
     ";



echo "
	<td class='border' width='25%'>
    <ul>
    <li><a href='news_admin.php'>News Feed </a>
    <LI><a href='/library/index.php/I2U2:Site_Status'>Site Status Block</a> 
	<P>
    <LI><a href='../Calendar.php'>I2U2 Calendar</a> 
    <LI><a href='http://spreadsheets.google.com/ccc?key=pvw2y9-_Vf3gNVzPlbw9nfw&hl=en'>
	I2U2 Gantt Chart</a> $external
    <LI><a href='http://www.quarknet.us/Calendar.php'>QuarkNet Calendars</a> $external

    </ul>
    </td> 
";

echo "
	<td class='border' width='25%'>
    <ul>
    <LI><a href='usage/'>Webalizer Stats</a>
    <LI><a href='http://".$_SERVER['SERVER_NAME']."/server-status'
                >server-status</a>
    <LI><a href='http://".$_SERVER['SERVER_NAME']."/server-info'
                >server-info</a>

    </ul>
    </td>
";


echo "
   </tr>
    </TABLE>
";


admin_page_tail();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: control_panel.php,v 1.2 2009/06/24 17:44:31 myers Exp $";  

?>
