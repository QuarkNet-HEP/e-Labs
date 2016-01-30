<?php
/***********************************************************************\
 * Display a forum (discussion room).
 *
 * Requires one input, via GET or POST, id=<room number>
 * 
 * Modified from BOINC forum code (http://boinc.berkeley.edu)
 * by Eric Myers <myers@spy-hill.net> for the I2U2 project (www.i2u2.org)
 *
 * @(#) $Id: forum_forum.php,v 1.9 2009/05/29 13:23:08 myers Exp $
\***********************************************************************/ 

require_once('../inc/forum.inc');
require_once('../inc/util.inc');
require_once('../inc/time.inc');
require_once('../inc/forum_show.inc');

require_once('../project/project.inc'); // for category privacy policy

//set_debug_level(3);


$id = get_int("id",true);
$sort_style = get_str("sort", true);
if(!$sort_style) $sort_style = post_str("sort", true);
$start = get_int("start", true);
if (!$start) $start = 0;

db_init();


$forum = getForum($id);
if( !$forum ){
   error_page("Discussion room $id does not exist.");
}

$title = $forum->title;
$category = getCategory($forum->category);

//// HACK FOR PRIVATE FORUMS, do this before page_head()
$pvt=false;

if( function_exists('category_is_private') ){
    $pvt=category_is_private($category->id);
 }

$next_url=$self;  // come back, Shane!
$logged_in_user = get_logged_in_user($pvt) ;
$logged_in_user = getForumPreferences($logged_in_user);


// Access controls:
//
if( function_exists('check_reading_is_allowed') ){
    if( !check_reading_is_allowed($logged_in_user, $forum) ) {
        error_page("You are not allowed to read this forum.");
    }
 }


if ($category->is_helpdesk) {
    if (!$sort_style) {
        $sort_style = getSortStyle($logged_in_user,"faq");
    } else {
        setSortStyle($logged_in_user,"faq",$sort_style);
    }
    if (!$sort_style) $sort_style = 'timestamp';
    //$title = "Help Desk: $title";
}
 else {
    if (!$sort_style) {
        $sort_style = getSortStyle($logged_in_user,"forum");
    } else {
        setSortStyle($logged_in_user, "forum",$sort_style);
    }
    if (!$sort_style) $sort_style = 'modified-new';
    $title = "Discussion: $title";
}


/***********************************************************************\
 * Display Page:
 */

page_head($title);

show_forum_title($forum, NULL, $category->is_helpdesk);

echo "<!-- BEGIN forum_forum -->
    <form method='GET' action='forum_forum.php' >
    <input type=hidden name=id value=", $forum->id, ">
    <table width=100% cellspacing=0 cellpadding=0>
    <tr valign=bottom>
    <td class='left noborder'>
";

echo "<p>\n<a href=forum_post.php?id=$id>";
if ($category->is_helpdesk) {
    echo "Submit a question or report a problem</a>";
} else  {
    echo "Create a new thread</a> ";
    echo "- <i>Please create a new thread for a new topic</i> ";
}

echo "\n</p>\n</td>";

echo "<td align='right'>";
if ($category->is_helpdesk) {
  //show_select_from_array("sort", $faq_sort_styles, $sort_style);
  echo  auto_select_from_array("sort", $faq_sort_styles, $sort_style,'Ok');
}
else {
  //show_select_from_array("sort", $forum_sort_styles, $sort_style);
  echo  auto_select_from_array("sort", $forum_sort_styles, $sort_style,'Ok');
}
//echo "<input type=submit value=OK></td>\n";

echo "</tr>\n</table>\n";

show_forum($category, $forum, $start, $sort_style, $logged_in_user);

echo "\n</form><!-- END forum_forum -->\n";
page_tail();

?>
