<?php

require_once('../inc/forum.inc');
require_once('../inc/util.inc');
require_once('../inc/time.inc');

// show only recent activity

require_once('../project/extras.php');

$helpdesk_only_recent = show_only_recent();

db_init();

page_head("Help Desk");

echo "<table width='100%' border=0><tr>
      <td valign='top'>
         <a href='HelpDeskRequest.php'>Submit a request or bug report</a>
      </td>
";

/***************
echo "
<td align='right' valign='top'>
        <form action=http://www.google.com/search>
        <input type=hidden name=domains value=".URL_BASE.">
        <input type=hidden name=sitesearch value=".URL_BASE."/forum_thread.php>
        <img src='http://www.google.com/images/experimental_sm.gif'>
        <input class=small name=q size=20>
        <input type=submit value=Search>
        </form>
</td>
    ";
*************/

if( defined("HELP_DESK_AGE") ) {
    $x="";
    if( $helpdesk_only_recent ) $x = "CHECKED";
    echo "<td align='right'>
     <font size='-1'>
     <form method='POST' action='". $_SERVER['PHP_SELF']."'>
        <input type='hidden' name='helpdesk_only_recent_checkbox' value='1'>
         Show only recent questions
        <input type='checkbox' name='helpdesk_only_recent' value='1'  $x >
        <input type='submit' name='helpdesk_only_recent_submit' value='OK'>
      </form>
      </font>
      </td>";
 }

echo "\n</tr></table>\n";



/**********
    echo "
        <p>
        Do a <a href=forum_text_search_form.php>keyword search</a> of messages.
        <p>
    ";
**********/


start_forum_table(array("Topic", "# Questions", "Most recent post"));

$categories = getHelpDeskCategories();
while ($category = mysql_fetch_object($categories)) {
    echo "
    <tr class=subtitle>
        <td class=category colspan=4>", $category->name, "</td>
    </tr>
    ";

    $forums = getForums($category->id);
    while ($forum = mysql_fetch_object($forums)) {
        if( $forum->orderID < 0) continue; // don't show forums "in the attic"
        ///////
        $age = 
        $x = time_diff_str($forum->timestamp, time()); 
        if( $helpdesk_only_recent &&
            (time()-$forum->timestamp) > (24*3600*HELP_DESK_AGE) ){
            $x="";
        }
        ////////

        echo "
        <tr class='row1'>
        <td>
            <b><a href=\"forum_forum.php?id=$forum->id\">$forum->title</a></b>
            <br>", $forum->description, "
        </td>
        <td>", $forum->threads, "</td>
        <td>$x</td>
    </tr>
        ";

    }
}

echo "
    </table>
</p>
";

page_tail();
?>
