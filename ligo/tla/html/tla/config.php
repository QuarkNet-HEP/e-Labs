<?php
/***********************************************************************\
 * config.php - run time configuration
 *
 * Use this file to set run time configuration common to all pages.
 * This is just for settings, not code.
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: config.php,v 1.58 2009/05/26 20:55:38 myers Exp $
\***********************************************************************/

// Bluestone version is put at the bottom of every page, 
// using the CVS tag
//
define('CVS_TAG', '\$Name: version_0_72  $');


// "Tickets" were for cross-site authentication.  They are not presently
// in use, since we can use domain cookies instead.
//
//define("MAX_TICKET_AGE", 360);   // short for testing
//define("MAX_TICKET_AGE", 60);   // REALLY short for testing!
define("MAX_TICKET_AGE", 3600);     // one hour is long enough for a class     

// How long (in seconds) can someone step away before we reset the session?
// After an hour, class is over. 
//
define("MAX_SESSION_AGE", 3600);       


// Path to wiki, for tutorial or other transclusions.  Relative path
//
$Path_to_wiki='/library';



// Configuration info about this server and setup, global to
// all pages which include this file (which is most everything).
//
$self = $_SERVER['PHP_SELF']; 
$local_server = $_SERVER['SERVER_NAME'];
$user_IP=$_SERVER['REMOTE_ADDR']; 
$URI=$_SERVER['REQUEST_URI'];
$this_dir = dirname($self);


// From whence we came?
//
if( array_key_exists('HTTP_REFERER', $_SERVER) ){
    $referer = $_SERVER['HTTP_REFERER'];            // full URI
    $came_from = basename($referer);               // just script name
 }


// Complete URL to the glossary wiki, such that a search term
// can just be appended to it.  Uses 'kiwi' skin to remove controls.
//
define('GLOSSARY_URL', "http://".$local_server."/glossary/kiwi.php?title=") ;


// URL to the e-Lab server (Tomcat running JSP).   The actual e-lab
// pages will be under this (eg. ELAB_URL/ligo)
//
define('ELAB_URL',  "http://".$local_server.":8080/elab");


$elab='ligo';   // Used in elab_interface.php and elab_login.php


// Metadata basics list:  names of variables that should be saved
// to e-Lab as associated metadata (you can add to this in a vi)

$metadata_items = array('GPS_start', 'GPS_end');



/*********************
 * Where things live.  TLA_TOP_DIR is assumed to be two levels up.
 */

$cwd = getcwd();

$TLA_TOP_DIR=dirname(dirname(dirname(__FILE__)));

$TLA_SLOTS_DIR=$TLA_TOP_DIR."/html/tla/slot";   // note plural!


// Where executable scripts live. 
//
$BIN_DIR=realpath($TLA_TOP_DIR."/bin");   

// Where ROOT executable script (eg. run_dmtroot.sh) can be found.
//$ROOT_DIR =  realpath($cwd."/../../root"); //OLD (depracated)
//
$TLA_ROOT_DIR =  realpath($TLA_TOP_DIR."/root");

// Where Transformations live (think of them as Virtual Instruments)
// Telative to the slot where we are running.
//
$TLA_VI_DIR=realpath($TLA_TOP_DIR."/vi");   


// Where BOINC utilitiy files live (until we can separate from them?)
//
$BOINC_html=dirname(dirname(__FILE__));


// Where authentication tokens ("tickets")  are kept on server.
// Must be writeable by the web server daemon!
//
//OLD//$ticket_file="/home/www/etc/tickets.txt";
$ticket_file= $TLA_TOP_DIR. "/var/tickets.txt";


// We will need to know the current `hostname` in several places
// It may not be the same as the SERVER_NAME.  
//
if( !isset($hostname) ) $hostname=trim(exec('hostname -s'));


// Name of the Analysis Tool
$TLA_tool_name='Bluestone';   


// Debugging: Danger, overriding like this breaks the user 
// controllable version, so only do this in a pinch!
/****   $debug_level=6; ****/



$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: config.php,v 1.58 2009/05/26 20:55:38 myers Exp $";
?>
