<?php
/***********************************************************************\
 * root.php -  ROOT data input and graphics output
 *
 *  Functions to support plotting using ROOT, and in particular dmtroot
 * 
 *  In general this all happens in a "slot" sub-directory, which is 
 *  unique to each user and each browser session.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: root.php,v 1.39 2008/10/17 21:36:30 myers Exp $
\***********************************************************************/

require_once("messages.php");
require_once("channels.php");



// Launch a task to run a ROOT or DMTROOT script.
// If $bg=TRUE then the task is launched in the background, and the return
// code is zero if the launch succeeded, even though the task itself
// may later fail.  If $bg=FALSE (the default) then wait for the task to
// finish. In that case the return code is for the task itself, not just
// the launch.
//
function root_run($script,$task_id='',$bg=FALSE){  
    global $TLA_ROOT_DIR;

  // TODO: pass the $id from outside so both know it?
  global $Nplot;

  // log file names (no additional parts)
  // TODO: clear up confusion between $task_id and $plot_id

  if( !empty($task_id) ) $id = $task_id;
  else $id = uniq_id();  

  $logfile = $id .".log";
  $errfile = $id ."_err.log";

  if( empty($task_id) ) $id = uniq_id($Nplot);  


  // The TLA_ROOT_DIR is where our own ROOT scripts and stuff live.
  // This is now set in config.php so we don't need to do so here.
  // And this had better match what's used in root/run_dmtroot.sh! 
  //
  $cwd = getcwd();                      // remember where we were
  if( !isset($TLA_ROOT_DIR) ){          
      debug_msg(0,"TLA_ROOT_DIR was not set!  Trying to guess...");
      $TLA_ROOT_DIR =  realpath($cwd."/../../root");
  }
  if( !is_dir($TLA_ROOT_DIR) ) {
      debug_msg(1, "Cannot find TLA ROOT directory ($TLA_ROOT_DIR)" );
      return 7;
  }

  // Each task runs in a separate 'slot' directory.
  // We may already be there, but let's make sure.
  //
  //$slot = slot_dir();
  //chdir($slot); 

  $cmd = "/bin/sh ". $TLA_ROOT_DIR."/run_dmtroot.sh $id '" .$script;

  // send stderr to separate error log 
  $cmd .= "' >> $logfile 2>>$errfile ";

  if( $bg ){
      debug_msg(1,"Launching task '$task_id' in background!");
      $cmd .= " &"; 
      //TODO: emit process PID
  }
  debug_msg(5,$cmd);
  
  // Run it
  //
  $cmdfile=$task_id.".cmd";
  if( $h = fopen($cmdfile, 'a') ){
      fwrite($h, time()." $cmd\n");
  }
  $out="";
  $txt = exec($cmd,$out,$root_rc);
  if($root_rc) add_message("ERROR: ROOT return code: ".$root_rc, MSG_ERROR);

  if( !empty($out) ){
      add_message("% $cmd", MSG_WARNING);
      foreach($out as $line){
          add_message($line, MSG_WARNING);
      }
  }


  if( $root_rc ){
      $x = "ROOT task failed! <br> Probable cause: ";
      $x .= root_error_text($root_rc);
      add_message($x, MSG_ERROR);
  }
  if( !empty($txt) ) debug_msg(3, " $txt");

  chdir($cwd);  // back to where we were 

  //TODO: or return an object with $id, $rc and anything else?
  return $root_rc;   
}



// Convert a ROOT or DMTROOT error code into a more understandable
// error message.  (The messages use HTML.  Should we convert?)
//
function root_error_text($root_rc){// 
    switch($root_rc){

        /* negative values are (likely) from Frame library */

    case -3:
        $x .= "Requested data not found in current frame.";
        break;


        /* Small positive values are general ROOT errors */

    case 1:
        $x .= "ROOT script failed.";
        break;

    case 2:
        $x .= "Unix script error.";
        break;


        /* Errors in DMT Macros or in our own ROOT scripts */

    case 14:
        $x .= "Missing or incorrect channel name";
        break;

    case 15:
        $x .= "No frames read. Nothing to plot";
        if ($ttype == "T" || $ttype == "R") {
            $x .="<br>Perhaps you need to run data_prep first?";
        }
        break;

    case 17:
        $x .= "Detected DMT is online rather than offline.";
        break;


        /* Errors in run_dmtroot.sh script or similar */

    case 21:
        $x .= "No uniq task id.";
        break;

    case 22:
        $x .= "Missing component or directory.";
        break;

    case 127:
        $x .= "Executable not found.";
        break;
    }
    return $x;
}




/*******************************
 * Update an existing plot (in the foreground)
 */

function plot_update($task_id, $Nplot){
    global $debug_level;

    // Previous Plot file

    $Npast = $Nplot-1;
    if( $Npast < 1 ) $Npast = 1;

    $old_plot = $task_id."_".$Npast.".C";
    debug_msg(3,"plot_update(): previous plot was $old_plot");


    // Already in slot?
    $slot=slot_dir()."/";
    if( !file_exists($slot.$old_plot) ) {
        debug_msg(1,"No plot file $old_plot to modify.");
        return -1;
    }

    // Updates to the plot

    $updates =  $task_id."_update.C";

    if( !file_exists($slot.$updates) ) {
        debug_msg(2,"No changes have been made to the plot.");
        return -2;    // TODO:  or return object with $rc, etc...?
    }


    $plot_save = "  \$TLA_ROOT_DIR/plot_save.C(\"$task_id\",". $Nplot.") ";

    // Run these through ROOT.  The existing plot, the updates,
    // and the "save" script.
    //
    $rootscript=$old_plot."  ". $updates ." ". $plot_save ;

    if($debug_level > 0) @copy( $slot.$updates, "/tmp/".$updates);  

    $rc = root_run($rootscript,$task_id,false);   // not in background!

    @unlink($slot.$updates); // remove update file when finished 
    return $rc; 
}

?>
