<?php
/***********************************************************************\
 * Debugging messages and message level for PHP scripts - TLA version!
 * 
 * Use set_debug_level($level) to set the debugging level.  In general
 * the higher the number the more verbose the output.
 *
 * Use debug_msg(level,message) to create a debug message.
 *
 * Low level messages (level 1-5) should be used for error conditions
 * or important trace information.  Higher level messages (6-10) are
 * for informational messages or more frequent or verbose output. 
 *
 * To prevent debug info leaking out to general users the level is only
 * set higher than zero if the REMOTE_ADDR is inside our internal network
 * or comes from our own IP range.  Adjust the $internal pattern below
 * accordingly.  The server should be configured to not show PHP errors
 * by default, but setting a debug level also turns on the display of 
 * PHP errors at an appropriate level.
 * 
 * Because we do a lot of work before we compose the page for output, 
 * and because in doing so we might need to send headers, we put the
 * messages in the array of messages to be displayed rather than just
 * echoing.   See messages.php for how the message dispaly system works.
 *
 * Eric Myers <myers@spy-hill.net>  - July 2005
 * @(#) $Id: debug.php,v 1.32 2009/04/14 18:30:52 myers Exp $
\**********************************************************************/

require_once("messages.php");
require_once("util.php");

$debug_log_dir="/tmp/debug";


/**
 * Log debug messages to a temporary file, if the proper directory
 * exists and we can create and write the file. */

function debug_msg_to_file($level, $message){
    global $debug_level, $debug_log_dir;

    /* Log all levels to a file, if it exists (see above)*/

    if( $debug_level <= 0) return;
    if( !is_dir($debug_log_dir) ) return;
    if( !is_writeable($debug_log_dir) ){
        error_log("Warning: $debug_log_dir exists but is not writeable.");
        return;
    }
    $debug_log_file = $debug_log_dir."/tla_debug.log";

    if( file_exists($debug_log_file)) $x = 'a';
    else                              $x = 'w';
    $h = fopen($debug_log_file, $x);
    if($h) {
        $timestamp=gmdate('M j G:i:s', time());
        fwrite($h,$timestamp);
        fwrite($h," [$level] ");
        fwrite($h,$message);
        fwrite($h,"\n");
        fclose($h);
	return TRUE;
    }
    return FALSE;
}



/***************************
 * Display a message, if the $level is less than or equal to the
 * global $debug_level.
 */

function debug_msg($level, $message, $status='') {
    global $debug_level;
    global $debug_log_dir;
    global $msgs_list, $messages_shown;

    if( session_id()=="" ) session_start();

    // cannot use recall_variable() here (yet) as it may call us!
    if( !isset($debug_level) ){
        if( isset($_SESSION) && array_key_exists('debug_level', $_SESSION) ){
            $debug_level = $_SESSION['debug_level'];
        }
        else {
            $debug_level=0;
        }
    }

    /* Log all levels to a file, if it exists (see above) */

    debug_msg_to_file($level, $message);

    /* only log to display if level is high enough */

    if ( $level > $debug_level ) return;

    /* if we have a session going then inject the message into the 
     * message system.  WARNING: right now they won't display after the  
     * message box has been shown!  Need to have another message box below? */

    if( session_id()!="" && !$messages_shown && $level > 0 
                         && function_exists('add_message') ){

        if($status==''){
            $status=MSG_ERROR;
            if( $level >= 5 ) $status=MSG_WARNING;
        }
        add_message("[$level] ".$message, $status);
    }
    else {  // Otherwise, just display it.

        $color='RED'; 
        if( $level >= 5 ) $color='ORANGE';  
        echo "\n<br><font color='" .$color. "'><tt>
      [$level] $message
      </tt></font><br>     
    ";
    }
}



/**
 * Is this a machine where we can debug?
 */

function is_test_client(){
    //return FALSE;  // BYPASS FOR PRODUCTION
    $ip_addr=$_SERVER['REMOTE_ADDR'];
    $internal="/^192\.168\.1\.|^204\.210\.158\.6|^198\.129\.208\.|"
        ."^137\.140\.48|^69\.86\.26\.53|^76\.15\.26\.166|"
        ."^76\.15\.106\.184|^198\.140\.183/";
    if( preg_match($internal,$ip_addr) ) return TRUE;
    return FALSE;
}


/**
 *  Set the debug level, and turn on display of error messages, 
 *  but only for recognized 'internal' IP addresses.
 *  We don't want general outside users to see our dirty laundry.
 */

function set_debug_level($level){
    global $debug_level;

    $debug_level=0;       // default is minimal output

    if( is_test_client() ){
        $debug_level = $level;

        // adjust PHP error reporting:

        $PHP_debug_level = E_ALL & ~E_NOTICE ; // as is PHP 5.x default
        if($debug_level>3) $PHP_debug_level &= E_NOTICE ;  // minor details
        if($debug_level>5) $PHP_debug_level &= E_STRICT ;  // everything!

        ini_set('error_reporting', $PHP_debug_level);
        ini_set('display_errors', "1");
        ini_set('display_startup_errors', "1");
        ini_set('html_errors', "1");
        debug_msg(9,"Internal use: debug_level set to ".$debug_level);
    }
    remember_variable('debug_level');
}



/**
 * Selector to set the debug level (see debug.php)
 */

function select_debug_level(){
    global $debug_level;

    $t="Debug Level:&nbsp;";
    for($i=0; $i<10; $i++){  $dray[$i] = "$i"; }
    $t .= auto_select_from_array('debug_level', $dray, $debug_level);
    return $t;
}


function handle_debug_level(){
    global $debug_level;

    // Get existing setting for session, if there is one
    //
    if( $_SESSION && array_key_exists('debug_level',$_SESSION) ){
       $lvl = $_SESSION['debug_level'];
       if( is_numeric($lvl) && $lvl < 10 ) {
          set_debug_level($lvl);
       }
    }

    // if( !posted_to_self() ) return; // Do we care?
    //
    if( array_key_exists('debug_level',$_POST) ){
       $lvl = $_POST['debug_level'];
       if( is_numeric($lvl) && $lvl < 10 ) {
          set_debug_level($lvl);
       }
    }

    // Save in session, if there is one
    //
    if( session_id() != "" && is_numeric($debug_level) ){
        $_SESSION['debug_level'] = $debug_level;
    }
}


/* Track memory usage */

function debug_memory_usage($label=''){
    $x = "";
    if($label) $x = "$label: ";
    $x .= "memory usage: " . memory_format(memory_get_usage());
    add_message($x);
}


function memory_save_usage($var){
    global $$var;
    $$var =  memory_get_usage();
}


/**
 *  Class __autoload() debugging.
 *  We don't load the class, we just log the error
 */ 

function __autoload($class_name) {
    debug_msg(2,"__autoload($class_name) has been invoked.");
}



?>
