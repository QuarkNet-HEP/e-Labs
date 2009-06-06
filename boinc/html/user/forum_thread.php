<?php

require_once('../inc/forum.inc');
require_once('../inc/util.inc');

require_once('../project/project.inc'); // for category privacy policy


db_init();

$threadid = get_int('id');
$sort_style = get_str('sort', true);
if(!$sort_style) post_str('sort', true);

$filter = get_str('filter', true);

if ($filter != "false"){
    $filter = true;
} else {
    $filter = false;
}

$thread = getThread($threadid);
if (!$thread) {
    error_page("No such thread found");
}
incThreadViews($thread->id);

$forum = getForum($thread->forum);
$category = getCategory($forum->category);


//// HACK FOR PRIVATE FORUMS, do this before page_head()
$pvt=false;

if( function_exists('category_is_private') ){
    $pvt=category_is_private($category->id);
 }

$logged_in_user = get_logged_in_user($pvt) ;
$logged_in_user = getForumPreferences($logged_in_user);

if( function_exists('check_reading_is_allowed') ){
    if( !check_reading_is_allowed($logged_in_user, $forum) ) {
        error_page("You are not allowed to read this forum");
    }
 }



$title = cleanup_title($thread->title);
if ($category->is_helpdesk) {
    if (!$sort_style) {
        $sort_style = getSortStyle($logged_in_user,"answer");
    } else {
        setSortStyle($logged_in_user,"answer",$sort_style);
    }
} else {
    if (!$sort_style) {
        $sort_style = getSortStyle($logged_in_user,"thread");
    } else {
        setSortStyle($logged_in_user,"thread",$sort_style);
    }
 }

if ($logged_in_user->jump_to_unread){
    page_head($title, 'jumpToUnread();');
	echo "<link href=\"forum_forum.php?id=".$forum->id."\" rel=\"up\" title=\"".$forum->title."\">";
 } else {
    page_head($title);
	echo "<link href=\"forum_forum.php?id=".$forum->id."\" rel=\"up\" title=\"".$forum->title."\">";
 }


// TODO: Constant for default sort style and filter values.
if ($sort_style == NULL) {
    $sort_style = "timestamp_asc";
}

$is_subscribed = false;

if(!empty($logged_in_user)) { 
    ////////// TESTING "ERROR" HERE///////////
    // was ->id which may be ambigious after merge NO
    $id = $logged_in_user->id;
    if( !is_numeric($id) )
        error_log("forum_thread.php: Non-numeric user ID: >$id<");
    else {
        error_log("Subscription check for user $id");
        $result = mysql_query("SELECT * FROM subscriptions WHERE userid=". $id
                          . " AND threadid = " . $thread->id );
    }
    ///////////////END TEST////////////////////
    if ($result) {
        $is_subscribed = (mysql_num_rows($result) > 0);
        mysql_free_result($result);
    }
}


show_forum_title($forum, $thread, $category->is_helpdesk);

if (($thread->hidden) && (!isSpecialUser($logged_in_user,0))) {
    /* If the user logged in is a moderator, show him the
     * thread if he goes so far as to name it by ID like this.
     * Otherwise, hide the thread.
     */
    error_page("This thread has been hidden for administrative purposes");
    exit(); 
}

    
    echo "
        <form action='forum_thread.php'>
        <input type=\"hidden\" name=\"id\" value=\"", $thread->id, "\">
        <table width='100%' cellspacing=0 cellpadding=0>
        <tr>
        <td align=\"left\">
    ";

    $link = "<a href=\"forum_reply.php?thread=" . $thread->id;
    if ($category->is_helpdesk) {
        $link = $link . "&helpdesk=1#input\">Answer this question";
    } else {
        $link = $link . "#input\">Post to this thread";
    }

    echo $link, "</a> &nbsp;-&nbsp;";

    if ($is_subscribed) {
        if ($category->is_helpdesk) {
            echo "You are subscribed to this question.  ";
        } else {
            echo "You are subscribed to this thread.  ";
        }
        echo "<a href=\"forum_subscribe.php?action=unsubscribe&amp;thread=$thread->id\">Click here to unsubscribe</a>.";
    } else {
        if ($category->is_helpdesk) {
            echo "<a href=\"forum_subscribe.php?action=subscribe&amp;thread=$thread->id\">Subscribe to this question</a>";
        } else {
            echo "<a href=\"forum_subscribe.php?action=subscribe&amp;thread=$thread->id\">Subscribe to this thread</a>";
        }
    }

   // Special user links for moderators and administrators
   //
   if( user_has_role('moderator') || user_has_role('admin') ||
       user_has_role('dev') ){
        echo "<br /><a href=\"forum_moderate_thread.php?action=hide&amp;thread=$thread->id\">Delete this thread</a>";
	if($thread->sticky){
	  echo "&nbsp;-&nbsp;<a href=\"forum_moderate_thread_action.php?action=desticky&amp;thread=$thread->id\">De-sticky this thread</a>"; 
	}
	else {
	  echo "&nbsp;-&nbsp;<a href=\"forum_moderate_thread_action.php?action=sticky&amp;thread=$thread->id\">Make this thread sticky</a>"; 
	}
    }

    echo "</td>";

    echo "<td align=right style=\"border:0px\">";
    if ($category->is_helpdesk) {
        //show_select_from_array("sort", $answer_sort_styles, $sort_style);
        echo  auto_select_from_array("sort", $answer_sort_styles, $sort_style,'Ok');
    } else {
        echo "Sort ";
        //show_select_from_array("sort", $thread_sort_styles, $sort_style);
        echo  auto_select_from_array("sort", $thread_sort_styles, $sort_style,'Ok');
    }
    echo "</tr>\n</table>\n</form>\n";

    // Here is where the actual thread begins.
    if ($category->is_helpdesk) {
        $headings = array(array("Author","authorcol"),
                          array("Question","titlecol' colspan='3"));
    } else {
        $headings = array(array("Author","authorcol"),
                          array("Messages","titlecol' colspan='3"));
    }

    start_forum_table($headings, "class='thread' width='100%'");
    show_posts($thread, $sort_style, $filter, true, true, $category->is_helpdesk);
    end_forum_table();

    // Link to post to thread

    echo "<p>";
    $link = "<a href='forum_reply.php?thread=" . $thread->id;
    if ($category->is_helpdesk) {
        $link = $link . "&helpdesk=1#input'>Answer this question";
    } else {
        $link = $link . "#input'>Post to this thread";
    }
    echo $link, "</a>\n";

    // Link to return to forum listing
    //
    echo " &nbsp;|&nbsp; ";
    $link  = "<a href='forum_forum.php?id=" . $forum->id ."'>";
    $link .= $link ."Return to overview</a>\n";
    echo "$link \n";

    // Link to set forum preferences
    //
    echo " &nbsp;|&nbsp; ";
    $next_url = "forum_forum.php?id=" . $forum->id;
    $link  = "<a href='edit_forum_preferences_form.php?next_url=$next_url'>";
    $link .= $link ."Forum preferences</a>\n";
    echo "$link \n";

    // Forum title again at bottom

    show_forum_title($forum, $thread, $category->is_helpdesk);


page_tail();
?>
