<?php

require_once('../inc/util.inc');
require_once('../inc/time.inc');
require_once('../inc/forum.inc');
require_once('../inc/user.inc');
require_once('../inc/db.inc');
require_once('../project/project.inc'); // for category privacy policy

db_init();

$userid = get_int("userid");
$offset = get_int("offset", true);
if (!$offset) $offset=0;
$hide = true;
$count = 10;

$user = lookup_user_id($userid);
$logged_in_user = get_logged_in_user(true);
$logged_in_user = getForumPreferences($logged_in_user);

if( $logged_in_user ) {
    if ($user->id==$logged_in_user->id ||  isSpecialUser($logged_in_user,0)) {
        $hide = false;
    }
}

page_head("Posts by $user->name");

if($hide) {
    $result = mysql_query("SELECT * FROM post
        WHERE user=$userid
        AND   hidden=0
        ORDER BY score, timestamp DESC LIMIT $offset,$count"
    );
} else {
    $result = mysql_query("SELECT * FROM post
        WHERE user=$userid
        ORDER BY score, timestamp DESC LIMIT $offset,$count"
    );
}
$n = 0;
start_table();
while ($post = mysql_fetch_object($result)) {
    show_post2($post, $n+$offset+1);
    $n++;
}
echo "</table>\n";
mysql_free_result($result);

if ($n == $count) {
    $offset += $count;
    echo "
        <br><br>
        <a href=forum_user_posts.php?userid=$userid&offset=$offset><b>Next $count posts</b></a>
    ";
}

page_tail();
?>
