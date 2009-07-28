<?php
/***********************************************************************\
 * execution - objects and methods to support execution of an analysis
 *
 * This is general stuff to manage execution of any analysis,
 * run locally or externally.   See task_exectution.php for code
 * which specifically supports external task exection.
 *
 * This is internal support code, not presentation code.
 * See control_panel.php and task_monitor.php  for how this is used.
 *
 * Eric Myers <myers@spy-hill.net  
 * @(#) $Id: execution.php,v 1.18 2009/02/12 21:50:04 myers Exp $
\***********************************************************************/


/*
 *  TaskExecution object class describes different ways that
 *   we can run a task. 
 */

class TaskExecution{
    var $name;          // internal name
    var $label;         // External label shown to user
    var $slope;         // run time, seconds per frame file    
    var $bias;          // run time in seconds needed to start any task
    var $run_time;      // estimated run time for this analysis
    var $level;         // user_level at or above where this is an option
    var $method;        // API type/method (local, POST, CLI, etc)
    var $submit_url;    // POST handler for task submission
    var $start_time;    // Starting time, Unix timestamp
    var $end_time;      // End time, estimated or actual, Unix timestamp


    // Constructor: 
    function TaskExecution($name='', $label='',$level=1){
        $this->name=$name;
        $this->label=$label;
        $this->level=$level;
        $this->slope=0.098039;     // based on www13 and www18     
        $this->bias=1.0;
        $this->run_time=0.0;
        $this->submit_url='';
        $this->start_time=0;
        $this->end_time=0;
        return $this;
    }

    //Fill in the run time estimate, UNLESS IT'S BLOCKED


    function estimateRunTime($Nframes){
        $x = $this->run_time;

        if( !empty($x) && !is_numeric($x) )
            return $this->run_time;

        $this->run_time = $this->bias + $Nframes*$this->slope;
        return $this->run_time;
    }


}// TaskExecution 




/*
 * Execution choices:  how to run it, how long it might take
 * TODO:  this should be moved to the VI settings, with these
 *        remaining just as defaults.
 */

$exec_list['local']= new TaskExecution('local', "Local ($hostname)",1);
$exec_list['local']->bias = 4.0;
$exec_list['local']->method = 'local';

# Things we know

if( $hostname=='alvarez' )      $exec_list['local']->slope = 0.41502;
if( $hostname=='tekoa' )        $exec_list['local']->slope = 0.098039;  
if( $hostname=='www13' )        $exec_list['local']->slope = 0.098039;  
if( $hostname=='www12' )        $exec_list['local']->slope = 0.098039;  
if( $hostname=='www18' )        $exec_list['local']->slope = 0.098039;  



// Testing: via POST to just run locally
//
$exec_list['post']= new TaskExecution('post', "POST ($hostname)", 4);
$exec_list['post']->slope = 0.114247;
$exec_list['post']->bias = 5.0;
$exec_list['post']->method = 'POST';    // TODO: tla_dev? or what?
$exec_list['post']->submit_url = "http://".$local_server.$this_dir."/plot1chan_submit.php";


// Testing: via POST to run on tekoa (if we are not on tekoa)
//
if( 0 &&  $hostname !='tekoa' ){
  $exec_list['tekoa']= new TaskExecution('tekoa', 'tekoa@LHO', 4);
  $exec_list['tekoa']->slope = 0.098039;  // seconds per frame
  $exec_list['tekoa']->bias = 6.0;
  $exec_list['tekoa']->method = 'POST';   // TODO: tla_dev? or what?
  $exec_list['tekoa']->submit_url = "http://tekoa.spy-hill.net/tla_dev/plot1chan_submit.php";
  $exec_list['tekoa']->run_time="<font color='ORANGE'>Not Available</font>";
}


// Grid execution options
//
//$exec_list['swift']= new TaskExecution('swift', 'Swift',3);
//$exec_list['swift']->method = 'POST';
//$exec_list['swift']->submit_url = ELAB_URL."/ligo/analysis-plot1chan/analysis.jsp";
//$exec_list['swift']->run_time="<font color='ORANGE'>Not Available</font>";
//$exec_list['swift']->run_time=1;


$exec_list['vds']= new TaskExecution('vds', 'VDS',5);
$exec_list['vds']->run_time="<font color='ORANGE'>Not Available</font>";

$exec_list['pegasus']= new TaskExecution('pegasus', 'Pegasus',5);
$exec_list['pegasus']->run_time="<font color='ORANGE'>Not Available</font>";





/***************************************************\
 * External Controls:
 */

// Estimate run times for all available options.  
// Returns name of lowest estimate (for use as default).
//
function estimate_run_times($Nframes){
    global $exec_list;
    global $user_level;

    if(sizeof($exec_list) < 1 ) {
        add_message("Error: no execution choices.", MSG_ERROR);
    }

    $best_exec_type='';
    $best_time = 1E24;
    foreach($exec_list as $key=>$obj){
        if( $obj->level > $user_level ) continue;
        $exec_list[$key]->estimateRunTime($Nframes);  
        $t = $exec_list[$key]->run_time;
        if( !is_numeric($t) ) continue;
        if($t <= 0) continue;
        if($t < $best_time){
            $best_time = $t;
            $best_exec_type=$key;
        }
    }
    return  $best_exec_type;
}



// process form input specifying execution type
//
function handle_exec_type(){
    global $exec_list;
    global $exec_type;

    $x = get_posted('exec_type');
    if( empty($x) ) return;

    if( !array_key_exists($x, $exec_list)){
        debug_msg(1,"No such execution type: $x");
        return;
    }
    $exec_type = $x;
    clear_steps_after();
}



// Selector to allow the user to pick the execution, 
// showing run estimates
// TODO: make this return a string, rather than echo
//
function exec_type_options(){
    global $exec_list;
    global $user_level;
    global $exec_type;

    $l = array();

    foreach ($exec_list as $key => $obj) {
        if($obj->level > $user_level) continue;

        $l[$key] = "<b>".$obj->label.":</b> ".exec_run_time($obj);       
    }
    echo auto_buttons_from_array("exec_type", $l, $exec_type, true);
}


// Input (radio button) to select an execution type
//
function exec_type_input($obj){
    global $exec_type;

    $label=$obj->label;
    $value=$obj->name;

    if(!empty($obj->run_time) && is_numeric($obj->run_time)){
        $x = "<input type='radio' name='exec_type' value='$value' ";
        if( $value==$exec_type ) $x .= " CHECKED ";
        $x .= "> \n";
    }
    else {
        $x = "<b>&nbsp;X&nbsp; </b> ";
    }
    $x .="<b>$label: </b>&nbsp; ";
    return $x;
}


// Show estimated run time for an execution type
//
function exec_run_time($obj){
    $run_time=$obj->run_time;

    $x .= "Estimated run time: ";
    if(!is_numeric($run_time)){
        $x .= $run_time;
    }
    else {
        $x .= printable_dt($run_time,1);
    }
    return $x;
}

?>
