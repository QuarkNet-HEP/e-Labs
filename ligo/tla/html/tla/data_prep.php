<?php
/***********************************************************************\
 * data_prep.php  - prepare data: generate second-trend or raw frame files
 *
 * This page presents a simple form which asks for a GPS interval,
 * the trend type, and IFO name.   It then launches a task to insure
 * that frame files exist in that GPS interval for that IFO and that
 * trend type (second-trends or raw).  If they do, it will finish quickly.
 * If not, any gaps will be filled in.
 * 
 * When the task is launched the page returns a process ID, which can
 * be used to query the status of a task previously launched.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 3 September 2008
 * @(#) $Id: data_prep.php,v 1.2 2008/09/12 20:01:08 myers Exp $
\***********************************************************************/

  // GOAL IS TO MAKE THIS RUN SEPARATE FROM BLUESTONE CORE!
  // So remove as many files from 'macros.php' as you can.

require_once("macros.php");              // general utilities

require_once("decoration.php");         // page decorations
require_once("controls.php");         // page decorations
require_once("time.php");               // time functions


if( !isset($hostname) ) $hostname=trim(exec('hostname -s'));

$task_status='';


$task_msgs[0] = '';



/***********************************************************************\
 * Functions
\***********************************************************************/

if( !function_exists('get_posted') ){ // from util.php
    function get_posted($key){ 
        if( array_key_exists($key, $_POST) ) {
            return strip_tags($_POST[$key]);
        }
        return NULL;
    }
 }



/***********************************************************************\
 * Action:
\***********************************************************************/


// Task Submission:

$GPS_start_time = get_posted('GPS_start_time');
if( !is_numeric($GPS_start_time) || ($GPS_start_time < 73012346) ){
    unset($GPS_start_time);
 }
//debug_msg(1,"GPS_start_time: $GPS_start_time");


$GPS_end_time = get_posted('GPS_end_time');
if( !is_numeric($GPS_end_time) || ($GPS_end_time < 730123456) ){
    unset($GPS_end_time);
 }
//debug_msg(1,"GPS_end_time: $GPS_end_time");


$ttype = get_posted('ttype');
$IFO   = get_posted('IFO');

$submit = get_posted('submit');



// Task Query:

$TaskID = get_posted('TaskID');

$query = get_posted('query');


/* Launch data-prep task - (second trends or raw data)
 *
 * launch a task in the background to run update-rds.php 
 * with the new -x flag to generate any missing frame files,
 * quickly skipping over existing frames in the RDS.
 * With any luck this will be all done before the user presses
 * the GO button.  Or we can check that the task has finished before
 * allow the GO button to work.
 */

if( $submit && $GPS_start_time && $GPS_end_time && $ttype && $IFO ){

    debug_msg(1,"Launching data prep task...");

    // Run shell script to perform task
    //
    $cmd = $BIN_DIR."/data_prep.sh -t $ttype -i $IFO ";
    $cmd .= " -s $GPS_start_time -e $GPS_end_time";
    $cmd .= " >&/tmp/data_prep_err.txt >/tmp/data_prep_out.txt  & ";
    // Appending this causes command to report PID of background task
    $cmd .=" echo \$! ";

    $out="";
    $data_prep_pid = exec($cmd,$out,$rc); // runs in csh

    if($rc) add_message("ERROR? data_prep lanuch code: ".$rc, MSG_WARNING);
    if( empty($data_prep_pid) ) debug_msg(1,"NO data_prep_pid returned");

    if( !empty($out) ){
        $data_prep_pid = $out[0]; 
        debug_msg(2, "% $cmd", MSG_WARNING);
        $i = 0;
        foreach($out as $line){
            debug_msg(2, $line, MSG_WARNING);
            $i++;
        }
    }

    // If the process lanuched sucessfully then generate 
    // a token to refer to it later:

    if( !$rc && $data_prep_pid ) {
        add_message("Data preparation/verification task launched (pid $data_prep_pid)");

        $TaskID = "$hostname:$data_prep_pid";
        $GPS_start_time='';
        $GPS_end_time='';
    }
 }


// Check Task Status

//
if( $TaskID ){
    $n=preg_match("/^([^:]+):(\d+)$/", $TaskID, $matches);
    if( $n > 0){        
        list($all, $run_host,$run_pid) = $matches;
        debug_msg(1, "Query pid $run_pid on host $run_host from host ".
                        $hostname);
        if( $run_host != $hostname){
            $task_status = "Query to $run_host not yet working...";
        }
        if( $run_host == $hostname ){
            $x = trim(`ps --no-headers $run_pid `);
            if( !empty($x) ) {
                $task_status = "Task $TaskID is running.";
            }
            else {
                $task_status = "Task $TaskID is NOT running.";
            }
        }
    }
    else {
        $task_status = "Task ID not found / not parsed";
    }
 }




/***********************************************************************\
 * Display the page:
\***********************************************************************/

html_begin("Data Preparation");
controls_begin();


if( $TaskID ){

  echo "<TABLE width='80%' border=1 align='center'><TR><TD>\n";
  echo "<TABLE width='100%' border=0><TR>\n";

  echo "<TD valign='top' colspan='2'>
          <b>Task Status:</b> <p>";


  if( $submit ) {
      echo "          The data preparation task was launched . ";
      echo " To query   the stautus use \n";
  }
  echo "
          <blockquote><font size='+1' color='blue'>
          TaskID:&nbsp;&nbsp; $TaskID 
          </font></blockquote>
          ";

  if( $task_status){
      echo "<center><font color='orange'>\n";
      echo "$task_status \n";
      echo "</font></center>\n";
  }

  echo " </TR>\n</TABLE>\n ";
  echo " </TD></TR></TABLE>\n ";

 }// Task launch


echo "<P>
      Use this form to request generation of frame files for the
      I2U2 Reduced Data Set for a given time interval. 
      <P>\n";
               


echo "<TABLE width='100%' border=1><TR><TD>\n";
echo "<TABLE width='100%' border=0><TR>\n";

echo "<TD valign='top' colspan='2'>
        <b>Frame File parameters:</b> <p>
        Enter a time interval, data type, and site.  
        A task will be launched to verify that frame files exist
        for this time interval, or else they will be created.
      </td>\n";


echo " </TR><TR>\n";

echo "<TD> Starting GPS Time:
                <input type='text' name='GPS_start_time'
                       size=12 value='$GPS_start_time'>
      </TD>\n ";

echo "<TD> Ending GPS Time:
                <input type='text' name='GPS_end_time'
                       size=12 value='$GPS_end_time'>

      </TD>\n";


echo " </TR><TR>\n";

echo "<TD>Data Trend Type:
      <select name='ttype'>
        <option value='T'> second trends</option>
        <option value='R'> raw data</option>
      </select>\n";

echo "  </TD>\n ";

echo "<TD> Site:
      <select name='IFO'>
        <option value='H0'> Hanford </option>
        <option value='L0'> Livingston </option>
      </select>\n";

echo "</TD>\n";

echo "     </TR><TR>\n";

echo "<TD colspan='2'>
        <blockquote>
        <input name='submit' type='submit' value='Submit'>
        </blockquote>
        When you push 'Submit' the task will be launched immediately.
        If you want to be able to check on the task later, be sure to
        remember the <i>Task ID</i> assigned to it when it is launched.
        </TD>\n";



echo " </TR>\n</TABLE>\n ";
echo " </TD></TR></TABLE>\n ";


// Query Task Status


echo "<TABLE width='100%' border=1><TR><TD>\n";
echo "<TABLE width='100%' border=0><TR>\n";

echo "<TD valign='top'>
        <b>Query Task status:</b><p>
        Enter the task ID for a previously launched data preparation
        task and we will show you the status of the task.
      </TD>\n";

echo "     </TR><TR>\n";

echo "<TD><b>Task ID:</b>
        <input name='TaskID' type='text' value='$TaskID'>
      </TD>\n";

echo "     </TR><TR>\n";

echo "<TD colspan='2'>
        <blockquote>
        <input name='query' type='submit' value='Query'>
        </blockquote>
        </TD>\n";

echo " </TR>\n</TABLE>\n ";
echo " </TD></TR></TABLE>\n ";


debug_msg(9, "data_prep.php: End.");

/*******************************
 * DONE:
 */

// end </form>

controls_end();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: data_prep.php,v 1.2 2008/09/12 20:01:08 myers Exp $";
?>
