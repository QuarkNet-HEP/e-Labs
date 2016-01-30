<?php 
/***********************************************************************\
 * Project specific user roles for I2U2
 * 
 * This file contains specific definitions for the project.
 * See ../include/roles.php for generic support functions.
 *
 * Eric Myers <myers@spy-hill.net> - 13 February 2009
 * @(#) $Id: roles.php,v 1.4 2009/05/05 15:53:39 myers Exp $
\***********************************************************************/

// This is needed for wiki/BOINC interface 

if( !$BOINC_html ) $BOINC_html=realpath("../");

require_once("$BOINC_html/inc/forum.inc");	
require_once("$BOINC_html/include/roles.php");	// general role functions

require_once("$BOINC_html/project/i2u2-roles.php");// project roles


/***********************************************************************\
 * Forum permissions
\***********************************************************************/

/*
 * category_is_private($cat) return true if the forum category number $cat
 * is supposed to be open for reading only to authenticated members.
 * Implement your own policy here.
 */

function category_is_private($catid){

    // Pirates@Home is "normally open" - only "Crew Issues" & "World Community" are closed
    //
    if(PROJECT=="Pirates@Home"){
        return( ($catid==6 || $catid==5) ); 
    }

    // I2U2 policy is "normally closed" - only "Public Areas" is open
    //
    if(PROJECT=="I2U2") {  // I2U2 Help Desks are now OPEN -EAM 11Feb2009
        return( ($catid==20) || ($catid==21) );
    }
}


/**
 * Check a forum room/thread to see if even reading, let alone posting, is
 *  allowed. Implement your policy here.
 * TODO: does this conflict with category_is_private() 
  *	or are they complementary?
 */

function check_reading_is_allowed($logged_in_user, $forum, $thread=NULL){
    $forumid=$forum->id;

    // Administrators can read anything, even hidden threads
    if( user_has_role('admin') ) return true;


    /* Hidden thread: if the thread has been hidden, do not allow anybody to read it. */

    if( !empty($thread) && $thread->hidden) {
        error_msg("This thread has been hidden for administrative purposes.");
        return false;
    }

    /* Individual Room policy, based on user's role */

    if( PROJECT == "I2U2"){ 

        if( $forumid==49 ){ // Teacher's Lounge
            if( empty($logged_in_user) ) return false;
            if( is_HS_teacher($logged_in_user) 
                || is_Developer($logged_in_user) 
                || is_Administrator($logged_in_user)
                ) {
                return true;
            }
            else return false;
        }

        if( $forumid==51 ){ // Boiler Room (developer's only)
            if( empty($logged_in_user) ) return false;
            if( is_Developer($logged_in_user) ) return true;
            else return false;
        }

        if( $forumid==59 ){ // Evaluator's Workroom
            if( empty($logged_in_user) ) return false;
            if( user_has_role('evaluator') ) return true;
            //if( user_has_role('developer') ) return true;
            else return false;
        }

        if( $forumid==45 ){ // Cosmic Ray's Diner: QN Fellows
            if( empty($logged_in_user) ) return false;
            if( user_has_role('QN_fellow') ) return true;
            if( user_has_role('scientist') ) return true;
            if( user_has_role('admin') ) return true;
            if( user_has_role('developer') ) return true;
            error_msg("This forum is only for QuarkNet fellows, "
                      ."administrators, and developers."); 
            return false;
        }

        if( $forumid==56 ){ // SJHSRC = St. Joseph's HS Research Community

            // user must be logged in 
            if( empty($logged_in_user) ) return false; 

            // These special users can all visit:
            if( user_has_role('teacher') )   return true;
            if( user_has_role('admin') )     return true;
            if( user_has_role('developer') ) return true;
            if( user_has_role('QN_fellow') ) return true;

            // Anyone else must be a member of the SJHS team
            if( $logged_in_user->teamid == 3 ) return true;

            // TODO: generalize to show team name
            error_msg("This forum is only for members of "  
                      ."St. Josephs's HS Research Community");
            return false;
        }
    }//I2U2

    if(PROJECT == "Pirates@Home"){ 
        // no room-level restrictions yet
    }
    return true;
}



/**
 * Check to see if the user is allowed to post to a given forum, or thread 
 * of a forum.  Used for both starting a thread or replying to a post.   
 * TODO: CHANGE THIS TO RETURN TRUE/FALSE, not use error_page().

 */

function check_posting_is_allowed($logged_in_user, $forum, $thread=NULL){
    debug_msg(2,"check_posting_is_allowed(".$logged_in_user->id."," .$forumid.")" );

    if( empty($logged_in_user) ) return false;
    if ( !$forum ) return false;
    $forumid=$forum->id;
    if ( !$forumid ) return false;

    // Administrators can post anywhere!
    //
    if( user_has_role('admin') ) return true;


    // Restrictions based on category could go here.
    // (we had some in the past, but not anymore)

    $category=$forum->category;
    $catid=$category->id;

    if(0 &&  !category_is_private($catid) ){ // public?
        debug_msg(2,"This is a public forum...");
        if( !( user_has_role('teacher')
	       || user_has_role('admin') 
	       || user_has_role('developer') )
	    ){
	  debug_msg(2," ... and you are not on the list.");
          return false;
	}
	return true;
    }


    /*** Individual Room policy, based on user's role ***/

    // Teacher's Lounge is for teachers (and developers and admins)
    //
    if( $forumid==49 ){ 
      if( ! (user_has_role('teacher') || user_has_role('developer') ) )
	  return false;
    }

    // Boiler Room (developer's only)
    //
    if( $forumid==51 ){ 
      if( !user_has_role('developer') ) return false;
    }

    // Evaluator's Workroom.  No developers!
    //
    if( $forumid==59 ){ 
      if( user_has_role('evaluator') ) return true;
      else return false;
    }


    // Cosmic Ray's Diner is for QN Fellows only
    //
    if( $forumid == 45 ){ 
      if( !( user_has_role('QN_fellow')
	     || user_has_role('developer') )
	  ){
	error_msg("This forum is open only to QuarkNet fellows, "
		  . "administrators, and developers");
	return false;
      }
    }


    // Example where 'membership' in the room would be useful
    //
    if( $forumid==56 ){ // SJHSRC = St. Joseph's HS Research Community

      // These special users can all visit:
      if( user_has_role('teacher') )   return true;
      if( user_has_role('admin') )     return true;
      if( user_has_role('developer') ) return true;
      if( user_has_role('QN_fellow') ) return true;

      // Anyone else must be a member of the SJHS team
      if( $logged_in_user->teamid == 3 ) return true;
    }


    /* Is this particular forum "in the attic"?   Then no posting. */

    if( ($forum->orderID < 0 || $category->orderID < 0 ) 
        && !user_has_role('admin') ) {
        error_msg("This forum is in the attic, and so it is frozen.
             You cannot post or reply to it. ");
        return false;

    }

    /* Throttle posting rate:
     * If the user is posting faster than forum regulations allow then
     * tell the user to wait a while before creating any more posts
     */

    if( time()-$logged_in_user->last_post < $forum->post_min_interval ){
        error_msg(tr(FORUM_ERR_INTERVAL));
        return false;

    }

    /* Hidden thread:
     * If the thread has been hidden, do not display it, or allow people
     * to continue to post to it.
     */

    if( !empty($thread) && $thread->hidden) {
        error_msg("This thread has been hidden for administrative purposes.");
        return false;
    }

    return true;
}



/*******************************
 * Functions to test user's Roles. 
 *   THE OLDER WAY - PLEASE DON'T USE THESE ANYMORE.
 */

if( !function_exists('is_Administrator') ){
    function is_Administrator($user){
        $user= getForumPreferences($user);
        if( empty($user) ) return false;
        return isSpecialUser($user, S_ADMIN);
    }
 }


function user_has_permission($p){ //OLD NAME  
    return user_has_role($p);
}


function is_HS_teacher($user){
    $user= getForumPreferences($user);
    if( empty($user) ) return false;
    return isSpecialUser($user, S_HS_TEACHER);
}

function is_HS_student($user){
    $user= getForumPreferences($user);
    if( empty($user) ) return false;
    return isSpecialUser($user, S_HS_STUDENT);
}

function is_Developer($user){
    $user= getForumPreferences($user);
    if( empty($user) ) return false;
    return isSpecialUser($user, S_DEV);
}


function list_user_roles($user){
    global $special_user_bitfield;

    $list=array();

    $user= getForumPreferences($user);
    if( empty($user) ) return $list;
    
    for($i=0;$i<sizeof($special_user_bitfield);$i++){
        if( substr($user->special_user, $i,1) == 1 ){
            $list[] = $special_user_bitfield[$i];
        }
    }
    return $list;
}











?>

