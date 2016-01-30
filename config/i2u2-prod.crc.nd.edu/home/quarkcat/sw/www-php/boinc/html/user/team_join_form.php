<?php

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/team.inc");

db_init();
$user = get_logged_in_user(true);

$teamid = get_int("id",true);     
if(!$teamid) $teamid = post_int("teamid",true);

// If no team specified and no team_select() then go look a team up...
//
if(!$teamid && !function_exists('team_select') ){
    header("Location: team.php");
    exit(0);
 }


if(!$teamid){  
    page_head("Select your school");
 }
 else {
     $team = lookup_team($teamid);
     $team_name = $team->name;
     page_head("Select school affiliation");
     echo "Set your school affiliation to <i>$team_name</i>?";
 }

echo " <p><b>Please note:</b>
    <ul>
    <li> Joining a school's team gives its founder access to your email address.
<!--    <li> Joining a school's team does not affect your account's credit.-->
    </ul>
        <P>
    <form method='POST' action='team_join_action.php'>
      ";

if( !$teamid && function_exists('team_select') ){
    $default=$user->teamid;
    echo "<P>Select a team: ". team_select($default). "<br>\n";
 }

 else {
    echo " <input type='hidden' name='teamid' value='$teamid'>\n";
 }

echo "  <input type='submit' value='Select this school'>
    </form>\n";



page_tail();

?>
