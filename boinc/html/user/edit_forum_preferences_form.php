<?php
/***********************************************************************\
 * Form to allow users to adjust discussion forum preferences.
 * See edit_forum_preferences_action.php for execution.
 *
 * From BOINC disucssion forums.
\***********************************************************************/

require_once("../inc/db.inc");
require_once("../inc/forum.inc");
require_once("../inc/util.inc");
require_once("../include/util.php");	// for get_destination()

db_init();
$user = get_logged_in_user();
$user = getForumPreferences($user);

// Is there a destination after this?
$next_url = get_destination();


page_head("Edit Discussion preferences");

echo "<script type=\"text/javascript\">
  function textCounter(field, countfield, maxlimit){
     /*
     * Input-Parameter: field name;
     * the remaining count field;
     * max. Characters.
     */
     if (field.value.length > maxlimit) // If the input length is greater than allowed
     field.value =field.value.substring(0, maxlimit); // no typing is allowed
     else
     countfield.value = maxlimit - field.value.length // the number of the remaining chars is displayed
     } 
</script>\n\n";


echo "<h1>Edit discussion forum preferences</h1> 
	Use this form to control how your information appears in the discussion forums,
     and to control how the discussion forums are displayed for you. <br>\n\n";

start_table();
echo "\n<form method=\"post\" action=\"edit_forum_preferences_action.php\"
   	    enctype=\"multipart/form-data\">\n";

if( $next_url ) {
  echo "   <input type='hidden' name='next_url' value='$next_url'>\n";
}



// Avatar (head-shot):

$has_avatar=FALSE;
if( !empty($user->avatar) && $user->avatar!="http://"){
  $has_avatar=TRUE;
}

$x="";
if( $has_avatar ){
  $x =  "  
	    <img src='".$user->avatar."' width='100' height='100'
		 align='right'>
	    <br/>
            <input type='radio' name='avatar_type' value='3'
		   checked='checked'>
    	  Use existing head-shot, as shown here.<br/>\n";
}
else {
  $zero_select=" checked='checked' ";
}


row2("<b>Head-shot</b><br><font size=-2>
	A picture of you (usually just your face) which represents you in the
	discussion forums.
	Using head-shots makes the discussion more personal.<br/>
	Note: Forced size of 100x100 pixels<br>
	Format: jpg/gif/png<br>
	Size: at most&nbsp;4k</font>",
      "$x <P>
             <input type='radio' name='avatar_type' value='0' ".$zero_select.">
		Don't use a head-shot
          <P>
          <input type='radio' name='avatar_type' value='2' ".$two_select.">
		Upload a head-shot from a file:
		<input type='file' name='picture'>\n ");

/*************NOT YET WORKING*******************
            <tr><td><input type='radio' name='avatar_type' value='1' ".$one_select.">
		Head-shot from URL: <input name='avatar_url' size=30 value='".$avatar_url."''></td></tr>
**************/



/*************OLD WAY **************
if( $has_avatar ){
    row2("Head-shot preview<br><font size=-2>
	This is how your head-shot will look</font>",
	"<img src='".$user->avatar."' width='100' height='100'>
	<tt>$user->avatar</tt>");
}
/**********************************/


// Signature:


if ($user->no_signature_by_default==0){$enable_signature="checked='checked'";} else {$enable_signature="";}
$signature=stripslashes($user->signature);
$maxlen=250;
row2("<b>Signature</b><br/> for discussion forums" . html_info().
    "<font size=-2><br>Max length (including newlines) is $maxlen chars.</font>",
    "<table><tr><td>
    <textarea name='signature' rows=4 cols=50 id='signature' onkeydown='textCounter(this.form.signature, this.form.remLen,$maxlen);'
    onkeyup='textCounter(this.form.signature, this.form.remLen,250);'>".$signature."</textarea>
    <br><input name='remLen' type='text' id='remLen' value='".($maxlen-strlen($signature))."' size='3' maxlength='3' readonly> chars remaining
    <br><input type='checkbox' name='signature_enable'  ".$enable_signature."> Attach signature by default
    </td></tr></table>");
if ($user->signature!=""){

row2("<b>Signature preview</b>".
    "<br><font size=-2>This is how your signature will look in the forums</font>",
    output_transform($user->signature)
);
}

row2("<b>Apply</b>", "<input type=submit value='Update your settings'>");


// Sorting preferences:

row2("<b>Sort styles</b><br><font size=-2>
	How to sort threads and posts in the Discussion Forums and Help Desks</font>",
    "
        <table>
            <tr><td>Discussion thread list:</td><td>".select_from_array("forum_sort", $forum_sort_styles, getSortStyle($user,"forum"))."</td></tr>
            <tr><td>Discussion posts:</td><td>".select_from_array("thread_sort", $thread_sort_styles, getSortStyle($user,"thread"))."</td></tr>
            <tr><td>Help Desk question list:</td><td>".select_from_array("faq_sort", $faq_sort_styles,  getSortStyle($user,"faq"))."</td></tr>
            <tr><td>Help Desk questions:</td><td>".select_from_array("answer_sort", $answer_sort_styles,  getSortStyle($user,"answer"))."</td></tr>
        </table>"
);



// Pop-ups, links, etc...

if ($user->link_popup==1){$forum_link_externally="checked='checked'";} else {$forum_link_externally="";}
if ($user->images_as_links==1){$forum_image_as_link="checked='checked'";} else {$forum_image_as_link="";}
if ($user->jump_to_unread==1){$forum_jump_to_unread="checked='checked'";} else {$forum_jump_to_unread="";}
if ($user->ignore_sticky_posts==1){$forum_ignore_sticky_posts="checked='checked'";} else {$forum_ignore_sticky_posts="";}

$forum_minimum_wrap_postcount = intval($user->minimum_wrap_postcount);
$forum_display_wrap_postcount = intval($user->display_wrap_postcount);

row2("<b>Display and Behavior</b>".
     "<br><font size=-2>How to treat links and images in the forums
	and how to deal with unread posts</font>",
     "<table><tr><td>
        <input type='checkbox' name='forum_images_as_links' ".$forum_image_as_link."> Show images as links<br>
        <input type='checkbox' name='forum_link_externally' ".$forum_link_externally."> Open links in new window/tab<br>
        <input type='checkbox' name='forum_jump_to_unread' ".$forum_jump_to_unread."> Jump to first new post in thread automatically<br>
        <input type='checkbox' name='forum_ignore_sticky_posts' ".$forum_ignore_sticky_posts.">Do not reorder sticky posts<br>
	<br />
	If a thread contains more than 
	<input type='text' name='forum_minimum_wrap_postcount' style='width: 30px;' value='".$forum_minimum_wrap_postcount."'> 
	posts, <br>
	only display the first one and the 
	<input type='text' name='forum_display_wrap_postcount' style='width: 30px;' value='".$forum_display_wrap_postcount."'> 
	 last ones.
      </td></tr></table>"
);


// Filtering:

if ($user->hide_avatars==1){$forum_hide_avatars="checked='checked'";} else {$forum_hide_avatars="";}
if ($user->hide_signatures==1){$forum_hide_signatures="checked='checked'";} else {$forum_hide_signatures="";}
$forum_low_rating_threshold= $user->low_rating_threshold;
$forum_high_rating_threshold= $user->high_rating_threshold;

row2("<b>Filtering</b>".
    "<br><font size=-2>What to display. 
	If you set both your high and low thresholds to 0 or empty they will 
	reset to the default values</font>",
    "<table><tr><td>
        <input type='checkbox' name='forum_hide_avatars' ".$forum_hide_avatars."> Hide head-shot images<br>
        <input type='checkbox' name='forum_hide_signatures' ".$forum_hide_signatures."> Hide signatures<br>
    </td></tr></table>
    <table width='380'>
	<tr><td width='32' valign=TOP><input type='text' name='forum_low_rating_threshold' 
		value='".$forum_low_rating_threshold."' style='width: 30px;'></td>
	<td>Filter threshold (default: ".DEFAULT_LOW_RATING_THRESHOLD.")
	Anything rated lower than the filter threshold will be filtered 
	</td></tr>
        <tr><td valign=TOP><input type='text' name='forum_high_rating_threshold' 
		value='".$forum_high_rating_threshold."' style='width: 30px;'>
	<td>Emphasize threshold (default: ".DEFAULT_HIGH_RATING_THRESHOLD.")
	Anything rated higher than the emphasize threshold will be emphasized.
	</td></tr>
    </table>
    "
);

$filtered_userlist=explode("|",$user->ignorelist);
for ($i=1;$i<sizeof($filtered_userlist);$i++){
    $filtered_user = lookup_user_id($filtered_userlist[$i]);
    $forum_filtered_userlist.="<input type ='submit' name='remove".trim($filtered_userlist[$i])."' value='Remove'> ".$filtered_userlist[$i]." - ".user_links($filtered_user,URL_BASE)."<br>";
}

/*************************
 * User filtering disabled for I2U2 (initially) -EAM 06Jun2009

row2("<b>Filtered users</b>".
    "<br><font size=-2>Ignore specific users.<br>
	You can define a list of users to ignore.
	These users will have to write posts with very high rating in order 
	to not be filtered.</font>",
    "<table><tr><td>
	$forum_filtered_userlist
    </td></tr></table>
    <table width='380'>
	<tr><td width='32'><input type='text' name='forum_filter_user' style='width: 80px;'></td><td>Userid (For instance, yours is ".$user->id.")</td></tr>
	<tr><td colspan='2'><input type='submit' name='add_user_to_filter' value='Add user to filter'></td></tr>
	<tr><td colspan=2>
	    Please note that you can only filter a limited number of users.
	</td></tr>	
    </table>
    "
);
***************************/

row2("<b>Apply</b>", "<input type=submit value='Update your settings'>");

echo "</form>\n";

row2("<b>Reset preferences</b>
      <br><font size=-2>
     Use this button to reset your discussion forum preferences to the defaults</font>",
    "<form method=\"post\" action=\"edit_forum_preferences_action.php\">
     <input type=\"submit\" value=\"Reset preferences\">
     </form>");


end_table();
page_tail();
?>
