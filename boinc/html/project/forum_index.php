<?php

// Original copied from forum_sample_index.php

require_once('../inc/forum.inc');
require_once('../inc/util.inc');
require_once('../inc/time.inc');
require_once('../project/project.inc');  // includes extras.in


function show_category($category) {
  if($category->orderID < 0 ) return;  // skip category 'in the attic'
  echo "
        <tr class=subtitle>
            <td ALIGN=CENTER class=category colspan=4><b>",
		$category->name, "</b ></td>
        </tr>
    ";

    $forums = getForums($category->id);
    while ($forum = mysql_fetch_object($forums)) {
      if($forum->orderID < 0 ) continue;   // skip forums 'in the attic'
        show_forum_summary($forum);
    }
}



function show_forums() {
	$categories = getCategories();
	while ($category = mysql_fetch_object($categories)) {
        show_category($category);
	}
}



// BEGIN:

$dbrc =  db_init_aux();

if( !user_has_role('admin') && !user_has_role('dev') ){
   error_page("You must be an <b>Administrator</b> or <b>project developer</b>"
                   ." to view this page.");
}


page_head(tr(FORUM_TITLE,PROJECT));

//show_forum_title(NULL, NULL, false);

if(1) { 

  echo "<TABLE width=100%><TR><TD>
      For <em>Questions and Answers</em> see the 
      <a href=forum_help_desk.php>Help Desk</a>
       ";

  // Signal if there are any recent posts in the Help Desk area
  //
  $t1=time();
  $t2=newest_post_time(true);

  if( ($dt = ($t1-$t2)) < 7*86400 ) {
      //      $dt = intval(($dt+20)/60) * 60;   // round to minutes
      //if($dt > 3600) $dt = intval($dt/3600) * 3600; // or hours
      echo " (<font color='ORANGE' size='-1'>Last post ";
      echo time_diff_str($t2,$t1);
      echo " </font>) ";
  }

  echo "    </TD>\n";

  // Link to description of forum restrictions

  echo "<TD><a href='forum_restrictions.php'>Description of
                forum restrictions</a></TD>\n";


  // Link to search menus, which are now at the bottom
  //
  echo "<TD align='RIGHT'>
	<a href='#Search'>Search via <i>title</i> or <i>text</i></a>
      </TD>
      </TR></TABLE>
	";
}
else {
  forum_search_menus();
}

start_forum_table(array("Topic", "Threads", "Posts", "Last post"));

show_forums();

end_table();



if(1){
  echo "\n   <p><hr>\n";
  forum_search_menus();
}
echo "<sup>*</sup>Google 
	can only search the public areas to which it has access.
      <P>\n";

page_tail();

?>
