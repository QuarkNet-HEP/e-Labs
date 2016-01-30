<?php
/***********************************************************************\
 * Functions to support keyword classification of forum posts in BOINC
 *
 * Use keyword_control() when composing a forum post to offer the author
 * a pull-down menu for classification of the post.  The available options
 * should be in the array $post_keywords, else defaults are used.
 * 
 *
\***********************************************************************/

require_once("../project/extras.php");  // for auto_select_from_array()

/**
 * create a control for selecting a keyword
 */

function keyword_control(){
    global $post_keywords;

    if( empty($post_keywords) ) {
        $post_keywords=array_of_values(
            array(" ", "calibration", "commissioning", "DAQ", "DQflag", "DMT",
                "filter_design", "injections", "microseism", "tides"));
    }

    $keyword="";
    if( array_key_exists('keyword',$_POST) ){
      $keyword= $_POST['keyword'];  // selected value is new default
    }

    $text = "<td align='right'><b>Keyword:</b> ".
        auto_select_from_array('keyword', $post_keywords, $keyword)."\n</td>\n";
    return $text;
}


/**
 * Handle keyword send as input
 */

function handle_posted_keyword(){
    if( !isset($_POST['keyword']) ) return "";
    $keyword= trim($_POST['keyword']);  
    return $keyword;
}

/**
 * Display a keyword in a posting (in postfooter line)
 */

function display_forum_keyword($keyword){
    if($keyword) $text="Keyword: $keyword";
    else $text="&nbsp;";
    echo "<td class='keyword, postfooter' width='25em' align='center' >
                <font size=-2><i>" .$text. "</i></font></td>\n";
}


//
/**
 * Add keyword to a posting in database
 */

function addPostKeyword($post, $keyword){
    if(!$post || !$keyword) return;

    $postid=$post->id;
    if( !is_numeric($postid) ) return;

    $k=mysql_real_escape_string($keyword);

    $sql = "UPDATE post SET keyword='".$k."' WHERE id=$postid";
    mysql_query($sql);
    $i = mysql_insert_id();
    return $i;
}

?>
