<?php
/***********************************************************************\
 * edit_forum_preferences_action.php -- handle preferences form
 * 
 * From BOINC (http://boinc.berkeley.edu) with local modifications
 * @(#) $Id:$
\***********************************************************************/

require_once("../inc/db.inc");
require_once("../inc/user.inc");
require_once("../inc/profile.inc");
require_once("../inc/util.inc");
require_once("../inc/image.inc");
require_once("../inc/forum.inc");

require_once("../include/util.php");	// for get_destination

/*********************
 * Need this because register_globals is off by default in PHP 4.2.0
 *  and beyond, as it well should be. -EAM 06Jan2005
 * (That means this code is really, really old!) 
 */

$HTTP_POST_VARS=$_POST;  // register_globals is off!

/*********************/


db_init();
$user = get_logged_in_user();
$user = getForumPreferences($user);

$next_url=get_destination();  // anywhere we should end up?

$avatar_url = mysql_real_escape_string($_POST["avatar_url"]);
if (substr($avatar_url,0,4) !="http") $avatar_url="http://".$avatar_url;
$newfile=IMAGE_PATH.$user->id."_avatar.jpg";
$avatar_type = intval($_POST["avatar_type"]);
if ($avatar_type<0 or $avatar_type>4) $avatar_type=0;


// They uploaded a picture.  Then assume it's for an avatar.

if( $_FILES['picture']['tmp_name']!="" ) {
  $avatar_type=2;
}

if ($avatar_type==0){ // no avatar
    if( file_exists($newfile) ){
        unset($newfile);      //Delete the file on the server if the user
                              //decides not to use an avatar
                              // - or should it be kept?
    }
    $avatar_url="";
}

if ($avatar_type==1){
  //TODO: go grab it via URL
}

if( $avatar_type==2 ){// UPLOAD IT
    if ($_FILES['picture']['tmp_name']!=""){
            $file=$_FILES['picture']['tmp_name'];
        $size = getImageSize($file);
        if ($size[2]<1 and $size[2]>3){
            //Not the right kind of file
            echo "Error: Not the right kind of file, only PNG, JPEG, and GIF  are supported.";
            exit();
        }
        $width = $size[0];
        $height = $size[1];
        $image2 = intelligently_scale_image($file, 100, 100);
        ImageJPEG($image2, $newfile);
    }
    if (file_exists($newfile)){
        $avatar_url=IMAGE_URL.$user->id."_avatar.jpg"; //$newfile;
    } else {
        //User didn't upload a compatible file or it went lost on the server
        $avatar_url="";
    }
}


$image_as_link = ($HTTP_POST_VARS["forum_images_as_links"]!="");
$link_externally = ($HTTP_POST_VARS["forum_link_externally"]!="");
$hide_avatars = ($HTTP_POST_VARS["forum_hide_avatars"]!="");
$hide_signatures = ($HTTP_POST_VARS["forum_hide_signatures"]!="");
$jump_to_unread = ($HTTP_POST_VARS["forum_jump_to_unread"]!="");
$ignore_sticky_posts = ($HTTP_POST_VARS["forum_ignore_sticky_posts"]!="");
$low_rating_threshold = intval($HTTP_POST_VARS["forum_low_rating_threshold"]);
$high_rating_threshold = intval($HTTP_POST_VARS["forum_high_rating_threshold"]);
$add_user_to_filter = ($HTTP_POST_VARS["add_user_to_filter"]!="");
$minimum_wrap_postcount = intval($HTTP_POST_VARS["forum_minimum_wrap_postcount"]);
$display_wrap_postcount = intval($HTTP_POST_VARS["forum_display_wrap_postcount"]);

$no_signature_by_default=($HTTP_POST_VARS["signature_enable"]=="");
$signature = sanitize_html(stripslashes($HTTP_POST_VARS["signature"]));
//// remove image tags from signatures
$signature = strip_out_images(sanitize_html(stripslashes($_POST["signature"])));
////
if (strlen($signature)>250) {
    echo "You signature was too long, please keep it less than 250 chars";
    exit();
}
$signature = mysql_real_escape_string($signature); 

$forum_sort = $HTTP_POST_VARS["forum_sort"];
$thread_sort = $HTTP_POST_VARS["thread_sort"];
$faq_sort = $HTTP_POST_VARS["faq_sort"];
$answer_sort = $HTTP_POST_VARS["answer_sort"];
$forum_sorting=mysql_real_escape_string(implode("|",array($forum_sort,$thread_sort,$faq_sort,$answer_sort)));
$has_prefs=mysql_query("select * from forum_preferences where userid='".$user->id."'");

$ignorelist = $user->ignorelist;
if ($add_user_to_filter){					//see if we should add any users to the ignorelist
    $user_to_add = trim($HTTP_POST_VARS["forum_filter_user"]);
    if ($user_to_add!="" and $user_to_add==strval(intval($user_to_add))){
	$ignorelist.="|".$user_to_add;
    }
}

$ignored_users = explode("|",$ignorelist);			//split the list into an array
$ignored_users = array_unique($ignored_users);			//a user can only be on the list once
natsort($ignored_users);					//sort the list by userid in natural order
$ignored_users=array_values($ignored_users);			//reindex
$real_ignorelist = "";
for ($i=1;$i<sizeof($ignored_users);$i++){
    if ($ignored_users[$i]!="" and $HTTP_POST_VARS["remove".trim($ignored_users[$i])]!=""){
	//this user will be removed
    } else {
	//the user should be in the new list
	$real_ignorelist.="|".$ignored_users[$i];
    }
}

if ($minimum_wrap_postcount<0) $minimum_wrap_postcount=0;
if ($display_wrap_postcount>$minimum_wrap_postcount) $display_wrap_postcount=round($minimum_wrap_postcount/2);
if ($display_wrap_postcount<5) $display_wrap_postcount=5;


// Apply Database update


$result = mysql_query(
    "UPDATE forum_preferences SET 
        avatar='".$avatar_url."', 
        images_as_links='".$image_as_link."', 
        link_popup='".$link_externally."', 
        hide_avatars='".$hide_avatars."', 
        no_signature_by_default='".$no_signature_by_default."', 
        ignore_sticky_posts='".$ignore_sticky_posts."', 
        signature='$signature',
        jump_to_unread='".$jump_to_unread."',
        hide_signatures='".$hide_signatures."',
        low_rating_threshold='".$low_rating_threshold."',
	ignorelist='".$real_ignorelist."',
        high_rating_threshold='".$high_rating_threshold."',
	minimum_wrap_postcount='".$minimum_wrap_postcount."',
	display_wrap_postcount='".$display_wrap_postcount."'
    WHERE userid=$user->id"
);



// TODO: if $next_url is set then go there instead
//         (this is all a bit crude)   -EAM 06Jun2009

if( empty($next_url) ) $next_url = "edit_forum_preferences_form.php";

if ($result) {
    echo mysql_error();
    Header("Location: $next_url");
} 
else {
    page_head("Forum preferences update");
    echo "Couldn't update forum preferences.<br>\n";
    echo mysql_error();
    page_tail();
}

?>
