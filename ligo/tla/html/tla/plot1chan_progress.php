<?php
/***********************************************************************\
 * task_wait.php - wait for executing task to finish.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 25 October 2007
 * @(#) $Id: plot1chan_progress.php,v 1.6 2008/03/28 18:02:58 myers Exp $
\***********************************************************************/

require_once("messages.php");           // message display
require_once("macros.php");              // general utilities
//require_once("root.php");                // also ROOT stuff
//require_once("../boinc_html/inc/util.inc");  // for the table stuff 


$task_name='plot1chan';

/***********************************************************************\
 * Action:  look for task files
\***********************************************************************/

// If task_id is in the URL use that
//
if( isset($_GET['task_id']) ){
    $task_id = $_GET['task_id'];
 }

if( isset($_GET['Ntry']) ){
    $Ntry = $_GET['Ntry'];
 }
if( empty($Ntry) ) {
    $Ntry = 0;
 }

if( isset($_GET['slot']) ){
    $slot = $_GET['slot'];
 }
if( empty($slot) ){
    $slot=slot_dir()."/";
 }
chdir($slot);


/********************
 * Are we done yet?
 *
 * Check status of any existing executing process, by looking
 * first for a lockfile, which indicates that the task is still
 * running, or that failing for a donefile, which indicates that
 * the task has finished.   Redirect appropriately for either case.
 *
 */

debug_msg(1, "$self: Analysis running?");

if( empty($root_rc) ) $root_rc=0;
if( empty($Nplot) || $Nplot < 0 )  $Nplot=1;

$donefile=$task_id. ".done";
debug_msg(1,"Checking for donefile $donefile");

if( file_exists($donefile) ) {
    list($t_end, $rc) = explode(' ', file_get_contents($donefile));
    add_message( dateHms()." Analysis completed at "
                     . date('r', $t_end) . "  Return Code: $rc");
    $u = "plot1chan_done.php?task_id=$task_id&slot=$slot&";
    if($debug_level > 0){
        $t = 7 + $debug_level;
        add_message("Jumping in $t seconds to $u");
        header("Refresh: $t ; URL=$u");
    }
    else {
        header("Location: $u");// OR JUST GO THERE
        exit(0); 
    }
 }
 else {
     $lockfile=$task_id . ".lock"; 
     debug_msg(1,"Checking for lockfile $lockfile");
     if( file_exists($lockfile) ) {
         debug_msg(2," Analysis is still running.  Try again in $t seconds...");
         add_message("Analysis $task_id is still running.");
         $Ntry = 0;  
         $t = 13 + $debug_level;
         $u = basename($self) ."?task_id=$task_id&slot=$slot&" ; // re-run myself
         header("Refresh: $t ; URL=$u");
         add_message("Try again in $t seconds with $u");
     }
     else  {// No lockfile, no Donefile.  Was it even submitted?
         if( file_exists($task_id.".cmd") ) {
             //         if( file_exists('Kilroy_was_here') ) {
             add_message("Analysis $task_id was started.  (Kilroy was here)");
         }
         else {
             add_message("Analysis $task_id was lost?");
             add_message("Try # $Ntry");
             $Ntry++; 
         }
         $t = 3 + $debug_level;
         $u = basename($self) ."?task_id=$task_id&Ntry=$Ntry&slot=$slot&" ; // re-run myself
         if( $Ntry < 5){
             header("Refresh: $t ; URL=$u");
             add_message("Try again in $t seconds with $u");
         }
         else {
             add_message("Task $task_id never started, or was lost. "
                         ."After $Ntry trys I give up.");
             // No header, no redirect -- we stop here. //
         }
     }
 }



/***********************************************************************\
 * Display Page:  form input for the basics
\***********************************************************************/

//TODO: strip user interface further to not use any TLA decorations or macros
//
    echo "<HTML>\n<HEAD> \n";
    echo "<TITLE>Task progress: $task_id\n</TITLE>\n";
    echo "</HEAD>\n <BODY>\n";

//html_begin();

controls_begin();  // includes message area

echo "\n\n<content_body>\n\n";
echo "<tt>\n";
echo "Analysis: $task_name      <br>\n";
echo "Task ID: $task_id         <br>\n";


echo "<div align='center' bgcolor='white'>
        <img align='center' src='img/busy2.gif'> 
        </div>\n";

echo "Slot: $slot               <br>\n";
echo "PHP Session ID: " . session_id(). "       <br>\n";

echo "<P>\n";
echo "</tt>\n";
echo "\n\n</content_body>\n\n";

controls_end();



/*******************************************************
 * DONE: */

echo "\n</form>\n";    
echo "</BODY>\n</HTML>\n";

?>
