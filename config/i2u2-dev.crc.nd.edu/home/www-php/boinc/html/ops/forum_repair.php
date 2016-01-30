<?php

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/ops.inc");

cli_only();
db_init_cli();

set_time_limit(0);


// activate/deactivate script
if (0) {
  echo "
This script needs to be activated before it can be run.
Once you understand what the script does you can change the 
if (1) to if (0) at the top of the file to activate it.
Be sure to deactivate the script after using it to make sure
it is not accidentally run. 
";
  exit;
}


function update_thread_timestamps() {
  $result = mysql_query("SELECT * from thread");
  while ($thread = mysql_fetch_object($result)) {
    if (0) {
      $q = "SELECT min(timestamp) AS foo FROM post WHERE thread=$thread->id";
      $r2 = mysql_query($q);
      $m = mysql_fetch_object($r2);
      echo "id: $thread->id; min: $m->foo\n";
      mysql_free_result($r2);
      $n = $m->foo;
      if ($n) {
	$q = "UPDATE thread SET create_time=$n WHERE id=$thread->id";
	mysql_query($q);
      }
    }
    $q = "SELECT max(timestamp) AS foo FROM post WHERE thread=$thread->id";
    $r2 = mysql_query($q);
    $m = mysql_fetch_object($r2);
    echo "id: $thread->id; min: $m->foo\n";
    mysql_free_result($r2);
    $n = $m->foo;
    if ($n) {
      $q = "UPDATE thread SET timestamp=$n WHERE id=$thread->id";
      mysql_query($q);
    }
  }
  mysql_free_result($result);
}

function update_user_posts() {
    $result = mysql_query("SELECT * FROM user");
    while ($user = mysql_fetch_object($result)) {
        $q = "SELECT count(*) AS num FROM post WHERE user=$user->id";
        $r2 = mysql_query($q);
        $m = mysql_fetch_object($r2);
        mysql_free_result($r2);
        if ($m->num != $user->posts) {
            echo "user $user->id: $user->posts $m->num\n";
            $q = "UPDATE user SET posts=$m->num WHERE id=$user->id";
            mysql_query($q);
        }
    }
    mysql_free_result($result);
}





// Repair the reply count for a thread by explicitly counting posts

function update_thread_count() {
    $result = mysql_query("SELECT * FROM thread");
    while ($thread= mysql_fetch_object($result)) {
      $id = $thread->id;
      $replies = $thread->replies;
      $q = "SELECT count(*) AS num FROM post WHERE thread=$id";
      $r2 = mysql_query($q);
      $m = mysql_fetch_object($r2);
      mysql_free_result($r2);
      $posts = $m->num;
      if ( $posts != $replies+1 ) {
        $N = $replies+1;
	echo "Thread $id: $posts posts (was showing $N) \n";
        $N = $posts -1;
        if($N < 0) $N = 0;
	$q = "UPDATE thread SET replies=$N WHERE id=$id";
         echo "  >> mysql_query($q)\n";
         mysql_query($q);
        }
    }
    mysql_free_result($result);
}



// Update forum timestamps too (after the thread timestamps have been
// updated!)  

function update_forum_timestamps() {
  $result = mysql_query("SELECT * from forum");
  while ($forum = mysql_fetch_object($result)) {
    $q = "SELECT max(timestamp) AS last FROM thread WHERE forum=$forum->id";
    $r2 = mysql_query($q);
    $th = mysql_fetch_object($r2);
    mysql_free_result($r2);
    $n = $th->last;
    if ($n) {
      //echo "id: $forum->id; min: $m->foo\n";
      $q = "UPDATE forum SET timestamp=$n WHERE id=$forum->id";
      mysql_query($q);
    }
  }
  mysql_free_result($result);
}



// Do it:

update_thread_count();
update_thread_timestamps();
update_forum_timestamps();
update_user_posts();

?>

