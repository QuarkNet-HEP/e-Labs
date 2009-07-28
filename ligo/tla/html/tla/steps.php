<?php
/***********************************************************************\
 * steps.php - configuration and functions for multi-step dialogue
 *
 *  These functions are for managing multi-step processes that 
 *  require continuity during a session and perhaps between sessions.
 *  Provisions are made for a step to include a sub-process which is
 *  itself another list of steps.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: steps.php,v 1.31 2009/02/11 20:04:54 myers Exp $
\***********************************************************************/

require_once("util.php");

// Step status

define('STEP_NEW',   0);
define('STEP_DONE',  1);
define('STEP_FAIL', -1);
define('STEP_IN_PROGRESS', 2);

 
/*******************************
 * Steps Object Class:
 \*/

class Process_Step{
    var $label;
    var $url;
    var $description;
    var $status;
    var $sub_process;    // name of variable containing a set of sub-steps
    var $is_optional;

    function Process_Step($label, $url='', $description=''){//  Constructor
        $this->label=$label;                // short name for brief display
        $this->description=$description;    // more detail
        $this->url=$url;
        $this->status=STEP_NEW;
        $this->sub_process='';              // name of array of any subprocess
        $this->is_optional=false;    
    }
}// End Process_Step class

 
/*******************************
 * Initialize TLA steps into the step array named $step_list_name
 * (move this to config.php?)
 */

function main_steps_init($step_list_name='main_steps'){
    global $$step_list_name;
    global $user_level, $this_step; 

    if( !isset($this_step) ) {
        $this_step=1; 
    }

    debug_msg(4,"Set/reset $step_list_name array to initial values.");
    $step_array[1] = new Process_Step("Analysis Type",  'work_flow.php',
                                      "How the data will be processed.");
    $step_array[] = new Process_Step("Data Selection",  'data_select.php',
                                     "Which data to process (time interval and channel).");
    $step_array[] = new Process_Step("Controls",  'control_panel.php',
                                     "Input parameters and execution control.");
    $step_array[] = new Process_Step("Task Execution",  'task_execution.php',
                                     "Monitor and control task execution.");
    $step_array[] = new Process_Step("Plot Graph",  'plot_graph.php',
                                     "View the graphics output.");
    $Nsteps = sizeof($step_array);
    $$step_list_name = $step_array;

    return $step_array;
}


/**
 *  Returns step number as found in step list $step_list_name,
 *  based on URI file name 
 */

function get_current_step($step_list_name='main_steps'){
    global $$step_list_name; 

    // Counting steps starts at 1, so flag/fix this error case   
    //
    if( isset($$step_list_name[0]) ){
        debug_msg(1,"Found $step_list_name" ."[0]. Deleted.");
        unset($$step_list_name[0]);
    }

    $list=$$step_list_name;
    $Nsteps = sizeof($list);
    debug_msg(5,"get_current_step(): ".
              "There are $Nsteps steps in the list $step_list_name.");

    if($Nsteps ==0) debug_msg(3, "No steps listed in $step_list_name");

    $fn1 = basename($_SERVER['PHP_SELF']);  // get current filename

    for($i=1; $i<=$Nsteps;$i++){
        $s = $list[$i];
        $fn2 = basename($s->url);
        debug_msg(6,"get_current_step(): checking $fn2 against $fn1");
        if( empty($fn2) ) continue;
        if( $fn2 == $fn1 ) return $i;
    }

    // Additional case not in the list
    //
    if($fn1 == 'index.php') return 1;   // for alias 

    debug_msg(5,"Cannot find file $fn1 in list of steps $step_list_name");

    return -1;
}


/**
 * Set the status for the given step in the list 
 */

function set_step_status($step_list_name, $status){
    if( empty($step_list_name)) $step_list_name='main_steps';
    global $$step_list_name;

    $i = get_current_step($step_list_name);
    debug_msg(5,"set_step_status(): this is step $i of $step_list_name"); 
    debug_msg(6,"Number of steps: ". sizeof($$step_list_name)); 

    if($i <= 0 ) return;
    if( !is_numeric($i) ) return;

    $p = &  $$step_list_name;   
    $p[$i]->status=$status;
    debug_msg(3,"Set step $i status to " . $p[$i]->status);
    remember_variable($step_list_name);  // save to $_SESSION
}


function clear_steps_after($step_list_name=''){
    if( empty($step_list_name)) $step_list_name='main_steps';
    global $$step_list_name; 

    $this_step = get_current_step($step_list_name);
    if($this_step <= 0 ) return;
    if( !is_numeric($this_step) ) return;

    $list =& $$step_list_name;
    $Nsteps = sizeof($list);

    if($Nsteps <= 0 || $this_step >= $Nsteps ) return;

    for($i=$this_step+1; $i<=$Nsteps; $i++){
        $list[$i]->status=STEP_NEW;
    }
}




/*******************************
 * Save the step info and status to the SESSION
 */

function steps_remember($step_list_name='main_steps'){
    if( session_id()=="" ) session_start();
    remember_variable($step_list_name);   
    remember_variable('this_step');
    return;
}

function steps_recall($step_list_name='main_steps'){
    if( session_id()=="" ) session_start();
    recall_variable($step_list_name);    
    recall_variable('this_step');       
    return;
}



/**
 * Save the step info and status to a file to be able to return to session later
 */
function steps_save($step_list_name, $filename){
    // [TODO] save steps to file so as to resume in later session...
}


/**
 *  get current step setting for session, including changes from _POST
 */
function update_step($step_list_name){
    global $$step_list_name;

    // First recall any settings we've already remembered
    steps_recall($step_list_name);

    // If still not set, then intitialize
    if( !isset($$step_list_name) ) {
        main_steps_init($step_list_name);
    }

    // Update based on current file name, if we can
    $this_step=get_current_step($step_list_name);

    // Update based on POST  (Old and goes away? No, use for debugging)
    if( $s = get_posted('this_step') ){  
        $this_step=$s;
    }

    return $this_step;
}



//
/*******************
 * Display the steps and status as tabs across the page
 */

function steps_as_tabs($step_list_name){
    global $user_level;
    global $this_step;
    global $status_msg, $status_color;
    global $Nsteps, $step_label, $step_status, $step_description, $step_url;

    global $$step_list_name;
    if( !isset($$step_list_name) ){
        debug_msg(5,"No steps listed in array $step_list_name"); 
        return;
    }
    $Nsteps=sizeof($$step_list_name);  

    echo "\n<TABLE class='control' width='100%'>
        <TR><TD>
        ";

    echo "
        <TABLE width='100%' ><TR>\n";

    $i=1;
    foreach($$step_list_name as $s){
        // Determine class of tab box
        $cl = 'tab';
        if($i == $this_step)        $cl .= ' selected';
        echo "<TD class='$cl'>\n";

     
        if( $i != $this_step) echo "<a href='" .$s->url. "' class='$cl'>";
        echo $s->label;
        if( $i != $this_step) echo "</a>";
        echo "\n </TD>\n";
        $i++;
    }
    echo "
        </TABLE>
     </TD></TR>
        ";

    // sub-steps menu from selected step would go here

    echo "<TR><TD class='sub-tab'>
                &nbsp;
        </TD></TR>\n    ";

    // End of menu tabs
    echo " </TABLE>\n ";
}


/*******************
 * Display the steps and status as block flow diagram
 */

function steps_as_blocks($step_list_name){
    global $user_level, $this_step;

    global $$step_list_name;
    if( !isset($$step_list_name) ){
        debug_msg(2,"No steps listed in array $step_list_name"); 
        return;
    }
    $Nsteps=sizeof($$step_list_name);  

    echo "<div class=\"control\">\n";
    prev_next_buttons($step_list_name, false);
    echo "\n<TABLE class='block-list' align='center' >
        <TR>\n";
    $i=1;
    foreach($$step_list_name as $s){
        if( $s->status == 0) {
            $c='block-new';
        }
        if( $s->status < 0)    $c='block-fail';
        if( $s->status > 0)    $c='block-ok';
        if( $i == $this_step)  $c='block-this';
        echo "  <TD align='center' valign='center'>\n";
        echo "     <TABLE class='$c'><TR><TD class='$c' title='".
            $s->description."'>\n";
        $show_link =  ($i != $this_step) && ($s->status != 0);

        if($show_link) echo "<a href='" .$s->url."' class='block'>";
        echo "$s->label";
        if($show_link) echo "</a>";
        echo "\n  </TD></TR></TABLE>\n </TD>\n";

        if($i != $Nsteps){
            echo "<TD align='CENTER' width='50' class='block-arrow'> ----> </TD>\n";
            $i++;
        }

    }
    echo "
     </TD></TR>
     </TABLE>
        ";
    echo "</div>\n";
}


/*******************
 * Display the steps and status as list of signals lights
 */

function steps_as_signals($step_list_name){
    global $user_level, $this_step;

    global $$step_list_name;
    if( !isset($$step_list_name) ){
        debug_msg(2,"No steps listed in array $step_list_name"); 
        return;
    }
    $Nsteps=sizeof($$step_list_name);  

    $x = "\n<TABLE border='2' width='175' align='right' ><TR><TD>
        <TABLE class='block' border='0'>\n";

    $i=1;
    foreach($$step_list_name as $s){
        if( $s->status == 0)   {
            $img='img/signal_white.gif';
            if( $i == $this_step)  $img='img/signal_blue.gif';
        }
        if( $s->status < 0)    $img='img/signal_yellow.gif';
        if( $s->status > 0)    $img='img/signal_green.gif';
        $x .= "<TR> <TD class='signal-block' align='left' valign='center'> <img src='$img' border=0> ";
        //if( $i != $this_step) $x .= "<a href='" .$s->url."' class='block'>";
        $x .= "$s->label";
        if( $i != $this_step) $x .= "</a>";
        //$x .=  "</TD></TR>\n";
        $i++;
    }
    $x .= "\n </TABLE>
        </TD></TR></TABLE>\n";
    return $x;
}


/***********************************************************************\
 * Next or Previous step buttons (including reset button)
 */

// Show the Next/Previous buttons:  
// 
function prev_next_buttons($step_list_name, $reset = true){
    global $this_step,  $$step_list_name;
    global $count;
    if( !isset($$step_list_name) ) return;
    
    if (!isset($count)) {
    	$count = 0;
    }
    $count++;

    $list=$$step_list_name; 
    $Nsteps = sizeof($list);
    //  if( $this_step<1 || $this_step > $Nsteps ) return;

    echo "        <TABLE width='100%'><TR>\n";

    $bt = "&nbsp;";
    if( $this_step > 1) {
        $bt = "<INPUT class=\"button\" type='SUBMIT' name='previous' value='<< Previous Step'>";
    }
	else {
        //$bt = "<INPUT disabled=\"true\" class=\"button\" type='SUBMIT' name='previous' value='<< Previous Step'>";
    }
    echo "   <TD width='33%' align='LEFT'> $bt      </TD>\n";

    echo "<TD width='33%' align='CENTER'>";
    if ($reset) {
       echo "<input class=\"button\" type='submit' name='reset_session' value='Start Over'>";
    }
    echo "</TD>\n";

    $bt = "&nbsp;";
	
    if($list[$this_step]->status==STEP_DONE && $this_step < $Nsteps ){
        $bt = "<INPUT class=\"button\" type='submit' name='next' value='Next Step >>'> ";
    }
    else if ($list[$this_step]->status != STEP_IN_PROGRESS && $this_step < $Nsteps) {
    	$bt = "<INPUT class=\"button\" type='submit' id=\"apply-button-$count\" name='apply' value='Apply'> ";
    }
    echo "<TD width='33%' align='RIGHT'> $bt </TD>\n";
    echo " </TR></TABLE>\n";
	echo <<<END
		<script language="JavaScript">
			for (var i = 1; i < 4; i++) {
				var apply = document.getElementById("apply-button-" + i);
				if (apply != null) {
					apply.name = "next";
					apply.value = "Next Step >>";
				}
			}
			var spans = document.getElementsByTagName("span");
			for (s in spans) {
				if (spans[s].className == "hideme") {
					spans[s].style.display = "none";
				}
			}
		</script>
END;
}


/**
 * Handle the button press for Next or Previous buttons
 */
function handle_prev_next($step_list_name='main_steps'){
    global $this_step;
    global $$step_list_name;

    $list = $$step_list_name; 
    if( empty($list) ) return;

    if( get_posted('next') ){ // form posted via 'NEXT' button'
        $u = $list[++$this_step]->url;
        if( !empty($u) ) {
            clear_steps_after();      // Clear all steps after this one
            header("Location: $u");   // Redirect!
            exit(0);
        }
    }
    if( get_posted('previous') ){ // form posted via 'NEXT' button'
        $u = $list[--$this_step]->url;
        if( !empty($u) ) {
            header("Location: $u");   // Redirect!
            exit(0);
        }
    }
}

?>
