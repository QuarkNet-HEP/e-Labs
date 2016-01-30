<?php
/***********************************************************************\
 * Log the user off by removing all cookies and deleting all authentication 
 * tokens.  Note: you must not emit *any* output before the headers
 *  which set the cookies, or they will not actually be set (cleared).
 *
 * @(#) $Id: logout.php,v 1.4 2008/06/18 18:45:07 myers Exp $
\***********************************************************************/

include_once("../inc/db.inc");
include_once("../inc/util.inc");

$wiki_prefix="i2u2_wiki";


/********************
 * Action:
 */

db_init();
$user = get_logged_in_user(false);

if( !$user ) {
    error_page("You are already logged off.");
 }


// Page to go to afterward, if specified
//
if( isset($_GET["next_url"]) )  $next_url = $_GET["next_url"];
if( !$next_url && isset($_POST["next_url"]) ) {
    $next_url = $_POST['next_url'];
 }
//TODO: forward this to Rytis.  
if( $next_url ) $next_url= str_replace("'", "%27", $next_url);

clear_cookie('auth');
clear_cookie('boinc_auth');
clear_cookie('i2u2_auth');

// MediaWiki authentication
//
clear_cookie($wiki_prefix."UserID");
clear_cookie($wiki_prefix."UserName");

// General spy-hill cookie (which lets you in to Bluestone, etc)
//
setcookie('i2u2_auth', "",  time()-42000, '/', '.spy-hill.net');

// e-Lab JSP session

clear_cookie('JSESSIONID');


session_destroy();      // clears the cookie
$_SESSION = array();    // clears the session
$_COOKIE=array();       // clear for this session

$user=NULL;
$authenticator=NULL;

// Final destination
//
if (strlen($next_url) >0) {
  Header("Location: $next_url");
  exit;
 }

/*******************
 * Display:
 */

page_head("Logged out");
echo "You are now logged out";
page_tail();

?>
