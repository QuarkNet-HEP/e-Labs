<?php
/***********************************************************************\
 *  Manage user 'roles', both social identification and permissions 
 * 
 *  Defines user roles and the permissions they are granted.
 *
 *  The implementation here is based on the special_users bits in 
 *  the BOINC discussion forum user preferences, and is only considered
 *  to be temporary.  
 *
 *  The "right" way to do this would be based on permissions and groups,
 *  as implemented in the MediaWiki system we use as a glossary, using
 *  database tables for group membership and individual permissions.
 *
 *
 *  Eric Myers <myers@spy-hill.net> - Fall 2006
 * @(#) $Id: roles.php,v 1.13 2009/05/28 16:20:54 myers Exp $
\***********************************************************************/


/**
 * Functions to test that the user has a particular permission/role.
 * Return true if they do, false otherwise.  When you test the return, 
 * please be sure to fail nicely if they don't, as they still might be
 * a nice person.  :-)
 *
 * This sh\c\ould be generalized to a roles-based auth system like MediaWiki,
 * using more granular permission items collected into permission groups
 * 
 * This version is specific to I2U2 .. for now.
 */

function user_has_role($p){
    // Who are you?  Must be logged in, but don't force a login if they aren't
    $logged_in_user = get_logged_in_user(false); 
    if( empty($logged_in_user) ) return false;

    // TODO: here we could check a list of roles the user has from user
    // table, instead of or before special-user bits.


    // TODO: check effective role here.


    // BOINC special user bits are in forum_prefrences
    $logged_in_user= getForumPreferences($logged_in_user);

    switch($p) {
    case 'admin':
    case 'administrator': 
        return isSpecialUser($logged_in_user, S_ADMIN);
    case 'mod':
    case 'moderator':
        return isSpecialUser($logged_in_user, S_MODERATOR); 
    case 'dev':
    case 'developer':
        return isSpecialUser($logged_in_user, S_DEV); 
    case 'teacher':
        return isSpecialUser($logged_in_user, S_HS_TEACHER); 
    case 'QN_fellow':
        return isSpecialUser($logged_in_user, S_QN_FELLOW);     
    case 'staff':
        return isSpecialUser($logged_in_user, S_QN_STAFF);     
    case 'scientist':
        return isSpecialUser($logged_in_user, S_SCIENTIST);     
    case 'evaluator':
        return isSpecialUser($logged_in_user, S_EVALUATOR);     
    case 'student':
        return isSpecialUser($logged_in_user, S_HS_STUDENT);     
    }
    return false;
}



function list_all_roles(){
    global $special_user_bitfield;
    $N = sizeof($special_user_bitfield);

    debug_msg(6,"H) There are ". $N . " roles."); 

    for($i=0;$i<$N;$i++){
        debug_msg(7,"G) Role: ".$special_user_bitfield[$i]);
        $list[] = $special_user_bitfield[$i];
    }
    return $special_user_bitfield;
}


?>
