<?php

// news_admin.php:
// Script for edit/add/delete of BOINC Project News

// Include project constants and functions
//
require_once("../inc/util_ops.inc");
require_once("../inc/news.inc");
require_once("../inc/news_ops.inc");
require_once("../project/project.inc");


// Set script logic by URL options
// - The task of current script call is set by option "modus"
// - The news item to handle is set by option "news",
//   it is >= 0  and <= number of news items

$modus = isset($_GET["modus"]) ? $_GET["modus"] : "";
$news  = isset($_GET["news"]) ? $_GET["news"] : -1;
$details  = isset($_GET["details"]) ? $_GET["details"] : "";
$filetime = isset($_GET["filetime"]) ? $_GET["filetime"] : "";
$msg  = isset($_GET["msg"]) ? $_GET["msg"] : "";
$file = isset($_GET["file"]) ? $_GET["file"] : "";

// Customizing script defaults
//
// i.e. $news_default_date = gmdate("F j, Y H:i "). "UTC";
// i.e. $news_default_date = gmdate("D, d M Y H:i:s") . ' GMT';
// i.e. $news_default_title = gmdate("F j, Y H:i "). "UTC";
// i.e. $news_default_link = MASTER_URL;
// i.e. $news_view = "details";

//$news_dateformat = "F j, Y H:i";
$news_dateformat = "F j, Y ";
$news_view = "";
$news_default_title = "";
$news_default_date = gmdate("F j, Y H:i "). "UTC";
$news_default_link = "";
$news_default_status = "none";

// selct and read newsfile - count news and get filemtime
//
$news_files =
    array("main"=>"../project/project_news.inc", 
          "old"=>"../project_news.inc");
if( array_key_exists($file, $news_files) ) {
    $news_file = $news_files["$file"];
} else {
    $news_file = $news_files["main"];
}
$news_filetime = @filemtime($news_file);


// Read in the new file to fill the new array

include($news_file);

$news_count = count($project_news);
if( $news_count < $news || $news < 0 ) {
    $news=0;
    $modus="";
}


// Get environment and init vars
//
$config = get_config();
$master_url = parse_config($config, "<master_url>");
$news_status_options = array( "none"=>"none", "hidden"=>"hidden" );
switch( $details ) {
  case "on": $news_view = "details" ; break ;
  case "off" : $news_view = "" ; break;
  default : break;
}

// Main script logic, based on URL parameter "modus"
//
switch( $modus ) {
  case "edit":
        $button = "Submit changes";
        if ($news >= 0  and $news <= $news_count) {
            news_fill_by_array($project_news, $news);
        };
        $next_modus = "wr_past_edit";
        break;
  case "delete":
        $button = "Delete this item";
        $disabled="disabled"; 
        if ($news >= 0  and $news <= $news_count) {
            news_fill_by_array($project_news, $news);
        };
        break;
  case "wr_past_delete":
        // delete a new news item to the news_array
        if( $news_filetime == $filetime ) {
            news_del_item($project_news, $news);
            $msg=news_write_file($project_news, $news_file, &$news_filetime);
            news_call_self(news_make_params(compact("details","msg","file")));
        }
        else {
            $msg = "MsgNoDelete";
        }    
        $news=0;
        $button = "Add this item";
        $modus="add";
        break;
  case "wr_past_add":
        // add a new news item to the news_array
        if( $news_filetime == $filetime ) {
            news_add_item($project_news, FALSE);
            $msg= news_write_file(&$project_news, $news_file, &$news_filetime);
            news_call_self(news_make_params(compact("details","msg","file")));
        }
	else {
            $msg = "MsgNoAdd";
        }    
        $news=0;
        $modus="add";
        $button = "Add this item";
        news_fill_by_post();
        break;
  case "wr_past_edit":
        // update news array
        if( $news_filetime == $filetime ) {
            news_edit_item($project_news, $news);
	   //function news_write_file(&$items, $file, &$news_filetime) {
            $msg=news_write_file(&$project_news, $news_file, &$news_filetime);
	   news_call_self(news_make_params(compact("details","msg","file")));
        }
	else {
            $msg = "MsgNoEdit";
        }
        $news=0;
        $modus="add";
        $button = "Add this item";
        news_fill_by_post();
        break;
  default:
        $news=0;
        $modus="add";
        $button = "Add this item";
        $date = $news_default_date;
        $title = $news_default_title;
        $link = $news_default_link;
        $status=$news_status_default;
        break;
}





// Start HTML page output
//
admin_page_head("Project News Admin");

echo "<center></enter><table border=0><tr><td colspan=2>
      <a href=\"$master_url"."rss_main.php?rss=0.91\" target=\"_new\">[RSS 0.91]</a>
      <a href=\"$master_url"."rss_main.php?rss=2.00\" target=\"_new\">[RSS 2.0]</a>
      <a href=\"$master_url\" target=\"_new\">[Mainpage]</a> ";

if( $news_view == "details" ) {
    echo "<a href=\"".$_SERVER['PHP_SELF'].
    news_make_params(array("details"=>"off","file"=>"$file")).
    "\">[Details OFF]</a> ";
}
else {
    echo "<a href=\"".$_SERVER['PHP_SELF'].
    news_make_params(array("details"=>"on","file"=>"$file")).
    "\">[Details ON]</a> ";
}

echo "<a href=\"".dirname($_SERVER['PHP_SELF']).
      "/news_admin_doc.php\" target=\"_new\">[Documentation]</a><br></td></tr>";

// display news items on the left side
//
echo "<tr><td width=\"380\" valign=\"top\">";
for ($i=0; $i<$news_count; $i++) {
  echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>";
  echo "<tr><td bgcolor=dddddd>
        <b>Item: $i </b> [<a href=./news_admin.php".news_make_params( 
           array("modus"=>"edit","news"=>"$i","details"=>"$details",
               "file"=>"$file") ).
       ">EDIT</a>] [<a href=./news_admin.php".news_make_params(
           array ("modus"=>"delete","news"=>"$i","details"=>"$details",
               "file"=>"$file") ).
       ">DELETE</a>]";
  if( $project_news[$i]["status"] == "hidden" ) {
      $temp_item = $project_news[$i];
      $temp_item["status"] = "none";
      echo " <font color=#FF0000>Status: Hidden</font>";
      echo "</td></tr>";
      echo "<tr><td valign=top>";
      rss_news_item($temp_item);    // changed from news_item()
      echo "</font>";
  } else {
      echo "</td></tr>";
      echo "<tr><td valign=top >";
      rss_news_item($project_news[$i]);    // changed from news_item()
  }
  echo "</td></tr>";
  //
  // If customized, display all fields of the single news array.
  // This maybe different form the formated output of news_item().
  //
  if ( $news_view == "details" ) {
      echo "<tr><td bgcolor=dddddd>";
      foreach ($project_news[$i] as $key => $value) {
          echo "\"<b>". $key ."</b>\"=>\"". wordwrap(htmlspecialchars($value),50,"\n",1) ."\", ";
      };
  };
  echo "</td></tr>";
  echo "</table><br>";
}

// Display edit/input form on the right side
//
echo "</td><td align=\"center\" valign=\"top\">";

// make params string for form action
//
$params = news_make_params( array("news"=>"$news", "details"=>"$details",
         "modus"=>"wr_past_$modus",
         "filetime"=>"$news_filetime",
         "file"=>"$file"));

// start form
//
echo "<form action='./news_admin.php$params'
      method='POST' name='form1'   enctype='multipart/form-data'>";

echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>";

echo "<tr><td bgcolor=ffffcc>Mode: <b>$modus";
if ($modus <> "add") echo " news #$news";
echo "</b></td>";
echo "<td align=\"right\" valign=\"top\" bgcolor=#ffffcc>Status:
      <select size=\"1\" name=\"status\" $disabled >";
     foreach( $news_status_options as $option ) {
         echo "<option value=\"$option\"";
         if( $option == $status ) echo "selected";
         echo ">$option</options>";
     }
     echo "</select></td></tr>";

if (isset($msg)) news_print_msg($msg);

echo "<tr><td valign=\"top\" align=\"center\" colspan=\"2\">";

// make params string for form reset 
//
$params = news_make_params( array("details"=>"$details","file"=>"$file") );

echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>
      <tr><td bgcolor=#ffffcc><b>Headline:</b> (<i>RSS title</i>)<br>
      <input type=\"text\" maxlength=\"99\" name=\"title\" value=\"".
     $title."\" size=\"47\"".$disabled."></td></tr></table>";

echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>
      <tr><td bgcolor=#ffffcc><b>Text:</b> (<i>RSS description</i>)<br>
      <textarea ".$disabled." name=\"description\" rows=\"15\"
      cols=\"40\">".$description."</textarea></td></tr></table>";

echo "<input type=\"submit\" value=\"$button\">";
echo "<input type=\"button\" value=\"Reset Form\" 
     onclick=document.location='./news_admin.php$params'></center><br>"; 



echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>
      <tr><td bgcolor=#ffffcc><b>Publish Date:</b> (<i>RSS PubDate</i>)<br>
      <input type=\"text\" maxlength=\"99\" name=\"date\" value=\"".
     $date."\" size=\"30\"".$disabled."><br>".
     "<font size=-1>\n".
     //gmdate("D, d M Y H:i:s",strtotime($date)).     " GMT (converted for RSS)<br>
     "Current local time: ".     date("D, d M Y H:i:s T")."<br>". 
     "Current UTC time: ".gmdate("D, d M Y H:i:s")." UTC <br>".
 //gmdate($news_dateformat)." UTC (user defined time format)<br>".
     "</font></td></tr></table>";

echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>
      <tr><td bgcolor=#ffffcc><b>Related URL:</b> (<i>RSS link</i>)<br>
      <input type=\"text\" maxlength=\"99\" name=\"link\" value=\"".
       $link."\" size=\"47\"".$disabled."><br>  ";

echo "<font size=-1>
	To reference a forum thread use: <br/>
        /forum_thread.php?id=###
	</font>
	</td></tr></table>";


echo "<table width=\"100%\" border=1 cellspacing=0 cellpadding=5>
      <tr><td bgcolor=#ffffcc><b>Author:</b> (<i>RSS author</i>)<br>
      <input type=\"text\" maxlength=\"99\" name=\"author\" value=\"".
     $author."\" size=\"47\"".$disabled."></td></tr></table>";

echo"</form></td></tr></table>";

echo "
</td></tr></table></center>";

admin_page_tail();

?>
