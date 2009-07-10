<?php

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/team.inc");

db_init();
$user = get_logged_in_user(true);

page_head("Remove School Affiliation");

$team = lookup_team($user->teamid);
if (!$team) {
  echo "<p>
	It looks like you do not currently have any school affiliation.
        <br>
    Press your browser's <b>back</b> button to go back.
        
    <P>
	(You can press the button at the bottom of the page to try
	to remove a school anyway, if you think I made a mistake.)
	<P>  ";
 }
 else {

    echo "<P>
	Press the button at the bottom of this page
	to remove your affiliation with <i>$team->name </i>.
	<p>
    Or press your browser's <b>back</b> button to go back.
    <p>
       ";
 }



echo "
    <b>Please note before dropping your school affiliation:</b>
    <ul>
    <li>If you drop your schoool affiliation you may add it again later.
    <LI>At present you may only have one schoool or institutional affiliation, 
        but in the future you should be able to have more than one
        affiliation.

    </ul>
    </p>
    <form method='post' action='team_quit_action.php'>
    <input type='hidden' name='id' value=$team->id>
    <input type='submit' value='Remove School'>
    </form>
";
page_tail();

?>
