<?php
 /***********************************************************************\
  * Debugging messages and message level for PHP scripts.
  * 
  * Use set_debug_level($level) to set the debugging level, causing 
  *     debugging messages to be displayed.
  *
  * Use debug_msg($level,message) to create debugging messages.
  *
  * Low level messages (level 1-5) should be used for error conditions
  * or important trace information.  Higher level messages (6-10) are
  * for informational messages or more frequent or verbose output. 
  * Setting the debug level to a lower number should produce less output, 
  * but important stuff should still be displayed.
  *
  * To prevent debug info leaking out to general users the level is only
  * set higher than zero if the REMOTE_ADDR is inside our internal network
  * or comes from our own IP range.  Adjust the $internal pattern below
  * accordingly.  The server is configured to now show PHP errors by default,
  * but setting a debug level also turns on the display of PHP errors.
  *
  * Eric Myers <myers@spy-hill.net>  - July 2005
  * @(#) $Id: debug.php,v 1.5 2009/05/05 15:53:39 myers Exp $
 \**********************************************************************/


// default if nothing else is already set
if( !isset($debug_level) ) $debug_level=0;


/* display a message, if the $level is less than or equal to the
 * global $debug_level.                                                 */

function debug_msg($level, $message) {
  global $debug_level;
  if ( $level <= $debug_level ) {
    $color='RED'; 
    if( $level >= 5 )     $color='ORANGE';  
    echo "\n<div style='z-index: 10'> <font color='" .$color. "'><tt>
      [$level] $message
      </tt></font></div>
    ";
  }
}


/**
 * Set the debug level, and turn on display of error messages, 
 *  but only for recognized 'internal' IP addresses.
 *  We don't want general outside users to see our dirty laundry. 
 */

function set_debug_level($level){
    global $debug_level;

    $debug_level=0;       // default is minimal output

    $ip_addr=$_SERVER['REMOTE_ADDR'];
    $internal="/^192\.168\.1\.|^204\.210\.158\.6|^198\.129\.208\.|"
        ."^137\.140\.48|^69\.86\.26\.53|^76\.15\.26\.166|"
        ."^76\.15\.106\.184|^198\.140\.183\.|^173\.50\.167\.46/";
    if( preg_match($internal,$ip_addr) ){
        $debug_level = $level;

        if($level > 3 ) {
            ini_set('error_reporting', E_ALL);
            ini_set('display_errors', "1");
            ini_set('display_startup_errors', "1");
            ini_set('html_errors', "1");
        }
        debug_msg(9,"Internal use: debug_level set to ".$debug_level);
    }
}

 

/**
 * Show the contents of one of the global arrays 
 */

function show_global_array($name){
  if (isset($name)){
     echo "\n<pre>\n";
     foreach($name as $key=>$value){
       echo "$key => ". print_r($value,true). "<br>\n";
     }
     echo "\n</pre>\n";

   }
   else {
     echo "<p>No " .$$name. " variables</p>\n";
   }
}

?>
