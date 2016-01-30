<?php
/***********************************************************************\
 * BOINCAuthPolicy() function for I2U2 "library" wiki
 * 
 * Sets permission group membership on the wiki based on special user
 * status in the BOINC project.
 *
 * You also need to set permissions for these groups in the file
 * LocalSettings.php on the wiki (or the file UserPermissions.php
 * which it includes.)
 *
 * Put this in PROJECT/html/project or set $BOINChtml in BOINCAuthPlugin.php
 * to the directory above a directory called "project"
 *
 * Eric Myers <myers@spy-hill.net> - 5 February 2007
 * @(#) $Id: BOINCAuthPolicy.php,v 1.2 2009/06/24 17:44:31 myers Exp $
\***********************************************************************/
/* Copyright (c) 2009 by Eric Myers;  all rights reserved
 *
 * Distribution of this file is covered by the MIT License, as follows:
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
\***********************************************************************/

//$debug_level=3;

// This is needed for wiki/BOINC interface

if( !$BOINC_html ) $BOINC_html="..";

// List of all user roles in the Forums, and functions to test for them
//
require_once("$BOINC_html/project/i2u2-roles.php");

if( $debug_level ){
  require_once("$BOINC_html/include/debug.php");
 }


// Check if user has special user bit enabled 
//
if( !function_exists('isSpecialUser') ) {
  function isSpecialUser($boinc_user, $specialbit){
      debug_msg(3,"isSpecialUser(): ".$boinc_user->name
		." has bits ". $forum_prefs->special_user);
      return (substr($boinc_user->special_user, $specialbit,1)==1);
  }
  debug_msg(1,"I had to define my own isSpecialUser()");
 }

// Add/remove user from wiki group based on BOINC special user bit
//
function add_remove_group($boinc_user, $user, $special_id, $group){
  if( isSpecialUser($boinc_user, $special_id) ){
    debug_msg(2,"Add user ".$boinc_user->name." to group $group"); 
    $user->addGroup($group);        
  }
  else {
    $user->removeGroup($group); 
    debug_msg(2,"Remove user ".$boinc_user->name." from group $group"); 
  }
}


// This function is called by the authentication interface
// to determine user authorization policy.  The first argument is
// the BOINC user object, the second is the user object for the wiki
//
function BOINCAuthPolicy($boinc_user, $user){

  /* Group assignment based on forum "special user" bits 
   * These are no longer exclusive; one can be in several groups */ 

  $forum_preferences =  getUserPrefs($boinc_user->id);
  if( empty($forum_preferences) ){
    debug_msg(1, "User: ".$boinc_user->name." has no forum preferences.");
    log_error("User: ".$boinc_user->name." has no forum preferences.");
  }
  if( !empty($forum_preferences) ){
    $boinc_user->special_user = $forum_preferences->special_user;
    debug_msg(3,"add/remove for ".$boinc_user->name
		." / ". $boinc_user->special_user);

    add_remove_group($boinc_user,$user,S_ADMIN,'admin');
    add_remove_group($boinc_user,$user,S_DEV,'dev');

    add_remove_group($boinc_user,$user,S_QN_FELLOW,'elab_fellow');
    add_remove_group($boinc_user,$user,S_QN_FELLOW,'fellow');

    add_remove_group($boinc_user,$user,S_HS_TEACHER,'teacher');
    add_remove_group($boinc_user,$user,S_HS_STUDENT,'student');

    /* BOINC users who are 'banned' or suspended from the BOINC 
     * discussion forums are "in a timeout" here */

    $t = $forum_preferences->banished_until ;
    if( $t ){
      if( $t > time() ) {
	$user->addGroup('timeout');        
      }
      else {
	$user->removeGroup('timeout'); 
      }
    }
  }// forum_preferences
}

?>
