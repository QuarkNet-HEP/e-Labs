<?php
/***********************************************************************\
 * control_panel.php  - user controls for execution of the analysis
 *
 * This page presents the user with a summary of the execution of 
 * the task, along with controls for execution, such as selecting "local" 
 * or "grid".   This is separate from the pages which let you select
 * inputs, options, or parameters for the task itself. 
 *
 * If everthing is okay and we can launch a task to execute then the
 * user gets a GO button.  
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: control_panel.php,v 1.73 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");              // general utilities
require_once("root.php");                // also ROOT stuff
require_once("execution.php");           // task submission

check_authentication();
handle_debug_level();
handle_user_level();
handle_auto_update();
handle_reset();

$this_step = update_step('main_steps');
recall_variable('msgs_list');
recall_variable('SESSION');

// General:
recall_variable('elab_group');
recall_variable('elab_cookies');

// From previous pages: 
recall_variable('WorkFlow');
recall_variable('Ninputs'); 
recall_variable('input_channels');

recall_variable('GPS_start_time');
recall_variable('GPS_end_time');
recall_variable('time_input_pref');

// This way of passing IDs will probably not work with
// concurrent analyses in the same session
// Task launch:
recall_variable('task_id');
recall_variable('exec_type');   // REPLACE WITH TASK OBJECT
recall_variable('Nplot');
recall_variable('launch_rc');   

// Task failure brings us back:
recall_variable('task_rc');



$slot=slot_dir()."/";   // working directory 

$is_go=true; // assume the best...


/***********************************************************************\
 * Action:
\***********************************************************************/

debug_msg(9, "control_panel.php: Action!");

elab_ping();


// Pressing 'Apply' lets us reset this step, unless
// other problems found below.
//
if( get_posted('apply') ){
        set_step_status('main_steps', STEP_NEW ); 
 }



// Cross-check WorkFlow selection and load settings
//
if( $x = get_posted('WorkFlow') ) $WorkFlow=$x;

if( !isset($WorkFlow)) {
    $main_steps[1]->status=STEP_NEW;
    set_step_status('main_steps', STEP_FAIL );     
    add_message("You need to select a work flow.", MSG_ERROR);
 }

load_vi_settings($WorkFlow);


// Cross-check

if( empty($Ninputs) ) {
    $main_steps[1]->status=STEP_NEW;
    set_step_status('main_steps', STEP_FAIL );     
    add_message("Number of input channels is not set.", MSG_ERROR);
 }

if( $Ninputs < 1  ) {
    $main_steps[1]->status=STEP_FAIL;
    add_message("Something is wrong. Ninputs is $Ninputs.", MSG_ERROR);
 }




// Cross-check time interval
//
$t_end = GPS_to_Unix($GPS_end_time);
if( $t_end > time() ){
    $GPS_end_time = Unix_to_GPS(time());
 }
$dt = $GPS_end_time - $GPS_start_time;

if( $dt<=0 ) {
    $main_steps[$this_step-1]->status=STEP_FAIL;    
    add_message("Something is wrong with the time interval.", MSG_ERROR);
    $u = $main_steps[$this_step-1]->url;
    header("Location: ".$u);                   // Go back
    exit(0);
 }



// Cross-check input channels, create description(s)
//
for($i=1;$i<=$Ninputs;$i++){

    if( !($input_channels[$i]->is_valid()) ) {
        $main_steps[$this_step-1]->status=STEP_FAIL;    
        add_message("Input channel $i is invalid.", MSG_ERROR);
        continue;
    }

    if( empty($input_channels[$i]->name) ){
        $main_steps[$this_step-1]->status=STEP_FAIL;  
        add_message("Input channel $i has no name.", MSG_ERROR);
        continue;
    }

    // Station description

    $st = $input_channels[$i]->station;
    if( $user_level==1 && !empty($station_desc) ){
        if( !isset($station_desc[$st])) {
            $st = $station_desc[$st];
        }
    }

    // Channel description information (based on user level)

    $x = $input_channels[$i]->site. ", " .$st. ", ";
    if($user_level==1) $x .= $input_channels[$i]->desc;
    if($user_level==2) $x .= $input_channels[$i]->info;
    if($user_level>2)  $x .= $input_channels[$i]->name;
    $channel_description[$i]=$x;


    // Channel Units (redundant, as this should be set in ROOT).
    //
    $input_channels[$i]->set_units();

    $u = $input_channels[$i]->units;
    if( empty($u) ){
        add_message("Input channel $i has no units.", MSG_WARNING);
    }
    else {
        debug_msg(3, "Input channel $i has units $u.");
    }
 }



// Alteration to make pressing 'Next' button same as pressing 'Go'
//
if( get_posted('next') ){
    $_POST['submit_task'] = $_POST['next'];
    unset($_POST['next']);
 }



// User pressed Next or Previous?

handle_prev_next('main_steps');   // *after* any possible user input

// Get exec_type from input

handle_exec_type();


//TODO: Create new TASK OBJECT from this type, save in Session?



/**
 * Estimate effort
 */

debug_msg(9, "control_panel.php: Effort.");

//TODO: this is only good for one channel.  Need to generalize it.
//      (need to generalize it by transformation, not just number of
//       channels) 

$ttype = $input_channels[1]->ttype;
$samp_rate = $input_channels[1]->rate;

if( $ttype == 'M' ) {
    $frame_length = 3600;
    $samp_path = "trend/minute-trend/";
 }

if( $ttype == 'T' ){
    $frame_length = 60;
    $samp_path = "trend/second-trend/";
 }

if( $ttype == 'R' ) {
    $frame_length = 32;
    $samp_path = "raw/S5/L0/";
    $GPS_block = 1e5;
 }



$Nframes = intval(($dt/$frame_length) +0.5);

// This fills in estimated run times 
// and gives us the best of them
//
$best_exec_type = estimate_run_times($Nframes);
$best_exec_time = $exec_list[$best_exec_type]->run_time;



// Limits for beginners (generalize this?) 
//
if( $user_level == 1 ) {
    if ( $best_exec_time > 300 ) {
        add_message("Warning: your estimated run time is too long.",
                    MSG_ERROR);
        $main_steps[$this_step]->status=STEP_FAIL;  
    }
    elseif ( $best_exec_time > 60 ) {
        add_message("Warning: your estimated run time is a bit long.",
                    MSG_WARNING);
    }
 }



/***************************
 * Launch data-prep task - (second trends or raw data)
 *
 * If we've passed all the tests above, and we  just came here
 * from data_select.php,  and we are dealing with second-trend or
 * raw data, then launch a task in the background to run update-rds.php 
 * with the new -x flag to generate any missing frame files,
 * quickly skipping over existing frames in the RDS.
 * With any luck this will be all done before the user presses
 * the GO button.  Or we can check that the task has finished before
 * allow the GO button to work.
 * 
 * This is not the best way to check the status of data for 
 * a time interval, but it will do until we have a working
 * database for segments and Data Quality 
 *
 * Another way to do this is to make this data-prep a separate
 * analysis task, which the user runs first to insure that data
 * are present for further analyses.
 *
 */

debug_msg(9, "control_panel.php: Data preparation.");

if( $came_from == "data_select.php" &&
    ($ttype == "T" || $ttype == "R") ){

    debug_msg(1,"Launching data prep task...");
    $is_go=false;

    $cmd = $BIN_DIR."/data_prep.sh -t $ttype -s $GPS_start_time -e $GPS_end_time";
    $cmd .= " >&prep_data_err.txt >prep_data_out.txt  & ";

    // cause command to report PID of background task
    $cmd .=" echo \$! ";

    $out="";
    $prep_data_pid = exec($cmd,$out,$rc); // runs in csh
    if($rc) add_message("ERROR? prep_data lanuch code: ".$rc, MSG_WARNING);
    if( empty($prep_data_pid) ) debug_msg(1,"NO prep_data_pid returned");
    if( !empty($out) ){
        $prep_data_pid = $out[0]; 
        debug_msg(2, "% $cmd", MSG_WARNING);
        $i = 0;
        foreach($out as $line){
            debug_msg(2, "$i) ".$line, MSG_WARNING);
            $i++;
        }
    }

    // if the process lanuched then remember the pid for later

    if(!$rc && $prep_data_pid ) {
        global $prep_data_pid;
        remember_variable('prep_data_pid');
        add_message("Data preparation/verification task launched (pid $prep_data_pid)");
        set_step_status('main_steps', STEP_NEW );  
        add_message(" Check on it in 5 seconds...");
        header("Refresh: 5; URL=control_panel.php");

        if($h = fopen("prep_data.pid","w")){
            fwrite($h, $prep_data_pid);
            fclose($h);
        }
        else {
            debug_msg(1,"Error: cannot write prep_data.pid file");
            set_step_status('main_steps', STEP_FAIL );  
        }
    }
 }


/********************
 * Check status of data_prep 
 */

debug_msg(9, "control_panel.php: Data prep still running?");

if( !isset($prep_data_pid) &&  file_exists("prep_data.pid")){

    $prep_data_pid =  file_get_contents("prep_data.pid");
    if(!empty($prep_data_pid) && is_numeric($prep_data_pid) ){
        $out="";
        $cmd = "/bin/ps -p $prep_data_pid";
        $txt = exec($cmd,$out,$rc); // runs in csh
        if( !empty($txt) ) debug_msg(4, "txt: $txt");

        if($rc==0){
            add_message("Data prep task is still running (pid $prep_data_pid)");
            set_step_status('main_steps', STEP_NEW );  // errors?            
            $is_go = false;
            add_message(" Check again in another 5 seconds...");
            header("Refresh: 5; URL=control_panel.php");
        }
        elseif ($rc==1) { // not running, so flag it as OK
            unlink("prep_data.pid");      
            add_message(" Data preparation task has ended.");           
            set_step_status('main_steps', STEP_DONE );   
        }
        else {
            debug_msg(1, "ERROR? /bin/ps return code: ".$rc, MSG_WARNING);
            debug_msg(1, "% $cmd");
            if( is_array($out) && count($out) > 1 ){
                $i = 0;
                foreach($out as $line){
                    debug_msg(1, "$i) ".$line, MSG_WARNING);
                    $i++;
                }
            }
        }
    }
 }


/***********************************************************************\
 * Engage Execution Engine!
 *
 * (This needs to be more robust.  Run process in the background, get pid,
 * check on status of all running processes).
 */

debug_msg(7, "control_panel.php: Engage!");

/**
 * Verify all steps up to here are good to go:  
 * Previous steps are OK, and this step is not FAIL.
 */

for($i=1; $i<$this_step;$i++){
    $is_go = $is_go && ($main_steps[$i]->status>0);
 }
$is_go = $is_go && ($main_steps[$this_step]->status>=0);

if($is_go) {
    flush_channel_info();  // Clean up, save memory 
    $plot_options=array();      // reset all plot options on 'GO'
    remember_variable('plot_options');  
 }

// If not ready yet, then just ask user to review and press GO
//
if( !$is_go || !get_posted('submit_task') ){ // not ready, or no button push?
    if( $user_level < 3 && $main_steps[$this_step]->status==STEP_DONE ){
        add_message("Please evaluate your proposed execution time to see "
                    ." if it is reasonable.  Press GO to launch the task.");
    }
 }

debug_msg(2, "Is go: $is_go");

if( $is_go && get_posted('submit_task') ){ // ready and GO!
    if( empty($exec_type) ){
        debug_msg(1,"Execution type unknown.");
        $exec_type='unknown';
    }
	
    // Fresh start...
    //
    clear_log_files();
    clear_plot_files();
    clear_steps_after();
    $task_id = uniq_id();
    $Nplot = 1;
    $Ntry=1;
    $Nbusy = rand(0,100);  // random number controls busy message


    // The actual work is done in the slot directory
    chdir($slot);
    // Wonderful assumption for remote execution ;)

    add_message(dateHms()." Engage: Task $task_id to be run as '$exec_type' "
                ."in slot ".getcwd() );

	debug_msg(2,"Exec type: $exec_type");

    // Local:
    //
    if( $exec_type=='local' ){


        $launch_rc = task_launch($task_id, TRUE);
        debug_msg(1,"Launching task $task_id returned $launch_rc");

        /* Verify ROOT script _started_ correctly  */

        if( !$launch_rc ){
            set_step_status('main_steps', STEP_DONE ); 
            add_message( dateHms()."Analysis launched.  Please stand by...",
                         MSG_GOOD);
            $task_time_start = time();
            remember_variable('task_time_start');
            $t = $exec_list['local']->run_time;
            $task_time_end = time()+$t;
            remember_variable('task_time_end');
            add_message("Expected to finish in $t seconds, at "
                        . gmdate('r',$task_time_end) );
 
            $task_rc=0;
            remember_variable('task_rc');
            //$t = 1 + $debug_level;
            $t = 0;
            $u = $main_steps[$this_step+1]->url;  
            header("Refresh: $t; URL=$u");
        }
        else {
            add_message("Analysis launch FAILED!", MSG_ERROR);
            add_message("Please see the log files for futher information. ",
                        MSG_WARNING);
            set_step_status('main_steps', STEP_FAIL);
            $main_steps[$this_step+1]->status = STEP_NEW ; 
            $is_go=false;
        }
    }


    /* POST method of execution (via web form somewhere else)
     * is used to submit a local task or to Swift  */

    if( $exec_type=='post' || $exec_type=='swift'){

        // POST to run local task
        //
        if( $exec_type=='post' ){ 
            $form_url="http://".$local_server.$this_dir."/plot1chan_submit.php";
            debug_msg(3,"POST URL: $form_url");

            $form_fields = array('outputDir' => $slot, 
                     'chName' => $input_channels[1]->name,
                     'GPS_start_time' => $GPS_start_time,
                     'GPS_end_time' => $GPS_end_time,
                     'time_input_pref' => $time_input_pref,
                     'slot_dir' => $slot,
                     'submit_task_via_POST' => 'POST',
                     );
            $form_files=array();  // no files (for now)
            $form_options=array( 'cookies' => array( 'auth' => $auth ) );
        }

        // POST to Swift
        //
        if( $exec_type=='swift' ){

            $form_url=$exec_list['swift']->submit_url ;
            debug_msg(2,"POST URL: $form_url");

            elab_login(); // should set $elab_cookies

            $form_fields = array('outputDir' => $slot,
            					 'task_id' => $task_id,
                                 'GPS_start_time' => $GPS_start_time,
                                 'GPS_end_time' => $GPS_end_time,
                                 'channelName' => $input_channels[1]->name, 
                                 'timeFormat' => $time_input_pref, 
                                 'channelName' => $input_channels[1]->name,
                                 'submit' => 'Analyze' 
                                 );
            $form_files=array();  // no files (for now)
            $ligo_cookies = $elab_cookies['ligo'];
            //According to the docs at us3.php.net/manual/en/http.request.options.php,
            //"list of cookies as associative array like array("cookie" => "value")
            $re_arranged_ligo_cookies = array();
            $re_arranged_ligo_cookies[$ligo_cookies['Name']] = $ligo_cookies['Value'];
            remember_variable("re_arranged_ligo_cookies");
            $plot_id = $task_id;
            remember_variable("plot_id");
            debug_msg(2, "JSESSIONID: ".$re_arranged_ligo_cookies['JSESSIONID']);
            $form_options=array( 'cookies' => $re_arranged_ligo_cookies );
        }


        // Submit via POST:
        //
        $response = http_post_fields($form_url, $form_fields, $form_files,
                                     $form_options ); 

		debug_msg(2, "posted");
        if( empty($response) ){
            add_message("Remote analysis failed! No reponse.", MSG_ERROR);
            add_message("Please see the log files for futher information. ",
                        MSG_WARNING);
            set_step_status('main_steps', STEP_FAIL);
            clear_steps_after();
            $is_go=false;
        }

        // Parse what we got back.  
        //   302 response means form was posted (at least for PHP). 
        //   200 response means something came back.  Could be good or bad.
        //
        if( $response ){
            $response_status = parse_http_response($response,
                                                   $response_headers,
                                                   $response_body);
            debug_msg(3,"HTTP status: $response_status");

            if( $response_status==302 ){// POST response 'submitted'

                add_message( dateHms()."Analysis launched. "
                             ."Please stand by...", MSG_GOOD);
                set_step_status('main_steps', STEP_DONE ); 
                $is_go=false;  // because we've already launched 
                               // TODO: show different message?
                remember_variable('response_status');
                remember_variable('response_headers');
                remember_variable('response_body');
                $t =  3 + $debug_level;  
                $u = $main_steps[$this_step+1]->url;  
                header("Refresh: $t; URL=$u");
            }
            elseif( $response_status==200 ){// got a page back
                // Look for JSESSIONID cookie from Swift, we'll need it.
                // But will that be enough to get us through all steps?
                // Trick: append my own Location: url to $response_headers
                //         (don't forget \r\n)
                debug_msg(3, "HTTP Response: $response");
                if (preg_match("/status\.jsp\?id=([0-9]*)/", $response, $matches)) {
                	$task_id = $matches[1];
                	debug_msg(3, "Task id: $task_id");
                }
                add_message("Remote analysis start? maybe/maybe not.", MSG_WARNING);
                add_message("Status code ".$response_status
                            ." means something came back.", MSG_WARNING);

                set_step_status('main_steps', STEP_DONE); 
                clear_steps_after();
                $is_go=false;           // because we've lanuched once

                remember_variable('response_status');
                remember_variable('response_headers');
                remember_variable('response_body');
                $t =  3 + $debug_level;  
                $u = $main_steps[$this_step+1]->url."?task_id=".$task_id;
                debug_msg(3, "Redirect to $u");
                header("Refresh: $t; URL=$u");
            }
            else {
                add_message("Remote analysis failed to submit", MSG_ERROR);
                add_message("Status code: $response_status  (huh?)", MSG_WARNING);
                set_step_status('main_steps', STEP_FAIL ); 
                clear_steps_after();
                $is_go=false;
            }

        }// got a response
    }// POST or Swift?
 }//GO!

debug_msg(5,"Nplot is $Nplot, Ntry is $Ntry");



/***********************************************************************\
 * Display the page:
\***********************************************************************/

$title="Control Panel";
html_begin($title);
title_bar($title);
controls_begin();


/**
 * Data Flow:
 */
$wf = $WorkFlow_list[$WorkFlow];
echo "<div class=\"control\">\n";
echo "<b>Analysis Type:</b> $wf->name ";
if( $user_level == 1 ) echo "- $wf->desc "; 
if( $user_level == 2 ) echo "- $wf->info "; 

echo "</div>\n";

echo "<div class=\"control\">\n";
if( $Ninputs==1 ) echo "<b>Input Channel:&nbsp;</b> ";
else           echo "<b>Input Channels:&nbsp;</b> ";


for($i=1; $i<=$Ninputs;$i++){
  echo "\n<br>&nbsp;&nbsp;" . $channel_description[$i]; 
  echo "[$ttype] ";
}
echo "</div>\n";


/**
 * Time Interval:
 */
echo "<div class=\"control\">\n";
echo "<b>Time interval:</b>";
echo printable_dt($dt);

echo " (estimated $Nframes frame files) <br/>\n";


debug_msg(6,"User's input time preference is $time_input_pref");

echo "&nbsp;&nbsp;".GPS_to_User($GPS_start_time);

if($user_level>2) echo  " (".GPS_to_Other($GPS_start_time). ") ";
echo  "\n to ". GPS_to_User($GPS_end_time); 
if($user_level>2) echo " (" .GPS_to_Other($GPS_end_time). ") ";
echo " </p>\n";

/*****************
 * task-specific controls or inputs are invoked here,
   via some kind of hook function

controls_next();
echo "<P align='center'>
        [There are no controlable parameters for the selected data flow,
        <br>
        but if there were, they would appear here.]

        </p>\n";
****************/

echo "</div>\n";
/**
 * Execution Controls:
 */
echo "<div class=\"control\">\n";
echo "<b>Execution:</b><br/>
        &nbsp;&nbsp;Select how you want to run your analysis:"
        . help_link("Execution type") ."<br/>\n";

if( empty($exec_type) ) $exec_type = $best_exec_type;
exec_type_options();



/**
 * Only show the GO button if we really are ready to go.
 */

if( !$is_go ){
     if( $main_steps[$this_step-1] == STEP_FAIL ){
         echo "<P align='RIGHT'><font color='RED'> 
                Correct all problems before proceeding.
                </font></p>\n";
     }
}

/*if( $launch_rc >0 || $task_rc >0 || $debug_level > 2 ) {
  show_log_files($Nplot);
}*/


if( $debug_level > 2 && ($response_headers || $response_body) ) {
    display_http_response($response_headers,$response_body);
}

echo("</div>\n");

controls_end();

debug_msg(9, "control_panel.php: End.");

/*******************************
 * DONE:
 */

// General:
remember_variable('SESSION'); 
remember_variable('main_steps'); 
remember_variable('this_step'); 
remember_variable('msg_list'); 

// From previous pages: 
remember_variable('WorkFlow');
remember_variable('Ninputs');
remember_variable('input_channels');
remember_variable('channel_description');   

remember_variable('GPS_start_time');
remember_variable('GPS_end_time');
remember_variable('time_input_pref');

// Task launch:
remember_variable('task_id');
remember_variable('exec_type');   // REPLACE WITH TASK OBJECT?
remember_variable('Nplot');
remember_variable('launch_rc');   
remember_variable('Nbusy');

tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: control_panel.php,v 1.73 2009/04/29 20:43:24 myers Exp $";
?>
