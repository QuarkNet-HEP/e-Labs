<?php
/***********************************************************************\
 * logout.php - drop authentication credentials
 *
 * The authentication system used here (now, at least) is based on the
 * same mechanism used by BOINC for the discussion forums.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 12 December 2006
 * @(#) $Id: logout.php,v 1.14 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general TLA utilities


/* Wiki prefix for clearing cookies */

$wiki_prefix='i2u2_glossary';

function my_clear_cookie($name,$domain=''){ // our own function for this page
    setcookie($name, "", time()-86400, "/",$domain);
    if( isset($_COOKIE[$name]) ) unset($_COOKIE[$name]);
}


/***********************************************************************\
 * Action:
\***********************************************************************/

// clear all AUTH cookies

my_clear_cookie('auth');
my_clear_cookie('boinc_auth');
my_clear_cookie('i2u2_auth');
my_clear_cookie($wiki_prefix."UserID");
my_clear_cookie($wiki_prefix."UserName");

// General spy-hill cookies (which let you in to Bluestone)
//
my_clear_cookie('pirates_auth',".spy-hill.net");   // beta test crew
my_clear_cookie('i2u2_auth',".spy-hill.net");   


if( !isset($_SESSION) ) session_start();

$sid= session_id();
if( !empty($sid)) my_clear_cookie($sid);

/* Are we logged in via HTTP Basic auth?  Then save info, as you cannot
    really log out from that this way */

$basic_auth = prev_HTTP_auth();
if($basic_auth){
  $u = $_SESSION['PHP_AUTH_USER'];
  $p = $_SESSION['PHP_AUTH_PW'];
 }

/* Clear session */

$_SESSION=array();

if( $basic_auth ){
    if( !$_SESSION ) session_start();
    session_regenerate_id();
    $_SESSION['AUTH_TYPE']='Basic';
    $_SESSION['PHP_AUTH_USER']=$u;
    $_SESSION['PHP_AUTH_PW']=$p;

    add_message("You were logged in using HTTP Basic authentication.");
    add_message("To complete the logout process you need to close your
                browser. ", MSG_ERROR);
    add_message("Until then you will remain logged in.",
                MSG_WARNING);
 }
 else {
    add_message("You are now logged out");
 }


/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="Logout";
html_begin($title);
title_bar($title);

controls_begin();

echo "You may now:
  <UL>
    <LI>Go to the <a href='../'>Main Page </a>
    <P>
    <LI>Start a <a href='index.php'>New Analysis</a>
  </UL>
";


controls_end();

/*******************************
 * DONE:
 */

tool_footer();
html_end();

/* You cannot really log-out from HTTP Basic auth except by closing your
 * browser.  So to indicate this we start a new session with the existing
 * auth tokens, since you are really still logged in.
 */

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: logout.php,v 1.14 2009/04/29 20:43:24 myers Exp $";
?>
