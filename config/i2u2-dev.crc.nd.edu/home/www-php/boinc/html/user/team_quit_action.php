<?php
    require_once("../inc/db.inc");
    require_once("../inc/util.inc");
    require_once("../inc/team.inc");

    db_init();
    $user = get_logged_in_user();
    //    $teamid = $_POST["id"];  // IGNORE THIS

    page_head("Remove School Affiliation");

    $team = lookup_team($user->teamid);
    $teamid = lookup_team($user->teamid);
    mysql_query("UPDATE user SET teamid=0 WHERE id=$user->id");
    team_update_nusers($team);

    if (!$team) {
     echo "<p>
	   You are now have no school or institutional affiliation.
	   <P>  ";
    }
    else {
      echo "<P>
	   You have been removed from
	   <a href=team_display.php?teamid=$team->id>$team->name</a>
        <P>

	  ";
    }

echo "<P>
       Go to <a href='home.php'>your account page</a>.
       \n"; 


page_tail();

?>
