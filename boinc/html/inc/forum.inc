<?php

require_once('../inc/db.inc');
require_once('../inc/db_forum.inc');
require_once('../inc/time.inc');
require_once('../inc/forum_moderators.inc');
require_once('../inc/text_transform.inc');
require_once('../project/project.inc');


// attachments and keywords

require_once('../include/forum_attach.php');
require_once('../include/forum_keyword.php');


define('AVATAR_WIDTH', 100);
define('AVATAR_HEIGHT',100);

$special_user_bitfield[0]="Forum moderator";
$special_user_bitfield[1]="Project administrator";
$special_user_bitfield[2]="Project developer";
//I2U2//$special_user_bitfield[3]="Project tester";
//I2U2//$special_user_bitfield[4]="Volunteer developer";
//I2U2//$special_user_bitfield[5]="Volunteer tester";
$special_user_bitfield[6]="Project scientist";

require_once('../project/i2u2-roles.php');


define('ST_NEW_TIME', 1209600); //3600*24*14 = 14 days
define('ST_NEW', 'New member');

define('MAXIMUM_EDIT_TIME',3600); //Maximally allow edits of forums posts up till one hour after posting.

define('FORUM_OPEN_LINK_IN_NEW_WINDOW',1);
define('MAX_FORUM_LOGGING_TIME', 604800); //3600*24*7 = 7 days
define('NO_CONTROLS', 0);
define('FORUM_CONTROLS', 1);
define('HELPDESK_CONTROLS', 2);
define("EXCERPT_LENGTH", "120");

define('NEW_IMAGE', 'img/unread_post.png');
define('NEW_IMAGE_STICKY', 'img/unread_sticky.png');
define('STICKY_IMAGE', 'img/sticky_post.png');
define('NEW_IMAGE_HEIGHT','15');
define('EMPHASIZE_IMAGE', 'img/emphasized_post.png');
define('EMPHASIZE_IMAGE_HEIGHT','15');
define('FILTER_IMAGE', 'img/filtered_post.png');
define('FILTER_IMAGE_HEIGHT','15');
define('RATE_POSITIVE_IMAGE', 'img/rate_positive.png');
define('RATE_POSITIVE_IMAGE_HEIGHT','9');
define('RATE_NEGATIVE_IMAGE', 'img/rate_negative.png');
define('RATE_NEGATIVE_IMAGE_HEIGHT','9');
define('REPORT_POST_IMAGE', 'img/report_post.png');
define('REPORT_POST_IMAGE_HEIGHT','9');

define ('SOLUTION', 'This answered my question');
define ('SUFFERER', 'I also have this question');
define ('OFF_TOPIC', 'Off-topic');

define ('DEFAULT_LOW_RATING_THRESHOLD', -5);
define ('DEFAULT_HIGH_RATING_THRESHOLD', 5);

$forum_sort_styles['modified-new'] = "Most recent post first";
$forum_sort_styles['modified-old'] = "Least recent post first";
$forum_sort_styles['activity-most'] = "Most recent activity first";
$forum_sort_styles['views-most'] = "Most views first";
$forum_sort_styles['replies-most'] = "Most posts first";

// Threads can only be viewed oldest first, like a ship's logbook 
$thread_sort_styles['timestamp_asc'] = "Oldest first";
//$thread_sort_styles['timestamp'] = "Newest first";
$thread_sort_styles['score'] = "Highest rated first";

$faq_sort_styles['create_time'] = "Most recent question first";
$faq_sort_styles['timestamp'] = "Most recent answer first";
$faq_sort_styles['activity'] = "Most frequently asked first";

$answer_sort_styles['score'] = "Highest score first";
$answer_sort_styles['timestamp'] = "Most recent first";
$answer_sort_styles['timestamp_asc'] = "Oldest first";

$thread_filter_styles['2'] = "\"Very helpful\"";
$thread_filter_styles['1'] = "At least \"helpful\"";
$thread_filter_styles['0'] = "At least \"neutral\"";
$thread_filter_styles['-1'] = "At least \"unhelpful\"";
$thread_filter_styles['-2'] = "All posts";

$post_ratings['2'] = "Very helpful (+2)";
$post_ratings['1'] = "Helpful (+1)";
$post_ratings['0'] = "Neutral";
$post_ratings['-1'] = "Not helpful (-1)";
$post_ratings['-2'] = "Off topic (-2)";

// process a user-supplied title to remove HTML stuff
//
function cleanup_title($title) {
    $x = trim(htmlspecialchars(strip_tags($title)));
    $x = stripslashes($x);      // clean up funky old titles in DB
    if (strlen($x)==0) return "(no title)";
    else return $x;
}

/* Check if user has special user bit enabled */
function isSpecialUser($user, $specialbit){
    return (substr($user->special_user, $specialbit,1)==1);
}

function getHasRated($user, $postid){
    return (strstr($user->rated_posts,"|".$postid));
}



function getSortStyle($user,$place){
    if ($user->id!=""){
        list($forum,$thread,$faq,$answer)=explode("|",$user->sorting);
    } else {
        list($forum,$thread,$faq,$answer)=explode("|",$_COOKIE['sorting']);
    }
    return $$place;
}


// display functions

function show_posts($thread, $sort_style, $filter, $show_controls=true, $do_coloring=true, $is_helpdesk=false) {
  global $logged_in_user;
    global $n;   // to get the alternating colors right 
    $n = 1;

    global $category;
    if($category->is_helpdesk && $do_coloring) $n=2;

    if ($show_controls && !$is_helpdesk) {
        $controls = FORUM_CONTROLS;
    } else if ($show_controls && $is_helpdesk) {
        $controls = HELPDESK_CONTROLS;
    } else {
        $controls = NO_CONTROLS;
    }

    // If logged in user is moderator,
    // let him see all posts - including hidden ones
    //
    if (isSpecialUser($logged_in_user,0)){
        $show_hidden_posts = true;
    } else {
        $show_hidden_posts = false;
    }

    $posts = getPosts($thread->id, -1, -1, $sort_style, $show_hidden_posts);
    $postcount = mysql_num_rows($posts);
    $logged_in_user = getThreadLastVisited($logged_in_user,$thread);
    setThreadLastVisited($logged_in_user,$thread);

    $firstPost = getFirstPost($thread->id);
    $first_unread_post=$firstPost;
    if( function_exists('getLastPost') ) {
       $first_unread_post= getLastPost($thread->id);
    }


    $postnumber=0; $previous_post=0;
    if ($is_helpdesk) {
        if ($firstPost) {
            show_post($firstPost, $thread, $logged_in_user, $n, $controls, true,$filter);
            if ($do_coloring) $n = ($n+1)%2;
            $postnumber=1; $previous_post=1;
            if ($firstPost->timestamp > $logged_in_user->thread_last_visited){
                $first_unread_post=$firstPost;
            }
        }
    }
    
    //$logged_in_user->minimum_wrap_postcount=13;
    //$logged_in_user->display_wrap_postcount=12;
    $no_wraparound = get_str("nowrap",true);
    while ($post = mysql_fetch_object($posts)) {
        if (!$is_helpdesk || ($is_helpdesk && $post->id != $firstPost->id)) {
	    $postnumber++;
	    
	    if (
		(!$logged_in_user->minimum_wrap_postcount) //If the user hasn't enabled the feature to display only a certain amount of posts, simply display all of them.
		|| ($postcount <= $logged_in_user->minimum_wrap_postcount) //If it is enabled and we havent yet hit the limit, simply display all
		|| ($no_wraparound)  // If the user has asked to display all the posts just display them
		||
		(
		    ($postcount > $logged_in_user->minimum_wrap_postcount) //If it is enabled and we have hit the limit AND we have the minimum wraparound number of posts or more
		    &&
		    (
			($postnumber==1 || $postnumber==$postcount) // Let's display the post only if it is the first post 
			|| 
			(	
			    (($postnumber > $postcount-$logged_in_user->display_wrap_postcount) //or it is one of the last wrap_display_postcount posts.
			    && ($sort_style=="timestamp_asc"))
			    ||
			    (($postnumber <= $logged_in_user->display_wrap_postcount) //or it is one of the last wrap_display_postcount posts.
			    && ($sort_style=="timestamp"))
			    || (substr($sort_style,0,4)!="time")
			)
			|| ($post->timestamp > $logged_in_user->thread_last_visited) //or if this post is unread
		    )
		)
	    ){
		if ($postnumber!=$previous_post+1){
		    //A number of posts were hidden, display a way to unhide them:
		    echo "<tr class=\"postseperator\"><td></td><td colspan='3'>
		    Only the first post and the last ".($logged_in_user->display_wrap_postcount)." posts 
		    (of the ".($postcount)." posts in this thread) 
		    are displayed. <br />
		    <a href=\"?id=".$thread->id."&amp;nowrap=true\">Click here to also display the remaining posts</a>.</td></tr>";
		}
		$previous_post=$postnumber;
		show_post($post, $thread, $logged_in_user, $n, $controls, false, $filter);
        	if ($do_coloring) $n = ($n+1)%2;
        	if (($post->timestamp>$logged_in_user->thread_last_visited) && (($post->timestamp<$first_unread_post->timestamp) || $first_unread_post->timestamp==0)){
		    $first_unread_post=$post;
        	}
	    }
        }
    }
    if($post)  mysql_free_result($post);
    if($posts) mysql_free_result($posts);


    if( $logged_in_user && $logged_in_user->jump_to_unread ){
       $target = "";
       if( $first_unread_post->id != "" ) {
           $target = $first_unread_post->id;
       }
       elseif( $sort_style == CREATE_TIME_OLD  ){
           $last_post = getLastPost($thread->id);  // from extras.inc 
           $target = $last_post->id();
       }


       echo "\n\n<!-- Script to jump to first unread (or last read) post -->\n";
       if( empty($target) ){
           echo "<script>\n   function jumpToUnread(){};\n</script>\n\n";
       }
       else {
	        echo "<script>\n  function jumpToUnread(){\n     ".
		     "if(!location.hash){ location.href='#".$target."';}\n  };\n</script>\n";
       }
    }

/****************OLD WAY *******************
    if ($logged_in_user->jump_to_unread){
        if ($first_unread_post->id!=""){
            echo "<script>function jumpToUnread(){location.href='#".$first_unread_post->id."';}</script>";
        } else {
            // if sorted oldest first but nothing new jump to last post
            if($sort_style == "timestamp_asc"){
                $last_post = getLastPost($thread->id);  // from extras.inc 
                echo "<script>function jumpToUnread(){location.href='#".$last_post->id."'};</script>";
            }
            else {
                echo "<script>function jumpToUnread(){};</script>";
            }
        }
    }
************/


}



/**
 * Show a single forum post:
 */

function show_post($post, $thread, $logged_in_user, $n, $controls=FORUM_CONTROLS, $separate=false, $filter=true) {
    $user = lookup_user_id($post->user);
    $user = getForumPreferences($user);
    $user->has_avatar = ($user->avatar != "");
    $forum = getForum($thread->forum);
    $category = getCategory($forum->category);

    //If the user that made this post is on the list of people to ignore, change thresholds to be more strict

    if (in_array($user->id,explode("|",$logged_in_user->ignorelist))){
        $user_is_on_ignorelist=true;
        $rated_below_threshold = ($logged_in_user->high_rating_threshold>($post->score*$post->votes));
        $rated_above_threshold = ($logged_in_user->high_rating_threshold+abs($logged_in_user->low_rating_threshold)<($post->score*$post->votes));
    } else {                //Use normal threshold values
        $rated_below_threshold = ($logged_in_user->low_rating_threshold>($post->score*$post->votes));
        $rated_above_threshold = ($logged_in_user->high_rating_threshold<($post->score*$post->votes));
    }


    $can_edit = ($logged_in_user && $user->id == $logged_in_user->id); //Only the creator can edit the post
    //$can_edit = ((isSpecialUser($logged_in_user,0)) || ($logged_in_user && $user->id == $logged_in_user->id));// Everybody assumes we can edit posts, why not make it so?
    echo "
        <tr class=\"row$n\" valign=\"top\">
        <td rowspan=\"3\"><a name=\"$post->id\"></a>\n\t\t<div class=\"authorcol\">
    ";

    echo user_links($user);
    echo "<br>";
    global $special_user_bitfield; 
    $fstatus="";
    if ($user->special_user) {
        $keys = array_keys($special_user_bitfield);
        for ($i=0; $i<sizeof($special_user_bitfield);$i++) {
            if (isSpecialUser($user,$keys[$i])) {
                $fstatus.=$special_user_bitfield[$keys[$i]]."<br>";
            }
        }
    } else {
        if ($user->create_time>time()-ST_NEW_TIME) {
            $fstatus=ST_NEW."<br>";
        }
    }
    if ($fstatus) echo "<font size=\"-2\">$fstatus</font>";

    echo "<font size=-2>";
    if (!$filter || !$rated_below_threshold){
        if ($user->has_avatar and $logged_in_user->hide_avatars!=1) {
	  echo "<img width='".AVATAR_WIDTH."' height='".AVATAR_HEIGHT."'
		src='".$user->avatar."'  alt='Avatar'><br>";
        }
        echo "Joined: ", gmdate('M j, Y', $user->create_time), "<br>Posts: $user->posts<br>";
    }

    // circumvent various forms of identity spoofing
    // by displaying the  user id of the poster.
    // its cheap, easy, and doesn't require any additional database calls.
    //echo "ID: $user->id<br>";

   // Team = School

   if ($user->teamid) {
        $team = lookup_team($user->teamid);
        echo "<i>$team->name</i><br>\n";  
   }

   // Country = State

   echo $user->country ."<br>\n";



   /********************
    // CREDIT: 
    // printf("Credit: %.0f<br>", $user->total_credit);
    //I2U2// echo "Credit: ".number_format($user->total_credit,1)."<br>\n";

    // printf("RAC: %.1f<br>", $user->expavg_credit);
    //I2U2//echo "RAC: ".number_format($user->expavg_credit,2)."<br>\n";

    // DUBLOONS:
    $dubloons = $user->seti_nresults;
    if($dubloons>0 && 0 ){ //I2U2//
      echo "Dubloons: $dubloons <br>\n";
    }
   ****************/


    echo "</font></div></td>\n\t\t
    ";

    if ($controls == FORUM_CONTROLS || $controls == HELPDESK_CONTROLS) {
        echo "<form action=\"forum_rate.php?post=", $post->id, "\" method=\"post\">";
    }
    if ($controls == FORUM_CONTROLS){
	echo "<td align=left colspan='3' class=\"postheader\" valign=\"top\"><font size=-2>";
    } else {
	echo "<td align=left colspan='2' class=\"postheader\" valign=\"top\"><font size=-2>";
    }

    if ($post->timestamp>$logged_in_user->thread_last_visited){
        echo "<img src=\"".NEW_IMAGE."\" alt=\"Unread post\" height=\"".NEW_IMAGE_HEIGHT."\">";
    }
    if ($rated_above_threshold){
        echo "<img src=\"".EMPHASIZE_IMAGE."\" alt=\"!\" height=\"".EMPHASIZE_IMAGE_HEIGHT."\">";
    }

    echo " <a href=\"#$post->id\">Message $post->id</a> - ";
    if ($post->hidden) echo "<font color=red>[deleted] </font>";
    echo "
        Posted ", pretty_time_str($post->timestamp);
    ;

    if ($post->parent_post) echo " - in response to <a href=\"#$post->parent_post\">Message ID $post->parent_post</a>.";
    if ($can_edit && $controls != NO_CONTROLS) echo "&nbsp;<a href=\"forum_edit.php?id=$post->id\">[Edit this post]</a>";
    if (isSpecialUser($logged_in_user,0)) show_post_moderation_links($post); //If user is moderator, show links
    if ($post->modified) echo "<br>Last modified: ", pretty_time_Str($post->modified);
    if ($rated_below_threshold && $filter){
        if ($user_is_on_ignorelist) $andtext=" and the user is on your ignore list";
        echo "<br>This post has been filtered (rating: ".($post->score * $post->votes).")$andtext, press <a href=\"?id=".$thread->id."&amp;filter=false#".$post->id."\">here</a> to view this thread without filtering";
    }
    echo "\n</font></td>\n";

    if ($controls == FORUM_CONTROLS) {
        //no special controls in forum
	//echo "<td class=\"postheader\"></td>";
    } else if ($controls == HELPDESK_CONTROLS && $separate) {
        echo "
            <td align=right class=\"postheader\">
            <input type=submit name=submit value=\"", SUFFERER, "\">
            </td>
        ";
    } else if ($controls == HELPDESK_CONTROLS && !$separate) {
        echo "
            <td align='right' class='postheader'>
            <input type=submit name=submit value=\"", SOLUTION, "\">
            <input type=submit name=submit value=\"", OFF_TOPIC, "\">
            </td>
        ";
    }

    echo "</tr>\n";

    if ($controls == FORUM_CONTROLS || $controls == HELPDESK_CONTROLS) {
        echo "</form>";
    }
    echo "<tr class=\"row$n\"><td class=\"postbody\" colspan='3'>";
    //If either filtering is turned off of this post is not below the threshold
    if (!$filter || !$rated_below_threshold){

        $options = get_transform_settings_from_user($logged_in_user);

        // Include any attachments for this post (from forum_attach.php)
        $attach_text = getPostAttachment($post->id);

        $posttext = $post->content;

        // If the creator of this post has a signature and
        // wants it to be shown for this post AND the logged in
        // user has signatures enabled: show it

	$signature="";
        if ( $post->signature && !$logged_in_user->hide_signatures ){
            $signature.="\n\n  <div class='sigblock'>\n"
 	      . output_transform("____________\n".$user->signature) 
	      . "\n </div>\n";
        }

        $posttext = output_transform($posttext,$options);
        
        echo "\n" . $attach_text . $posttext . $signature . "\n";

        echo "</td></tr>\n<tr><td class=\"postfooter\">
                <font size=-2><i>ID: ", $post->id;
        if ($controls == HELPDESK_CONTROLS && $separate) {
            echo "</i></font></td>";
        } else if ($controls == HELPDESK_CONTROLS && !$separate) {
            echo " / Score: ", round(($post->score * $post->votes),0), "</i></font></td>";
        } else {


            if( user_has_permission('admin') ){
                $id=$user->id;
                echo " | Admin: <a href='" .URL_BASE. "ops/manage_user.php?userid=$id'>
                      <img src='".REPORT_POST_IMAGE."'
                           alt='Report this post as offensive'
                           title='Report this post as offensive' 
                         border=0></a>\n";
            }
            else {
                echo "	| Report: <a href=\"forum_report_post.php?post=".$post->id."\">
                      <img src='".REPORT_POST_IMAGE."'
                           alt='Report this post as offensive'
                           title='Report this post as offensive' 
                           height='".REPORT_POST_IMAGE_HEIGHT."' border=0></a></font>\n";
            }
            $rating = floor($post->score*$post->votes + 0.01);
            echo " | Rating: ", $rating, "</i> 
                   | Rate: <a href=\"forum_rate.php?post=".$post->id."&amp;choice=p\"><img
                             src=\"".RATE_POSITIVE_IMAGE."\"
                                alt=\"+\" title='rate this post as positive'
                                height=\"".RATE_POSITIVE_IMAGE_HEIGHT."\" border=0></a>
                      / <a href=\"forum_rate.php?post=".$post->id."&amp;choice=n\"><img src=\"".RATE_NEGATIVE_IMAGE."\" alt=\"-\" title='rate this post as negative'
                        height=\"".RATE_NEGATIVE_IMAGE_HEIGHT."\" border=0></a> </td>\n";
        }


        // Keyword:

        display_forum_keyword($post->keyword);

        // Reply to thread, or to THIS post:

        $link = "<a href=\"forum_reply.php?thread=" . $thread->id;
        if ($category->is_helpdesk) {
            $link = $link . "&helpdesk=1#input\">Answer this question";
        } else {
            $link = $link . "#input\">Post to thread";
        }
        $link = "[".$link."</a>]&nbsp;";

        if ($controls == FORUM_CONTROLS) {
            echo "<td align=right class=\"postfooter\">".$link."[<a href=\"forum_reply.php?thread=" . $thread->id . "&amp;post=" . $post->id . "#input\">Reply to THIS post</a>]</td>";
        } else if ($controls == HELPDESK_CONTROLS && !$separate) {
            echo "<td align=right class=\"postfooter\">".$link."[<a href=\"forum_reply.php?thread=" . $thread->id . "&amp;post=" . $post->id . "&helpdesk=1#input\">Reply to THIS answer</a>]</td>";
        } else {
	    echo "<td class=\"postfooter\"></td>";
	}
        echo "</tr>";
    }
    echo "</td></tr>";
    echo "<tr class=\"postseperator\"><td colspan='4'></td></tr>\n";
    if ($separate) {
        $headings = array(array("Author","authorcol"),
                          array("Message","titlecol' colspan='3"));
	echo "<tr class='helpdeskseperator'><td></td></tr>\n";
        start_forum_table($headings, "class='thread' width='100%' ");
    }
}

// utility functions

function start_forum_table($headings, $extra="width=100%") {
    start_table($extra." cellspacing=0");
    echo "  <tr>";

    for ($i=0; $i<count($headings); $i++) {
        if (is_array($headings[$i])){
            $title = $headings[$i][0];
            $class = $headings[$i][1];
        } else {
            $title = $headings[$i];
            $class = "heading";
        }
        echo "<th class='$class'>$title</th>";
    }
    echo "</tr>\n";
}

function end_forum_table() {
    echo "</table>\n";
}

// generate a "select" element from an array of values
//
function select_from_array($name, $array, $selection) {
    $out= "\n<select name=\"$name\">";

    foreach ($array as $key => $value) {
        $out.= "<option ";
        if ($key == $selection) {
            $out.= "selected ";
        }
        $out.= "value=\"". $key. "\">". $value. "</option>\n";
    }
    $out.= "</select>";
    return $out;
}

function show_select_from_array($name, $array, $selection) {
    echo select_from_array($name,$array,$selection);
}

// Shows the forum "title" as a hierarchical list of forum  & thread
// so user can click back up.
// I2U2 modification: don't show link to overview page, except to
// admin and dev
//
function show_forum_title($forum=NULL, $thread=NULL, $helpdesk=false) {
    echo "<p>\n";
    if (!$forum && !$thread) {
        echo "<p class=\"title\">";
        if ($helpdesk) {
            echo " Questions and problems</p>";
        } else {
            echo " Message boards</p>";
        }
    } else if ($forum && !$thread) {
//        echo "<span class=title>";
        echo "<div class=title>";
        if ($helpdesk) {
            echo "<a href=\"forum_help_desk.php\">", " Questions/Answers</a> : ";
        }
	else {
	  if( user_has_role('admin') || user_has_role('dev') ){ 
//	    echo "<a href=\"forum_index.php\">", " Discussion</a> : ";
	    echo " Discussion: ";
	  }
	  else {
            echo "Discussion: ";
	  }
        }
        echo $forum->title;
//        echo "</span><br>";
        echo "</div>";
    }
    else if ($forum && $thread) {
//LQ        echo "<span class=title>";
        echo "<div class=title>";
        if ($helpdesk) {
            echo "<a href=\"forum_help_desk.php\">", " Questions and problems</a> : ";
        } else {
	  if( user_has_role('admin') || user_has_role('dev') ){ 
//	    echo "<a href=\"forum_index.php\">", " Discussion/Logbook</a> : ";
	    echo " Discussion: ";
	  }
	  else {
            echo "Discussion: ";
	  }
        }
        echo "<a href=\"forum_forum.php?id=$forum->id\">", $forum->title, "</a> : ";
        echo cleanup_title($thread->title);
//        echo "</span><br>";
        echo "</div>";
    } else {
        echo "Invalid input to show_forum_title<br>";
    }
    echo "</p>\n";
}

// show a thread with its context (e.g. for search results)
//
function show_thread($thread, $n) {
    $forum = getForum($thread->forum);
    $category = getCategory($forum->category);

    // Is the user not logged in and the category is private?
    $logged_in_user = get_logged_in_user(false);
    if( empty($logged_in_user) && category_is_private($category->id)) return false;
    //

    $first_post = getFirstPost($thread->id);
    $title = cleanup_title($thread->title);
    $where = $category->is_helpdesk?"Questions and answers":"Message boards";
    $top_url = $category->is_helpdesk?"forum_help_desk.php":"forum_index.php";
    $excerpt = sub_sentence(stripslashes($first_post->content), ' ', EXCERPT_LENGTH, true);
    $posted = time_diff_str($thread->create_time, time());
    $last = time_diff_str($thread->timestamp, time());
    $m = $n%2;
    echo "
        <tr class=\"row$m\">
        <td><font size=\"-2\">
            $n) Posted $posted
            <br>
            Last response $last
        </td>
        <td valign=top>
            <a href=\"$top_url\">$where</a> : $category->name :
            <a href=\"forum_forum.php?id=$forum->id\">$forum->title</a> :
            <a href=\"forum_thread.php?id=$thread->id\">$title</a>
            <br>
            <font size=\"-2\">$excerpt</font>
        </td>
        </tr>
    ";
}

// show a post with its context (e.g. for search results)
//
function show_post2($post, $n) {
    $thread = getThread($post->thread);
    $forum = getForum($thread->forum);
    $category = getCategory($forum->category);

    // Is the user not logged in and the category is private?
    $logged_in_user = get_logged_in_user(false);
    if( empty($logged_in_user) && category_is_private($category->id)) return false;
    //

    $where = $category->is_helpdesk?"Questions and answers":"Message boards";
    $top_url = $category->is_helpdesk?"forum_help_desk.php":"forum_index.php";
    $content = output_transform($post->content);
    $when = time_diff_str($post->timestamp, time());
    $user = lookup_user_id($post->user);
    $title = cleanup_title($thread->title);
    $m = $n%2;
    if($post->hidden) {
        //Todo: factor this array out, it is also used elsewhere
        $deleted_text = array( "Obscene", "Flame/Hate", "Commercial spam" );
        $deleted = "<br><font color=red>[Deleted " .
                   "by a moderator as " . $deleted_text[$post->hidden-1] .
                   "] </font>";
    } else {
        $deleted = "";
    }
    echo "
        <tr class=row$m>
        <td>
            $n) <a href=\"$top_url\">$where</a> : $category->name :
            <a href=\"forum_forum.php?id=$forum->id\">$forum->title</a> :
            <a href=\"forum_thread.php?id=$thread->id\">$title</a>
            <br>
            Posted $when by $user->name $deleted
            <hr>
            $content
        </td>
        </tr>
    ";
}

function show_forum_summary($forum) {
    $latest = time_diff_str($forum->timestamp, time());
    $first_thread = getFirstThread($forum);
    if($first_thread) {
      $link = "<a href='/forum_thread.php?id=" .$first_thread->id. "'>"
		.sub_sentence($first_thread->title," ", 20, true) . "</a>";
      $latest .= "<br><font size=-3>" .$link. "</font>";
    }
    echo "
        <tr class=row1>
        <td>
            <b>
            <a href=forum_forum.php?id=$forum->id>", $forum->title,
            "</a></b>
            <br><font size=-2>", $forum->description, "
        </td>
        <td>", $forum->threads, "</td>
        <td>", $forum->posts, "</td>
        <td>", $latest, "</td>
    </tr>
    ";
}

function post_warning() {
    return "<br><br><font size=-2>
        Don't use obscene language or images,
        and don't threaten other participants;
        otherwise your message may be deleted.
	</font>\n";
}


function reply_warning(){
    $text = "<p><font color='RED' size='-2'>
       Please trim quoted material.   
       You must change [TRIM_THIS_quote] tags into [quote]
         tags (and the terminating tags too) to preserve
       quoted material.
       </font>";
    return $text;
}

 





//Generated automatically - do not edit
$cvs_version_tracker[]="\$Id: forum.inc,v 1.13 2009/05/28 16:20:54 myers Exp $";  
?>
