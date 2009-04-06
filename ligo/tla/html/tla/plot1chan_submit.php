<?php
/***********************************************************************\
 * plot1chan.php - simple web form for launching an analysis 
 *
 *
 * Eric Myers <myers@spy-hill.net  - 23 October 2007
 * @(#) $Id: plot1chan_submit.php,v 1.9 2008/03/27 16:21:16 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities
require_once("root.php");                // also ROOT stuff

require_once("../boinc_html/inc/util.inc");  // for the table stuff 

handle_debug_level();                   // so we can get more verbose
//require_authentication();

$something_missing=false;

$task_name='plot1chan';



/***********************************************************************\
 * Functions:
\***********************************************************************/

function bad_input($reason){
    global $something_missing;
    add_message("* $reason", MSG_ERROR);
    $something_missing=true;
}


/***********************************************************************\
 * ACTION:  process form inputs.  
\***********************************************************************/

$task_id = get_posted('task_id');
$chName = get_posted('chName');
$GPS_start_time = get_posted('GPS_start_time');
$GPS_end_time = get_posted('GPS_end_time');
$time_input_pref = get_posted('time_input_pref');


// Submit task? Let's examine the inputs first
//
$submit_task_via_POST = get_posted('submit_task_via_POST');

if( !empty($submit_task_via_POST) ){

    // Input conditioning:  this is much less strict than the full
    // Bluestone interface.  Here we just check the basics.
    //
    if( empty($task_id) ){
        bad_input("You must specify a unique plot ID.");
    }
    if( empty($chName) ) {
        bad_input("You must specify a data channel to plot.");
    }
    if( empty($GPS_start_time) ) {
        bad_input("You must specify a starting GPS time.");
    }
    if( empty($GPS_end_time) ) {
        bad_input("You must specify a final GPS time.");
    }
    if( $GPS_end_time <= $GPS_start_time){
        bad_input("End time must come AFTER the starting time.");
    }

    if( ($time_input_pref != 'GMT') &&  ($time_input_pref != 'GPS') ){
        $time_input_pref = 'GMT';
    }


    // If all inputs are there, then run the task in the background
    //
    if( !$something_missing ){
        // the argument is a Channel object
        $ch1->name = $chName;
        $ch1->ttype = 'M';
        $ch1->tcomp = 'mean';

        $slot=slot_dir();

        debug_msg(1, "Launching task $task_id in slot $slot...");

        // Log that we have submitted the task
        // TODO: Someday this should write to a database not a file
        //
        $fname=$slot."/".$task_id.".submit";
        if( !$h = fopen($fname, 'w') ){
            debug_msg(1,"Cannot write to submission log file $fname");
        }
        else { // start sketching parameter file
            $x = date('U'). " $task_id  POST $local_server "
                ." $task_name(".$ch1->name.",$GPS_start_time,$GPS_end_time)";
            fwrite($h, $x);
            fclose($h);
        }
        // proof we did it this way 
        touch($slot."/Kilroy_was_here"); 

        $rc = plot1chan($task_id, $ch1,
                             $GPS_start_time,$GPS_end_time,
                             $time_input_pref,
                             TRUE);  // Run in background

        // If it launched then go to progress page
        //
        if( !$rc ){
            header("Location: plot1chan_progress.php?task_id=$task_id&slot=$slot&");
            exit;
        }
        if( is_numeric($rc) && $rc != 0 ){
            add_message("ROOT task failed to launch. RC=$rc", MSG_ERROR);
        }
    }
 }// submit_task_via_POST



/***********************************************************************\
 * DISPLAY Page:  form input for the basics
 \***********************************************************************/

html_begin("Analysis: $task_name");

echo "\n<style type='text/css'>
.description {
    font-size: 80%;
    font-weight: normal;
}
</style>\n";


echo "This form will submit an analysis task to
      plot the specified data channel
      between the given GPS times (using minute-trends).\n";


controls_begin();

start_table();

row2("<b>Unique ID:
        </b><br><span class='description'>
        A token which is used to identify <b>your</b> task.</span>",  
     "<input name='task_id'  value='$task_id' size='32'>"
     );

row2("<b>Channel Name:
        </b><br><span class='description'>
        The name of the channel to plot</span>",
     "<input name='chName'  value='$chName', size='45'>"
     );

row2("<b>GPS Start Time:
        </b><br><span class='description'>
        Starting time of analysis segement, as a GPS time.",
     "<input name='GPS_start_time'  value='$GPS_start_time'>"
     );

row2("<b>GPS End Time:
        </b><br><span class='description'>
        Ending time of analysis segement, as a GPS time.</span>",
     "<input name='GPS_end_time'  value='$GPS_end_time'>"
     );

// Time axis preference
//
$time_prefs=array_of_values(array('GMT', 'GPS'));
$selection='GMT';
$out = "\n <select name='time_input_pref'>\n";
foreach ($time_prefs as $key => $value) {
    $out .= "        <option value='". $key. "' ";
    if ( $key == $selection ) {  $out .= " SELECTED "; }
    $out .=">". $value. "</option>\n";
}
$out .= "      </select>\n";

row2("<b>Time scale preference:
        </b><br><span class='description'>
        Display the time axis using GPS or GMT?</span>", $out );


$slot = slot_dir();
row2("<b>Slot directory:
        </b><br><span class='description'>
        Directory in which work will be done or results will appear.
        </span>"
     , " <tt>$slot</tt>
        <input type='hidden' name='slot_dir' value='$slot'> " );


// Make it so:
//
row2("<b>Execute task:
        </b><br><span class='description'>
        Execute the analysis.",
     "<input type='submit' name='submit_task_via_POST' value='POST'>"
     );

end_table();

controls_end();


/*******************************************************8
 * DONE: */

  echo "\n</form>\n";    
  echo "</BODY>\n</HTML>\n";

?>
