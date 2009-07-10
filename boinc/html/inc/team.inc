<?php
/*
 * @(#) $Id: team.inc,v 1.4 2008/11/13 21:48:44 myers Exp $
\***********************************************************************/

require_once("../inc/util.inc");
require_once("../inc/db.inc");
require_once("../inc/sanitize_html.inc");
require_once("../inc/countries.inc");
require_once("../inc/credit.inc");
require_once("../inc/team_types.inc");


function show_team_create_account_url($team) {
    return; // DISABLED!   REMOVED FROM BOINC?
    $url = URL_BASE."create_account_form.php?teamid=$team->id";
    row2("Create school account URL<br><font size=-2>
        Accounts created via this URL will belong to this school team and
        will have the project preferences of its founder</font>",
         "<a href=$url>$url</a>");
}

function display_team_page($team, $offset, $sort_by) {
    $n = 20;

// there aren't indices to support sorting by credit.
// set the following to turn off sorted output.
// (though since caching is generally used this shouldn't needed)
//
    $nosort = false;

    switch($sort_by){
    case "total_credit":
        $sort_clause = "total_credit desc";
        break;
    case "expavg_credit": 
        $sort_clause = "expavg_credit desc";
        break;
    case "credit_per_member": 
        $sort_clause = "total_credit/nusers desc";
        $where_clause=" AND nusers>1  ";
        break;
    case "rac_per_member": 
        $sort_clause = "expavg_credit/nusers desc";
        $where_clause=" AND nusers>1  ";
        break;
    default:
        $sort_clause = "expavg_credit desc";
    }

    page_head("$team->name");

    echo sanitize_html($team->name_html);
    start_table();
    row1("School info");
    if (strlen($team->description)) {
        row2("Description", sanitize_html($team->description));
    }
    if (strlen($team->url)) {;
        if (strstr($team->url, "http://")) {
            $x = $team->url;
        } else {
            $x = "http://$team->url";
        }
        row2("Web site", "<a href=$x>$x</a>");
    }
    row2("Members ", $team->nusers);
    if( defined("NO_COMPUTE") ){
        row2("Total credit", format_credit($team->total_credit));
        row2("Recent average credit", format_credit($team->expavg_credit));
    }
    $user = lookup_user_id($team->userid);
    row2("Founder", user_links($user));
    if( defined("NO_COMPUTE") ){
        row2("State", $team->country);
	}
    else{
        row2("Country", $team->country);
    }

    row2("Type", team_type_name($team->type));
    row2("Make this your school", "<a href=team_join_form.php?id=$team->id>Join</a>");

    if( defined("NO_COMPUTE") )
        show_team_create_account_url($team);

    echo "</table>";
    echo "<p>";
    start_table();

    if( defined("NO_COMPUTE") )
        row1("Active members (have gotten Credit)", 4);

    echo "<tr>
        <th>Name</th>
    ";
    if (1 || $nosort) {
        echo "
            <th>Total credit</th>
            <th>Recent average credit</th>
        ";
    } else {
        if ($sort_by == "total_credit") {
            echo "<th>Total credit</th>";
        } else {
            echo "<th><a href=team_display.php?teamid=$team->id&sort_by=total_credit&offset=$offset>Total credit</a></th>";
        }
        if ($sort_by == "expavg_credit") {
            echo "<th>Recent average credit</th>";
        } else {
            echo "<th><a href=team_display.php?teamid=$team->id&sort_by=expavg_credit&offset=$offset>Recent average credit</a></th>";
        }
   }

    echo "
        <th>State</th>
        </tr>
    ";

    if ($nosort) {
        $result = mysql_query("SELECT * FROM user WHERE teamid=$team->id LIMIT $offset,$n");
    } else {
        $result = mysql_query("SELECT * FROM user WHERE teamid=$team->id ORDER BY $sort_clause limit $offset,$n");
    }

    $j = $offset + 1;
    while ($user = mysql_fetch_object($result)) {
        $user_total_credit = format_credit($user->total_credit);
        $user_expavg_credit = format_credit($user->expavg_credit);
        $x = user_links($user);
        echo "<tr class=row1>
            <td align=left>$j) $x
            <td align=center>$user_total_credit</td>
            <td align=center>$user_expavg_credit</td>
            <td align=center>$user->country</td>
            </tr>
        ";
        $j++;
    }
    mysql_free_result($result);
    echo "</table>";

    if ($offset > 0) {
        $new_offset = $offset - $n;
        echo "<a href=team_display.php?teamid=$team->id&sort_by=$sort_by&offset=$new_offset>Last $n</a> | ";
    }
    if ($j == $offset + $n + 1) {
        $new_offset = $offset + $n;
        echo "<a href=team_display.php?teamid=$team->id&sort_by=$sort_by&offset=$new_offset>Next $n</a>";
    }
}

// requires that the team exist
function require_team($team) {
    if (!$team) {
        error_page("No such team.");
    }
}

// requires that the user is logged in as the founder of
// the team trying to be edited
//
function require_founder_login($user, $team) {
    require_team($team);
    if ($user->id != $team->userid) {
        error_page("Only a team's founder may edit a team.");
    }
}

function team_table_start($sort_by,$type_url) {
    echo "<tr>
        <th>".tr(USER_TABLE_RANK)."</th>
        <th>".tr(USER_TABLE_NAME)."</th>
        <th>".tr(TEAM_TABLE_MEMBERS)."</th>
    ";
    if ($sort_by == "total_credit") {
        echo "
            <th><a href=top_teams.php?sort_by=expavg_credit".$type_url.">".tr(EXPAVG_CREDIT)."</a></th>
            <th>".tr(TOTAL_CREDIT)."</th>
        ";
    } else {
        echo "
            <th>".tr(EXPAVG_CREDIT)."</th>
            <th><a href=top_teams.php?sort_by=total_credit".$type_url.">".tr(TOTAL_CREDIT)."</a></th>
        ";
    }
    echo "
        <th>".tr(USER_TABLE_COUNTRY)."</th>
        </tr>
    ";
}

function show_team_row($team, $i) {
    $team_expavg_credit = format_credit($team->expavg_credit);
    $team_total_credit = format_credit($team->total_credit);
    echo"<tr class=row1>
        <td>$i</td>
        <td><a href=team_display.php?teamid=$team->id>$team->name</a></td>
        <td>$team->nusers</td>
        <td>$team_expavg_credit</td>
        <td>$team_total_credit</td>
        <td>$team->country</td>
        </tr>\n";
}

function user_join_team($team, $user) {
    $old_teamid = $user->teamid;
    $res = mysql_query("update user set teamid=$team->id where id=$user->id");
    if ($old_teamid != 0) {
        $old_team = lookup_team($old_teamid);
        team_update_nusers($old_team);
    }
    team_update_nusers($team);
    if ($res) return true;
    return false;
}

function user_quit_team($user) {
    $team = lookup_team($user->teamid);
    if (!$team) return;
    mysql_query("update user set teamid=0 where id=$user->id");
    mysql_query("UPDATE team SET ping_user=0 WHERE id=".$user->teamid." AND ping_user=".$user->id);
}


function team_edit_form($team, $label, $url) {
    global $team_types;
    echo "<form method=post action=$url>\n";
    if ($team) {
        echo "<input type=hidden name=teamid value=$team->id>\n";
    }
    /***********************DISABLED - this is a BOINC leftover
    echo "
        <p>
        <b>Privacy note</b>: if you create a school 
        account, your project preferences (resource share, graphics preferences)
        will be visible to the public.
        <p>
    ";
    ***************************************/


    echo "Create a team for your school or institution ";


    start_table();
    row2( "<b>School name</b> <br><font size=-2>
        Don't use any HTML tags.",
        "<input name=name type=text size=50 value='$team->name'>"
    );

	/************
    row2("School name, HTML version
        <br><font size=-2>
        You may include HTML formatting, link, and image tags.
        If you don't know HTML, just leave this box blank.",
        "<input name=name_html type=text size=50 value=\"".str_replace('"',"'",$team->name_html)."\">"
    );
	*************/



    row2("<b>School URL</b><br><font size=-2>(without \"http://\")
        This URL will be linked to from your groups's page on this site.",
        "<input name=url size=60 value='$team->url'>"
    );
    row2("<b>Description</b><br><font size=-2>Please tell us something
		about your school.",
        "<textarea name=description cols=60 rows=10>$team->description</textarea>"
    );


    //    row2("Type of team:", team_type_select($team)); 

    /******************
    /////////////////////////
    //TODO: redo this to arbitrary length
    // Make it a pull-down not a radio button

    $x1 = $team->type==1?"checked":"";
    $x2 = $team->type==2?"checked":"";
    $x3 = $team->type==3?"checked":"";
    $x4 = $team->type==4?"checked":"";
    $x5 = $team->type==5?"checked":"";
    $x6 = $team->type==6?"checked":"";
    $x7 = $team->type==7?"checked":"";
    $x7 = $team->type==8?"checked":"";
    $x7 = $team->type==9?"checked":"";

    if ($team==null) $x1 = "checked";
    row2("Type of team:",
        "    <input type=radio name=type value=1 $x1>".$team_types[1]."
        <br> <input type=radio name=type value=2 $x2>".$team_types[2]."
        <br> <input type=radio name=type value=3 $x3>".$team_types[3]."
        <br> <input type=radio name=type value=4 $x4>".$team_types[4]."
        <br> <input type=radio name=type value=5 $x5>".$team_types[5]."
        <br> <input type=radio name=type value=6 $x6>".$team_types[6]."
        <br> <input type=radio name=type value=7 $x7>".$team_types[7]."
        <br> <input type=radio name=type value=7 $x8>".$team_types[8]."
        <br> <input type=radio name=type value=7 $x9>".$team_types[9]
    );

    ////////////////
    *****************/

    //I2U2 and QuarkNet use state not country
    if( defined("NO_COMPUTE") ){
        row2_init("State", "<select name=country>"    );
    }
    else {
        row2_init("Country", "<select name=country>"    );
    }
    print_country_select($team->country);


    echo "</select></b></td></tr>\n";
    row2("",
        "<input type=submit name=new value='$label'>"
    );
    end_table();
    echo "</form>\n";
}

// decay a team's average credit
//
function team_decay_credit($team) {
    $avg = $team->expavg_credit;
    $avg_time = $team->expavg_time;
    $now = time(0);
    update_average($now, 0, 0, $avg, $avg_time);
    mysql_query("update team set expavg_credit=$avg, expavg_time=$now where id=$team->id");

}
// if the team hasn't received new credit for ndays,
// decay its average and return true
//
function team_inactive_ndays($team, $ndays) {
    $diff = time() - $team->expavg_time;
    if ($diff > $ndays*86400) {
        team_decay_credit($team);
        return true;
    }

    return false;
}

function team_update_nusers($team) {// Deprecated?
    $res = mysql_query("select count(*) as total from user where teamid=$team->id");
    $comp = mysql_fetch_object($res);
    if (!$comp) return;
    $n = $comp->total;
    mysql_query("update team set nusers=$n where id=$team->id");

    //if ($n == 0) {
    //    echo "<br>Team is empty - deleting team.\n";
    //    mysql_query("delete from team where id=$team->id");
    //}
}

function team_count_nusers($teamid) {
    $res = mysql_query("select count(*) as total from user where teamid=$teamid and total_credit>0");
    $cnt = mysql_fetch_object($res);
    if ($cnt) {
        $n = $cnt->total;
        // mysql_query("update team set nusers=$n where id=$teamid");
        return $n;
    } else {
        return null;
    }
}



?>
