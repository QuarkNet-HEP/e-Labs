<?php
/***********************************************************************\
 * plotNchan - plot multiple timeseries channels on the same graph
 *
 * This file is read in to define parameters particular to the 
 * transformation.  
 *
 * Variables going in or out need to be declared 'global', since 
 * this file is included within the scope of a function.
 *
 * Eric Myers <myers@spy-hill.net> - 29 June 2008
 * @(#) $Id: settings.php,v 1.5 2009/04/27 20:02:20 myers Exp $
\***********************************************************************/

$vi_name='plotNchan';

define('CHANNEL_LIST_FILE', "channel_list.txt");

debug_msg(2,"$vi_name: reading settings....");


/**
 * General settings for all steps/pages.   This file may be included
 * in a _function_ somewhere else, so declare globals here.
 */

global $WorkFlow, $Ninputs, $Npens, $WorkFlow_list, $metadata;
global $input_channels, $GPS_start_time, $GPS_end_time, $ttype;
global $user_level;

 // Default only if not set
if( empty($Ninputs) || $Ninputs < 2 ) $Ninputs=2; 

$Npens=$Ninputs;                        // Out=In always here 


/**
 * Workflow details (for work_flow AND data_select).
 */

debug_msg(3,"settings: work_flow: added $vi_name details");
$WorkFlow_list[$vi_name] = new Work_Flow( $vi_name,"Plot multiple channels");
$WorkFlow_list[$vi_name]->user_level=2;
$WorkFlow_list[$vi_name]->maxInputs=array(2,4,8,16,99);
$WorkFlow_list[$vi_name]->desc="Plot data from two or more channels together "
    ."as a time series";


// But if we don't make the cut for user level, then forget
// all about this transformation
//
if( $user_level < $WorkFlow_list[$vi_name]->user_level )
    unset($WorkFlow_list[$vi_name]);


/** 
 *  Control Panel (to launch the task).  
 * This is assumed to already be in the slot
 */

if( is_step_named('control_panel') ){

    debug_msg(1,"settings: control_panel: load plotNchan.php...");
    require_once("plotNchan.php");

    // This function assembles the needed parameters and
    // lanuches the task.   The return value is just for the _launch_
    // of the task, not completion.
    // Assumed to be run in the slot.

    //
    function task_launch($task_id, $bg){
        global $GPS_start_time, $GPS_end_time;
        global $Ninputs, $input_channels; 
        global $time_input_pref;
        global $slot;


        debug_msg(1,"task_launch: launching $vi_name in ".getcwd() );

        $N = sizeof($input_channels);    
        debug_msg(1,"task_launch: $vi_name has $N input channels.");        

        $fh = fopen(CHANNEL_LIST_FILE,'w');
        if( !$fh ) {
            debug_msg(1,"task_launch: Cannot write list of channels "
                      .CHANNEL_LIST_FILE." in slot $slot");
            return -1;  
        }
        for($i=1; $i <= $Ninputs; $i++){
           $chName = $input_channels[$i]->name; 
           $ttype = $input_channels[$i]->ttype;
           //fwrite($fh, "$chName  $ttype \n");
           fwrite($fh, "$chName  \n");
        }
        fclose($fh);

        debug_msg(1,"task_launch: invoking $vi_name()...");        

        $launch_rc = plotNchan($task_id, CHANNEL_LIST_FILE, $Ninputs, 
                               $GPS_start_time, $GPS_end_time,
                               $ttype, $time_input_pref,   // GMT or GPS or LCL?
                               $bg); // runs in background? 
        return $launch_rc;        
    }

 }



/** 
 *  Task Execution (and monitoring)
 */

if( is_step_named('task_execution') ){
    //
    // TODO: task specific controls or settings for monitoring, canceling?
    //
 }




/** 
 *  Plot display (and save)
 */

if( is_step_named('plot_graph') ){
    debug_msg(4,"settings: plot_graph: created metadata array");

    global $input_channels;

    $metadata[] = "analysis string ".$WorkFlow;
    $metadata[] = "GPS_start_time int ". $GPS_start_time;
    $metadata[] = "GPS_end_time int ". $GPS_end_time;

    $N = sizeof($input_channels);    
    debug_msg(4,"settings: metadata for $N channels");
    for($i=1; $i <= $N; $i++){
        $metadata[] = "channel string ". $input_channels[$i]->name; 
        $ttype = $input_channels[$i]->ttype;
        $metadata[] = "trendType string ".$ttype;
    }
 }

?>
