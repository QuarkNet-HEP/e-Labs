<?php
/***********************************************************************\
 * Post to BOINC forum (discussion room), either starting a new thread
 * or replying to a thread or a post in a thread.
 *
 * if ?id=forumid is set then this will start a new thread in that forum
 * if ?thread=thread_id is set then we reply to that thread
 * if ?post=post_id is set then we reply to that post (in some thread) 
 *
 * This version supports:
 *      - iterative editing with a preview before posting
 *      - file attachments
 *      - keyword classification
 *
 * This is a self-posting form, there is no "action" script.
 * 
 * @(#) $Id: forum_post.php,v 1.11 2009/01/21 21:31:33 myers Exp $
\***********************************************************************/

require_once('../inc/forum.inc');
require_once('../inc/util.inc');
require_once('../inc/subscribe.inc');
require_once('../inc/translation.inc');
require_once('../inc/image.inc');         // to scale images for thumbnails
require_once('../project/project.inc');   // project settings

// I2U2 additions:

require_once('../include/forum_extras.php');   
require_once('../include/forum_attach.php');
require_once('../include/forum_keyword.php');

// NOTE: interface change: second arg changed to author name!

function quote_text($text, $author="") {
    if( empty($author) ){
        $text = "[TRIM_THIS_quote]" . $text . "[/TRIM_THIS_quote]";
    }
    else {
        $text = "[TRIM_THIS_quote=$author]" . $text . "[/TRIM_THIS_quote]";
    }
    return $text;
}


/*******************************\
 * BEGIN: 
\*******************************/

db_init();

$logged_in_user = get_logged_in_user(true);  // require login to post
$logged_in_user = getForumPreferences($logged_in_user);


$parent_post = NULL;
$new_post=FALSE;
$reply_post=FALSE;
$show_full_thread=false;


$forumid = get_int("id",true);     
if( empty($forumid) ){
    $forumid = post_str('forumid',true);  // allow POST someday?
 }
$thread_id = get_int('thread',true);
if( empty($thread_id) ){
    $thread_id = post_str('thread',true);  // allow POST someday?
 }

if(get_int('post', true) ) {
    $parent_post = getPost(get_int('post',true));
}
if( empty($parent_post) ) $parent_post = getPost(post_int('post',true));



/* Starting a new thread, or replying to a thread or post? */

if( !empty($forumid) ){
    $new_post=TRUE;
    $forum = getForum($forumid);
    $thread=NULL;
 }
if ( !empty($thread_id) || !empty($parent_post) ){ //TODO: simplify?
    $reply_post=TRUE;
    if( empty($thread_id) ) { // get thread id if not given
        $thread_id=$parent_post->thread;
    }
    $thread = getThread($thread_id);
    $forum=getForum($thread->forum);
}

if( (!$new_post && !$reply_post) || ($new_post && $reply_post) ) {
    error_page("Usage:<blockquote>
        <tt>forum_post.php?id=##</tt>  - start new thread in forum ## <br>
        <tt>forum_post.php?thread=###</tt>  - reply to thread ### <br>
        <tt>forum_post.php?post=####</tt>  - reply to post #### 
        </blockquote>");
 }


// Need to know if Help Desk

$category = getCategory($forum->category);
$helpdesk=$category->is_helpdesk;


/* Check for Cancel, if so then return to thread */

if(is_posted('cancel')) {
    header('Location: forum_thread.php?id=' . $thread_id);
    exit;
 }


/* Check to see that posting is allowed by this user in this forum/thread */

if( function_exists('check_posting_is_allowed') ){
    if( !check_posting_is_allowed($logged_in_user, $forum, $thread) ){
        error_page("You are not allowed to post to this forum.");
    }
 }



/*************
 * Process user input fields (for previewing or posting)
 */

if($new_post){
  $title   = post_str("title", true);
  if( $title ) $title=cleanup_title($title);
 }
if($reply_post){ //TODO: even bother?
     $title=$thread->title;
 }

$posted  = is_posted('postit');
$previewed = is_posted('previewed',true);   // has the user previewed?
$add_signature=is_posted('add_signature');
$show_full_thread=is_posted('show_full_thread');

$content = post_str("content", true);


/* Keyword classification  */

$keyword= trim(post_str("keyword",true));   // clean?

/* Attachment, with type and caption */

$add_attachment=is_posted('add_attachment');

/* Use the default signature setting if (perhaps initial) posting is empty */

if( empty($content) && empty($keyword) && !$add_attachment ) {
    if( $logged_in_user->no_signature_by_default==0) {
        $add_signature=true;
    }
 }

/* Info about attachment file, if there is any */

if( isset($_SESSION['attach_file']) ) {  
    $attach_file= $_SESSION['attach_file'];
 }
 else {
     $attach_file = new FileAttachment();
 }

$caption=post_str("caption",true);  
$attach_file->caption=htmlentities(strip_tags($caption)); // remove any HTML



/*********************
 * If this is a reply then insert the parent text in a [quote] block
 */

if( $reply_post && empty($content) && !empty($parent_post->content) ){
    $parent_user=lookup_user_id($parent_post->user);
    $quoted_author=$parent_user->name;
    $content=cleanTextBox(quote_text(stripslashes($parent_post->content),
                                     $quoted_author));
 }

/*********************
 * Deal with file uploaded as attachment, anytime there is one.
 * We just save a copy of the file in UPLOAD_TMP_DIR until "POST"
 */

$attach_error="";

if( !$add_attachment ){ 
    $attach_file->clear(); // be sure to clear if no attachments
 }
 else {
     if( !empty($_FILES['attach_file']['name']) ){// file uploaded?
        $attach_file = save_uploaded_attachment($attach_file);
        if( empty($attach_file) && empty($attach_error) ) {
            $attach_error="File upload failed.  File too large? ";
        }
    }
 }


/* Save attachment file info while editing */

$_SESSION['attach_file'] = $attach_file;


/*********************
 * User pressed "POST", so try to post the message
 */

if( $posted && !empty($title) && !empty($content) ) {

    // New Post: create new thread:

    if( $new_post ){
        $thread_id = createThread($forumid, $logged_in_user->id,
                                  $title, $content, $add_signature );
        if( !$thread_id ) {
            error_page("Failed to create new thread.");
        }

	// Autosubscribe to help desk questions

	if( $helpdesk ){
          error_log("Subscribing user# $logged_in_user->id to thread $thread_id");
          // This is awkward, but done better in newer BOINC
	  $sql = "INSERT INTO subscriptions SET userid=" .
		  $logged_in_user->id . ", threadid=" . $thread_id;
	  //error_log("SQL: $sql");
          mysql_query($sql);
	}
    }

    // Reply post: reply to thread or parent

    if( $reply_post ){
        $parent_id=NULL;
        if($parent_post) $parent_id=$parent_post->id;

        debug_msg(1, " replyToThread($thread_id, $logged_in_user->id, $content,
                      $parent_id, $add_signature)");

        replyToThread($thread_id, $logged_in_user->id, $content,
                      $parent_id, $add_signature);
        //TODO: it would be nice if this returned $post so we can get $post->thread

        //Notify all subscribers except the user who posted (if the user has also subscribed)
        notify_subscribers($thread_id, $logged_in_user); 
    }

    /* add attachment (to last or only post) */

    $last_post =  getLastPost($thread_id);
    if( !$last_post ) {
        debug_msg(1,"Cannot find lasst post for the thread. Bummer.");
    }

    if( !empty($attach_file) && $last_post ) {
        $i = addPostAttachment($last_post, $logged_in_user, $attach_file);
        if( !$i ) {
            debug_msg(1,"Failed to add attachment to post. Dunno why.");
        }
        unset($_SESSION['attach_file']); // now forget about it
    }

    /* add keyword */

    if( $keyword && $last_post ) {
        addPostKeyword($last_post, $keyword);
    }

    /* Now go view that thread... */

    ///TODO: Keep this?
    $thread->id=$thread_id;
    setThreadLastVisited($logged_in_user,$thread);
    ///
    header('Location: forum_thread.php?id=' . $thread_id);
    exit;
 }



/***********************************************************************\
 * DISPLAY form:
\***********************************************************************/

$page_title="Forum";   //TODO: more detailed title 
if ($helpdesk) $page_title="Help Desk";
page_head($page_title);

show_forum_title($forum, NULL, $helpdesk);

if (0&&  $helpdesk) { // no need for these messages on a reply!
    //Tell people to first search for answers THEN ask the question...
    echo "<p>".sprintf(tr(FORUM_QA_POST_MESSAGE), "<b>".tr(LINKS_QA)."</b>");
    echo "<ul><li>".sprintf(tr(FORUM_QA_POST_MESSAGE2), "<b>".tr(FORUM_QA_GOT_PROBLEM_TOO)."</b>", "<b>".tr(FORUM_QA_QUESTION_ANSWERED)."</b>");
    echo "<li>".tr(FORUM_QA_POST_MESSAGE3);
    echo "</ul>".tr(FORUM_QA_POST_MESSAGE4);
 }

/* Input form: */ 

$self = $_SERVER['PHP_SELF'];
if( $new_post ) $self .="?id=".$forumid;
if( $reply_post ) {
   $self .="?thread=".$thread_id;
   if( $parent_post ) $self.="&post=".$parent_post->id;
}

echo "\n<form action='".$self."' method='POST'
            enctype='multipart/form-data'>
     <input type='hidden' name='MAX_FILE_SIZE' value= ".$max_file_size." >\n";

start_table("width='100%' class='thread' ");

if($reply_post) {
 row1("<font size='+1'><em>".$title."</em></font>");
 }



/**********************
 * Show preview of the posting so far... 
 */


$text = trim(trim_dead_quotes($content));
$previewed='yes';
if(empty($text)) $previewed='no';


if( !$posted && !empty($text) ){

    //TODO: Functionalilze this!
    // args ( $logged_in_user, $add_attachment, $attach_file, $keyword)

    $options = get_transform_settings_from_user($logged_in_user);

    echo "<tr class='postseperator'><td colspan=2>&nbsp;</td></tr>\n";
    echo "<tr class='row1'>";

    /*  User info: */

    echo "<td class='authorcol' valign='top' rowspan='2' ><font size=-2>\n";

    echo user_links($logged_in_user, URL_BASE);
    echo "<br>";
    $logged_in_user->has_avatar = ($logged_in_user->avatar != "");
    if ($logged_in_user->has_avatar && $logged_in_user->hide_avatars !=1 ) {
        echo "<img width='".AVATAR_WIDTH."' height='".AVATAR_HEIGHT."'
                src='".$logged_in_user->avatar."' alt='Avatar'><br>";
    }
    echo "Joined: ". gmdate('M j, Y', $logged_in_user->create_time).
        "<br>Posts: ".$logged_in_user->posts."<br>";
    echo "</font></td>\n";

    echo " <td class='postcontent' valign='top'>\n";

    /* Attachment: */

    if( defined('FORUM_ATTACHMENTS') ){
        if( $add_attachment && !empty($attach_file->filename)) {
            $alt=basename($attach_file->orig_filename);
            if($caption) $image_title=$caption;
            else         $image_title=$alt;
            echo attachment_view_link($attach_file,$image_title,$alt);
        }
    }

    /* Content: */

    echo "\n";
    echo output_transform($text,$options);

    if ($add_signature &&  $logged_in_user->signature ){
        echo output_transform("\n____________\n".$logged_in_user->signature);
    }

    /* Flag that the post has been previewed */ 

    echo "\n<input type='hidden' name='previewed' value= 'yes'>\n"; // flag 

    /* Keyword */

    echo "</td></tr>\n";

    if(defined('FORUM_KEYWORDS')){
        echo "<tr>";
        if($keyword) display_forum_keyword($keyword);
        echo "</tr>";
    }
    echo "<tr class='postseperator'><td colspan=2></td></tr>\n\n";
 }



/********************** 
 * Input form:
 */

$body_help = "";

if($new_post){
    if ($helpdesk) {
        row1(tr(FORUM_QA_SUBMIT_NEW)); //New question
        $submit_help = "<br>".tr(FORUM_QA_SUBMIT_NEW_HELP);
        $body_help .="<br>".tr(FORUM_QA_SUBMIT_NEW_BODY_HELP);
    }
    else {
        row1(tr(FORUM_SUBMIT_NEW)); 
        $submit_help = "";
    }
 }

// if a reply has quoted text add a warning

if($reply_post && preg_match("/TRIM_THIS/", $content)>0  ){
  $body_help.=reply_warning();
}


/* Title */

$title_error="";
if( $new_post && $posted && trim($title)=="" ) {
    $title_error="<p class='error'>* You must supply a title for
                your posting.</p>\n";
 }

if( $new_post ){
  row2_plain("<b>".tr(FORUM_SUBMIT_NEW_TITLE)."</b>".$title_error,
     "<input type='text' name='title' size=62 value='$title'>");
 }


/* Message */

$error_text="";
if( $posted && trim($content)=="" ) {
    $error_text.="<p class='error'>* You must supply text for 
               the body of your posting.</p>\n";
 }


$text="<b>".tr(FORUM_MESSAGE)."</b>".$error_text.
    html_info().post_warning();

echo "<tr><td class='authorcol'>$text</td>
        <td class='fieldvalue'>".
     "<textarea name='content' rows='12' cols='70'>$content</textarea>"
     ."<br>".$body_help. "</td></tr>\n";

/* Signature/Attachment/Keywords */

$line="<table width='100%'><tr><td>
        <input name='add_signature' type='checkbox' value='add_it' ";
if($add_signature) $line.= " CHECKED ";

$line .=" >".tr(FORUM_ADD_MY_SIG)."</td>\n";

if( defined('FORUM_ATTACHMENTS') ){
  $line.="<td><input name='add_attachment' type='checkbox' ";
  if( $add_attachment ) $line.= " CHECKED ";
  $line.=" > Add attachment  </td>\n";
 }

if( defined('FORUM_KEYWORDS') ) {
    $line .= keyword_control();  // from forum_keywords.php
 }

$line.="</tr></table>\n";
echo "<tr><td class='authorcol'><b>Settings</b></td>
          <td>$line</td></tr>\n";

/**
 * Attachments (images, data, documents)
 */


if( !defined('FORUM_ATTACHMENTS') ){
    $add_attachment=false;
 }

if( $add_attachment ){

    $text="<b>Description/Caption:</b><br> <textarea name='caption' rows='1'
                cols='70'>$caption</textarea>";

    if( !empty($attach_file->filename) ) {
        $text.="<br>File: ". $attach_file->orig_filename ;
        if( empty($attach_file->filetype) ){
            $text .="&nbsp;&divide;&nbsp; <b>Type:</b> " .
                auto_select_from_array('attach_file_type', $file_type_list,
                                       $attach_file->filetype);
        }
        else {
            $text.=" &nbsp; (<tt>".$attach_file->filetype."</tt>) &nbsp; ";
        }
        $text .="&nbsp; &divide; &nbsp;";// TODO: <br>?
        $text .="<b>Change File:</b> ";  
        $text.=" <input name='attach_file' type='file'> ";
    }
    else{
        $text .="<br><b>Select File:</b> ";
        $text.=" <input name='attach_file' type='file'> ";
    }

    if( !empty($attach_error) ) {
        $attach_error = "<br><font color='RED'>"
            .$attach_error."</font>";
    }
    row2_plain("<b>Attachments</b><br><font size=-2>
         Maximum file size is ". $max_file_size/1024 ." kilobytes.<br>
         Please include a brief description or caption.</font>"
         , $text . $attach_error );
 }

/**
 * Preview/Submit buttons.  Be sure to make the 'preview' button the first 
 * submit button on the page, so that the user pressing Enter or an 
 * auto_submit pull-down selector creates a preview instead of posting
 * the article.
 */

$buttons="<table width='100%'><tr>
   <td><input type='submit' name='preview' value='Preview'></td>
   <td align='center'> ";
if( $previewed=='yes' ) {
    $buttons .= "  <input type='submit' name='postit' value='Post'>\n";
 }
 else {
     $buttons.= "<font size=-2>You must preview your text <br>
                at least once before posting</font>";
 }
$buttons .="</td><td align='right'>
        <input type='submit' name='cancel' value='Cancel'>\n";
$buttons .=" </td></tr></table> \n";

/**
$buttons .="<center><input name='show_full_thread' type='checkbox'>
                Show full thread below</center>\n";
**/

echo "<tr><td class='authorcol'><b>Preview/Post</b><br>
        <font size=-2>Please preview before you post</font></td>
        <td> $buttons </td></tr>\n";


if($reply_post){
    row1(" <font size='+1'><em>".$title."</em></font>");
}
end_forum_table();
echo "</form>\n";


/**
 * Optional: for a reply, show the other posts in the thread
 *  (use a checkbox here some day)
 */

if( $show_full_thread && $reply_post  ){// only for replies

    $sort_style = get_str('sort', true);
    $filter = get_str('filter', true);

    if ($filter != "false"){
        $filter = true;
    } else {
        $filter = false;
    }

    if ($helpdesk) {
        if (!$sort_style) {
            $sort_style = getSortStyle($logged_in_user,"answer");
        } else {
            setSortStyle($logged_in_user,"answer", $sort_style);
        }
    } else {
        if (!$sort_style) {
            $sort_style = getSortStyle($logged_in_user,"thread");
        } else {
            setSortStyle($logged_in_user,"thread", $sort_style);
        }
    }

    if ($sort_style == NULL) {
        $sort_style = "timestamp";
    }

    if ($helpdesk) {
        $headings = array(array("Author","authorcol"), "Question","");
    } else {
        $headings = array(array("Author","authorcol"),
                          array("Message","titlecol' colspan='3"));
    }

    start_forum_table($headings, "class='thread' width='100%'");
    show_posts($thread, $sort_style, $filter, true, true, $helpdesk);
    end_forum_table();
 }
// END:



if( $debug_level>3 ) {
    echo "<blockquote><PRE>\n";
    echo print_r($attach_file, TRUE);
    echo "</pre></blockquote>\n";
 }

page_tail();


?>
