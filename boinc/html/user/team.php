<?php
  // Team affiliation page, modified for I2U2.

include_once("../inc/db.inc");
include_once("../inc/util.inc");
include_once("../inc/team.inc");


db_init();

$logged_in_user = get_logged_in_user(true);

page_head("School Affiliation");

echo "<blockquote><blockquote>\n";

echo "<p> I2U2 participants can indicate their school or institutional 
        affiliation as a part of their personal profile.</p>

  <P>
  Each school or other institution will have a
  \"team\" for everybody affiliated with that institution.
  If your school does not already have a team then a teacher 
  from that school can (and should) create one. </p>

  <P>
  If your school already has a team then you should join it.  
  Team membership helps identify you as a participant, and tells the
  other I2U2 participants a little more about you. </p>

   ";

/***********
    <p>
    You can (for now) belong to only one team.
    <p>  Each team has a <b>founder</b>, who may
    <ul>
    <li> access team members' email addresses
    <li> edit the team's name and description
    <li> remove members from the team
    <li> disband a team if it has no members
    </ul>
************/

echo "<p>
    To join a team, visit its team page
        and click the <b>Join</b> link there, or select
        a school from the pull-down menu below.
        </blockquote>\n";


echo "
    <h3>Select a School</h3>
    <blockquote>
    <form method='POST' action='team_join_action.php'>
    Select your school: "
    .team_select().
    " <input type='submit' value='Join!'>
    </form>
    </blockquote>

";



echo "
    <h3>Search for Schools</h3>
    <blockquote>
    <form method='GET' action='team_lookup.php'>
    Search for a school who's name contains:
    <input name='team_name'>
    <input type='submit' name='search' value='Search'>
    </form>
    </blockquote>
        ";


/* Only show team creation link to a user who can create a team */

if( !empty($logged_in_user) &&  function_exists('is_Administrator') ){ 
   
    $logged_in_user= getForumPreferences($logged_in_user);

    if( is_Administrator($logged_in_user) ||
        is_HS_teacher($logged_in_user) ||
        is_Developer($logged_in_user) ) {
      echo "
        <h3>Add a School </h3>
            <blockquote>
         <a href=team_create_form.php>Create a new \"team\" for your school
                or institution.</a>
            </blockquote>\n";
    }
 }

echo "\n    </ul>\n        ";


echo "</blockquote>\n";

    page_tail();

?>
