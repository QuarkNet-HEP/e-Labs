<?php
/***********************************************************************\
 * Extra stuff for BOINC discussion forums
 * (beyond existing official code, for now)
 *
 *
 * @(#) $Revision: 1.3 $
\***********************************************************************/

require_once("../include/forum_attach.php");
require_once("../include/forum_keyword.php");


/** 
 * Check to see if a given variable is submitted via POST.
 * Just return true/false, not any value.
 */

function is_posted($name){
    if( !isset($_POST[$name]) ) return false;
    if( empty($_POST[$name]) ) return false;
    return true;
}



/*************************************************************************/


/**
 * Get the last post in a thread, so we can warp to it.
 * (this would go with getFirstPost() in db_forum.inc)
 */

function getLastPost($threadID) {
    if ( !is_numeric($threadID) )  return NULL;
    $sql = "SELECT * FROM post WHERE thread = " . $threadID ." ORDER BY id DESC limit 1";
    $result = mysql_query($sql);
    if ($result) return mysql_fetch_object($result);
    return NULL;
}


/**
 * Get first thread in a forum so we can say something about  it
 */

function getFirstThread($forum) {
    $id=$forum->id;
    $sql = "SELECT * FROM thread WHERE forum=" . $id. " ORDER BY timestamp DESC limit 1";
    $result = mysql_query($sql);
    if ($result) return mysql_fetch_object($result);
    return NULL;
}


/**
 * Forums: Trim stuff from forums and sigs
 */

function strip_out_images($text){ // old name
    return  strip_sig_images($text);
}

function strip_sig_images($text){
    $n=0;
    // First strip out any images beyond the first.
    // (PHP4 does not have $count parameter, so repeat enough times  )
    for($i=0; $i<10;$i++){
        $text = preg_replace('@(\[img].*\[\/img])(.*)(\[img].*\[/img])@si', '$1$2', $text);
    }
    return $text;
}


/**
 * trim_dead_quote($content) removes from the text anything between
 *   [TRIM_THIS_quote] tags, or from the beginnning up to an unclosed
 *   such tag.
 */

function trim_dead_quotes($content){
    $a = preg_replace('@\[TRIM_THIS_quote].*\[\/TRIM_THIS_quote]@si', '', $content);
    $b = preg_replace('@^.*\[\/TRIM_THIS_quote]@si', '', $a);
    return $b;
}


/**
 * Forums: Customized search box headers used in several places.
 */

function forum_search_menus(){
    echo "
   <a name='Search'>
   Search the Message Board and Help Desk areas any of these ways:
    <P>
   <TABLE ALIGN='center' VALIGN='bottom'><TR><TD>
    <form action='forum_text_search_action.php'>
      <input type='submit' value='Titles:'>
      <input name='search_string'>
        &nbsp;
      <input type='hidden' name='titles' value='Search'>
    </form>
    </TD><TD>	

    <form action=forum_text_search_action.php>
      <input type='submit' value='Text:'>
      <input name='search_string'>
        &nbsp;
      <input type='hidden' name='bodies' value='Search'>

    </form>
    </TD><TD>	

    <form action='http://www.google.com/search'>
        <input type=submit value='Google:'> 
        <input class='small' name='q' size=20>  
        &nbsp;
        <input type='hidden' name='domains' value=" .URL_BASE. ">
        <input type='hidden' name='sitesearch' value='".URL_BASE."/forum_thread.php'>
    </form>
   </TD>
    </TR></TABLE>
    ";
}


/**
 * additional warning about trimming quotes is used for replies only.
 */
function quote_warning(){
    return "<p>	<font size=-2  color='RED'>
        Please trim quoted material.   
    	You must
        change [TRIM_THIS_quote] tags into [quote]
        tags (and the terminating tags too) to preserve
	quoted material.
	</font>\n ";
}


/**
 * Return the last time there was a posting to any forum.
 * If the optional argument is true then only helpdesk forums
 * are scanned.
 */

function newest_post_time($is_helpdesk=false){
    $t_list=array();
    $sql = "SELECT * FROM forum ORDER BY timestamp DESC";  
    //echo "<br><tt>$sql</tt><br>\n";
    $result = mysql_query($sql);
    $N = mysql_num_rows($result);
    //echo "<br>Got $N records.\n"; 
    while( $forum=mysql_fetch_object($result) ) {
        //echo "<br>Forum: ". $forum->id . "(" . $forum->title .")\n";

        if( !isset($forum->timestamp) ) continue;

        // If no restriction then just use first one found
        if( !$is_helpdesk ) break; 

        // check category until we find a helpdesk
        $category = $forum->category;
        if( isset($t_list[$category]) && $t_list[$category] == 0) continue;

        $sql="SELECT * FROM category WHERE id=$category";
        //echo "<br><tt>$sql</tt><br>\n";
        $r2 =  mysql_query($sql);
        $cat = mysql_fetch_object($r2);
        $t_list[$category] = $cat->is_helpdesk;
        if( $t_list[$category] ) break;
    }
    //  echo "<br>Forum: ". $forum->id . "(" . $forum->title .")\n";
    return $forum->timestamp;
}

?>
