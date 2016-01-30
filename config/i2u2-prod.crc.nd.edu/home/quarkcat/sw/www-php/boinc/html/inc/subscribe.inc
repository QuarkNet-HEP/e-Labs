<?php

require_once('../inc/email.inc');
require_once('../inc/forum.inc');
require_once('../inc/util.inc');


function subscribe($thread, $user=null) {
    if (!$thread) {
        show_result_page("subscribe", false, NULL);
        exit();
    }

    if (!$user) {
        $user = get_logged_in_user(true);
    }

    $sql = "INSERT INTO subscriptions SET userid = " . $user->id . ", threadid = " . $thread->id;
    show_result_page("subscribe", (mysql_query($sql) != null), $thread);
}

function unsubscribe($thread, $user=null) {
    if (!$thread) {
        show_result_page("unsubscribe", false, NULL);
        exit();
    }
    if (!$user) {
        $user = get_logged_in_user(true);
    }
    $sql = "DELETE FROM subscriptions WHERE (userid = ". $user->id . ") AND (threadid = " . $thread->id . ")";
    show_result_page("unsubscribe", (mysql_query($sql) != null), $thread);

}

function show_result_page($action, $success, $thread) {



    if ($action == "subscribe" && $success) {
        page_head("Subscription Successful");

       echo "<div id=\"maincontent\">";  //lq


//        echo "<span class=\"title\">Subscription successful</span>";
        echo "<div class=\"title\">Subscription successful</div>";
        echo "<p>You are now subscribed to <b>", stripslashes($thread->title), "</b>.  You will receive an email whenever another user posts to this thread.</p>";
    } else if ($action == "unsubscribe" && $success) {
        page_head("Unsubscription Successful");

        echo "<div id=\"maincontent\">";  //lq

//        echo "<span class=title>Unsubscription successful</span>";
        echo "<div class=title>Unsubscription successful</div>";
        echo "<p>You have successfully unsubscribed from <b>", stripslashes($thread->title), "</b>.  You will no longer receive emails for posts to this thread.</p>";
    } else if ($action == "subscribe" && !$success) {
        page_head("Subscription Failed");
        echo "<div id=\"maincontent\">";  //lq
//        echo "<span class=title>Subscription failed</span>";
        echo "<div class=title>Subscription failed</div>";
        if ($thread) {
            echo "<p>There was a problem subscribing you to ", stripslashes($thread->title), ".  Please try again later.</p>";
        } else {
            echo "<p>The thread you tried to subscribe to does not exist.</p>";
        }
    } else if ($action == "unsubscribe" && !$success) {
        page_head("Unsubscription Failed");
        echo "<div id=\"maincontent\">";  //lq
        echo "<span class=\"title\">Unsubscription failed</span>";
        echo "<div class=\"title\">Unsubscription failed</div>";
        if ($thread) {
            echo "<p>There was a problem unsubscribing you from ", stripslashes($thread->title), ".  Please try again later.</p>";
        } else {
            echo "<p>The thread you tried to unsubscribe from does not exist.</p>";
        }
    } else {
        page_head("Unknown action");
        echo "<div id=\"maincontent\">";  //lq
//        echo "<span class=\"title\">Unknown action</span>";
        echo "<div class=\"title\">Unknown action</div>";
        echo "<p>The action you requested is not known</p>";
    }

    echo "<a href=forum_thread.php?id=$thread->id>Return to thread</a>";

    echo "<br /><br /></div>"; //lq

//    page_tail();

}

/**
 * Notify everyone who has subscriped except the user object specified in the optional
 * parameter $except_user.
 **/
function notify_subscribers($threadID, $except_user=null) {
    if ($except_user){
	$extra = " and userid!=".intval($except_user->id);
    } else {
	$extra = "";
    }
    $sql = "SELECT DISTINCT * FROM subscriptions WHERE threadid = " . $threadID.$extra;
    $result = mysql_query($sql);

    while ($row = mysql_fetch_object($result)) {
        send_notice_email($row->userid, $threadID);
    }

}

function send_notice_email($userId, $threadID) {
    $thread = getThread($threadID);

    $result = mysql_query("SELECT * FROM user WHERE id = $userId");
    $user = mysql_fetch_object($result);

    $title = PROJECT . ": A user has posted to your subscribed thread.";
    $link = URL_BASE . "forum_thread.php?id=" . $threadID;
    $body = "Another " . PROJECT . " user has posted to the thread\n  \""
		. stripslashes($thread->title) . "\".\n\n"
        ."To view the updated thread, visit the following URL:\n  $link";

    send_email($user, $title, $body);
}

?>
