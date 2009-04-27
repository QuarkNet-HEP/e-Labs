<?php
/***********************************************************************\
 * plot1chan - plot a graph of a single data channel (timeseries)
 *
 * This file is read in to define parameters particular to the 
 * transformation.  
 *
 * Variables going in or out need to be declared 'global', since 
 * this file is included within the scope of a function.
 *
 * Eric Myers <Eric.Myers@ligo.org> - 29 June 2008
 * @(#) $Id: settings.php,v 1.6 2009/04/27 20:02:20 myers Exp $
\***********************************************************************/

$vi_name='plot1chan';


debug_msg(2,"$vi_name: reading settings....");

/**
 * General settings for all steps/pages
 */

global $WorkFlow, $Ninputs, $Npens, $WorkFlow_list, $metadata;
global $input_channels, $GPS_start_time, $GPS_end_time, $ttype;

$Ninputs=1;
$Npens=$Ninputs;


/**
 * Workflow details (for work_flow AND data_select).
 * Keep in mind that work_flow loads
 */

debug_msg(3,"settings: work_flow: added plot1chan details");
$WorkFlow_list[$vi_name] = new Work_Flow( $vi_name,"Plot one channel");
$WorkFlow_list[$vi_name]->user_level=1;
$WorkFlow_list[$vi_name]->maxInputs=array(1,1,1,1,1);
$WorkFlow_list[$vi_name]->desc="Plot data from a single channel "
    ."as a time series";


/** 
 *  Control Panel (to launch the task)
 */

if( is_step_named('control_panel') ){
    debug_msg(4,"settings: control_panel: load plot1chan.php");

    require_once("plot1chan.php");

    // This function assembles the needed parameters and
    // lanuches the task.   The return value is just for the _launch_
    // of the task, not completion.
    //
    function task_launch($task_id, $bg){
        global $GPS_start_time, $GPS_end_time, $input_channels; 
        global $time_input_pref;

        $ch1 = $input_channels[1];

        $launch_rc = plot1chan($task_id, $input_channels[1],
                               $GPS_start_time, $GPS_end_time,
                               $time_input_pref,
                               $bg); // runs in background? 
        return $launch_rc;        
    }


    // Task execution coefficients:
    // Fill in over default values on execution.php

    if( $hostname=='alvarez' ){
        $exec_list['local']->slope = 0.114247;
    }

    if( $hostname=='tekoa' ){ // if 'tekoa' is 'local' 
        $exec_list['local']->slope = 0.098039;  // seconds per frame
    }

    // POST to tekoa:
    //
    $exec_list['tekoa']->slope = 0.098039;      // seconds per frame
    $exec_list['tekoa']->bias = 6.0;            // POST takes longer to start


 }// control_panel




/** 
 *  Task Execution (and monitoring)
 */

if( is_step_named('task_execution') ){
    //
    // TODO: task specific controls or settings for monitoring, canceling?
    //
 }// task_execution



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
 }// plot_graph

?>
