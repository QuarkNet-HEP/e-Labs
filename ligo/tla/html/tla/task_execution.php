<?php
/***********************************************************************\
 * task_execution.php  -  manage execution of tasks
 *
 * Wait for a task to finish, or allow user to cancel task, etc.
 * 
 * This is presentation code.  For underlying functions for task
 * execution see execution.php
 *
 *
 * Eric Myers <myers@spy-hill.net  - 25 October 2007
 * @(#) $Id: task_execution.php,v 1.30 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");              // general utilities
require_once("root.php");                // also ROOT stuff
require_once("execution.php");           // task submission
require_once("elab_interface.php");      // JSP/HTTP interface

check_authentication();
handle_debug_level();
handle_user_level();
handle_auto_update();
handle_reset();

$this_step = update_step('main_steps');
recall_variable('msgs_list');

// General:
recall_variable('elab_group');
recall_variable('elab_cookies');

// Previous pages:
recall_variable('WorkFlow');
recall_variable('Ninputs');
recall_variable('input_channels');
recall_variable('channel_description');   

recall_variable('GPS_start_time');
recall_variable('GPS_end_time');
recall_variable('time_input_pref');

// Task launch:
recall_variable('task_id');
recall_variable('exec_type');   // REPLACE WITH TASK OBJECT?
recall_variable('Nplot');
recall_variable('launch_rc');

recall_variable('response_status');
recall_variable('response_headers');
recall_variable('response_body');

recall_variable('task_rc');
recall_variable('task_time_end');
recall_variable('task_time_start');
recall_variable('Ntry');
recall_variable('Nbusy');       // busy message display 


$slot=slot_dir()."/";   // working directory 
chdir($slot);


load_vi_settings($WorkFlow);

if( !empty($launch_rc) ) $task_rc = $launch_rc;     // from the launch


/***********************************************************************\
 * Action:  look for task files
\***********************************************************************/

debug_msg(9, "task_execution.php: Avanti!");

elab_ping();

debug_msg(2, "_GET['task_id']=".$_GET['task_id'].", isset(...)=".isset($_GET['task_id']));
// If the task_id is in the URL then use that instead
//
if( isset($_GET['task_id']) ){
    $task_id = $_GET['task_id'];
 }
debug_msg(2, "empty(task_id)=".empty($task_id));
// If the task_id is still empty then try to guess it, but worry about it.
// I changed empty() to isset(). Php treats '0' as empty, and '0' is a
// valid task id.
if( !isset($task_id) ){
    $task_id = uniq_id();
    debug_msg(1,"No task ID was set, so I'm guessing $task_id");
 }

debug_msg(1, "Task ID: $task_id  /  Slot: $slot");
//add_message("Execution: Task $task_id running via '$exec_type' ");


$logfile = $task_id .".log";
$donefile=$task_id. ".done";
$lockfile=$task_id . ".lock"; 
$pidfile=$task_id.'.pid'; 


if( empty($Ntry) ) $Ntry=0;


//TODO: if step[$this+1] is completed then do nothing, we are just
// looking around.



/********************
 * Process control button inputs here
 */

// Refresh Button: 
//   Just pushing the button submits the form and causes a refresh.
//   Nothing else need be done.


// Cancel Button: (might need to move down to 'local' section)
//
debug_msg(5,"Testing CANCEL button... ".$_POST['cancel']);
if( get_posted('cancel') ){
    debug_msg(1,"Cancel requested for task $task_id");
    debug_msg(2,"Checking for PID file $pidfile");
    if( !file_exists($pidfile) ) {
        debug_msg(1,"Cannot find PID of process.  Cannot Cancel task.");
    }
    else {
        list($task_pid) = explode(' ', trim(file_get_contents($pidfile)));
        debug_msg(1,"PID file contained $task_pid");
        if( !empty($task_pid) && is_numeric($task_pid) ) {
            debug_msg(1, "Process ID (PID) is $task_pid.  Kill it."); 
            system("kill -9 $task_pid");
            @unlink($lockfile);
            system("echo ".time()." 28   > $donefile");
        }
        else {
            debug_msg(1,"Error: PID $task_pid isn't numeric.");
        }
    }
 }



/********************
 * Local analysis:
 *
 * Check for lockfile, which indicates analysis is still running,
 * or check for donefile, which indicates that the task has finished,
 * and contains the return code from ROOT.
 */

if( $exec_type == 'local' ){

    debug_msg(1, basename($self).": Is local analysis still running?");
    $response_body='';

    debug_msg(2,"Checking for donefile $donefile");
    if( file_exists($donefile) ) {
        list($t_end, $task_rc) = explode(' ', trim(file_get_contents($donefile)));
        if( empty($t_end) || !is_numeric($t_end) ) $t_end = time();
        add_message( dateHms()." ! Analysis completed at "
                     . date('r', $t_end)
                     . "<br>&nbsp;&nbsp;  Return Code: $task_rc");

        if( $task_rc==0 ){ // No errors, so go forward
            set_step_status('main_steps', STEP_DONE );  // errors?

            $t = 1 + $debug_level;
            $u = $main_steps[$this_step+1]->url;  
            debug_msg(2," Task completed. Redirect in $t seconds to $u...");
            header("Refresh: $t ; URL=$u");
            //exit(0);
        }
        else {// Errors, so just stop here.
            set_step_status('main_steps', STEP_FAIL );  
            @unlink($lockfile);
            $x = root_error_text($task_rc); 
            if(!empty($x) ){
                $x = "<br/> Probable cause: $x ";
                $x .= "<br/> Please see the log files for further information.";
            }
            add_message(" Task completed,  but with errors. "
                        ."[Return Code $task_rc] $x", MSG_ERROR,2);
        }
    }
    else {// Not done yet.
    	set_step_status('main_steps', STEP_IN_PROGRESS);
        debug_msg(2,"Checking for lockfile $lockfile");
        if( file_exists($lockfile) ) {
            add_message( dateHms()."Task $task_id is still running.");
            $u = basename($self);

            // Check the error log for major error
            //
            $x = exec("grep Houston $logfile");
            debug_msg(2,"grep Houston $logfile gives:<br>  $x");
            if( !empty($x) ){
                set_step_status('main_steps', STEP_FAIL );  
                @unlink($lockfile);
                add_message(" Task failed: $x ", MSG_ERROR,2);
                $u = $main_steps[$this_step-1]->url;  
                $t = 5 + $debug_level;               
            }

            // Check the time
            //
            $t = $task_time_end - time();  // time remaining
            if( $t < 0 ) {
                $est_dt = $task_time_end - $task_time_start;
                if( abs($t) > (2*$est_dt + 900) ){ // overdue by twice estimate plus fifteen minutes
                    set_step_status('main_steps', STEP_FAIL );  
                    @unlink($lockfile);
                    add_message(" Task failed to complete in time ($est_dt sec). ", 
                                MSG_ERROR,2);
                    $u = $main_steps[$this_step-1]->url;  
                }
                $t = 5 + $debug_level;
            }

            header("Refresh: $t ; URL=$u");
            debug_msg(3, "Refresh in $t seconds...");
        }
        else{
            $cmdfile=$task_id . ".cmd"; 
            debug_msg(2,"Checking for cmd file  $cmdfile");
            $t = 5 + $debug_level;
            $u = basename($self);
            if( file_exists($cmdfile) ) {
                add_message( dateHms()."Task $task_id has started.");
                debug_msg(3, "Analysis has started.  Try again in $t seconds...");
            }
            else{
                add_message("Analysis Canceled or not yet started?  ".
                            "No cmdfile, no lockfile for task $task_id");
                $Ntry++;
                if( $Ntry > 4 ) {
                    set_step_status('main_steps', STEP_FAIL );  
                    $t = 5 + $debug_level;
                    $u = $main_steps[$this_step-1]->url;  
                    debug_msg(1," I give up. Going back in $t seconds...");
                }
            }
            header("Refresh: $t ; URL=$u");
        }
    }
 }// local execution


/********************
 * HTTP POST submission, local or abroad
 */
if ($exec_type == "swift") {
	debug_msg(2, "Checking on swift task ".$task_id." status");
	
	$form_url=ELAB_URL."/ligo/analysis/status-async.jsp?id=".$task_id;
    debug_msg(2,"POST URL: $form_url");
    recall_variable("re_arranged_ligo_cookies");
    $form_options=array( 'cookies' => $re_arranged_ligo_cookies );
    debug_msg(2, "Form options: ".print_r($form_options, TRUE));

    $response = http_get($form_url, $form_options);
        
    if (empty($response)) {
     	add_message("Failed to retrieve analysis status.", MSG_ERROR);
        add_message("Please see the log files for futher information. ",
                    MSG_WARNING);
        set_step_status('main_steps', STEP_FAIL);
        clear_steps_after();
    }
    else {
        
	    $response_status = parse_http_response($response,
                                               $response_headers,
       	                                       $response_body);
	    debug_msg(3,"HTTP status: $response_status");
 
        if ($response_status == 200) {
        
        	if (preg_match("/<form method=\"post\".*login\.jsp/", $response, $matches)) {
        		add_message("Error retrieving status: got the login page", MSG_ERROR);
		        add_message("Please see the log files for futher information. ",
        		            MSG_WARNING);
        	}
        	else {
		        $status_array = explode("&", $response);
    		    $status_fields = array();
        	
       			foreach ($status_array as $i) {
       				$pair = explode("=", $i);
	        		$status_fields[$pair[0]] = $pair[1];
	    	    }
    		    
				if ($status_fields["status"] == "Running") {
					add_message( dateHms()."Analysis $task_id is still running. Progress: ".$status["progress"]);
	        	    debug_msg(1,"Still in progress... keep on truckin...");
	            
	            	$t =  4;  
			        $u = $main_steps[$this_step]->url."?task_id=".$task_id;  
			        debug_msg(3, "Analysis is still running.  Try again in $t seconds...");
			        debug_msg(1," URL: $u");
		    	    header("Refresh: $t; URL=$u");
				}
				elseif ($status_fields["status"] == "Failed") {
					$form_url=ELAB_URL."/ligo/analysis/status.jsp?id=".$task_id;
					debug_msg(2, "Retrieving details from ".$form_url);
					$response = http_get($form_url, $form_options);
				
					$success = 0;
				
					if (!empty($response)) {
						$response_status = parse_http_response($response,
                	    			                           $response_headers,
       	    	                    			               $response_body);
				    	debug_msg(3, "HTTP status: $response_status");
					    if ($response_status == 200) {
					    	if (preg_match("@Execution failed:(.*)<hr\s*/>@U", $response, $matches)) {
								add_message("Reason for failure: ".$matches[1]);
								$success = 1;				    		
					    	}
					    	else {
					    		debug_msg(2, "Did not find failure reason in status page");
					    	}
					    }
					}
					if ($success == 0) {
						add_message("Failed to retrieve detailed analysis status.", MSG_ERROR);
						set_step_status("main_steps", STEP_FAIL);
						clear_steps_after();
					}
				}
				elseif ($status_fields["status"] == "Completed") {
					add_message( dateHms()."Analysis task $task_id is done.");
	            	set_step_status('main_steps', STEP_DONE);
	    	        $t =  1 + $debug_level;  
    	    	    $u = $main_steps[$this_step+1]->url;
        	    	header("Refresh: $t; URL=$u");
	        	    debug_msg(3,"Jumping in $t seconds forward to $u");
				}
			}
    	}
    	else {
    		add_message("Failed to retrieve analysis status.", MSG_ERROR);
	        add_message("Please see the log files for futher information. ",
                        MSG_WARNING);
       	    set_step_status('main_steps', STEP_FAIL);
           	clear_steps_after();
    	}
    }
}

if( $exec_type=='post'){

    debug_msg(2, basename($self).": Checking on task $task_id, "
              ." submitted via '$exec_type' ");
    debug_msg(3, "HTTP status: $response_status");


    // Check headers for a Location: or Refresh: header to tell us what's next.
    //
    $next_url = NULL;
    $next_dt = 10;

    $pattern = "/^Location: (.*)$/m";
    $n = preg_match($pattern, $response_headers, $matches);
    if($n>0) {
        list( $all, $next_url ) = $matches;
        debug_msg(1,"Got redirect via Location: $next_url ");
    }
    else{
        $pattern = "/^Refresh:.*(\d+).*;\s*URL=(.*)$/m";
        $n = preg_match($pattern, $response_headers, $matches);
        if($n>0) {
            list( $all, $next_dt, $next_url ) = $matches;
            debug_msg(1,"Got redirect via Refresh: $next_dt ;  $next_url ");
        }
    }

    // For Swift we can just get status directly if we have ID#

    if( !$next_url ){ // nowhere to go?
        debug_msg(1, "No next location! Aye Carumba. ");
        add_message("Analysis cannot continue!", MSG_ERROR);
        add_message("Please see the log files for futher information. ",
                    MSG_WARNING);
        set_step_status('main_steps', STEP_FAIL);
        clear_steps_after();
        $t =  17 + $debug_level;  
        $u = $main_steps[$this_step-1]->url;  
        header("Refresh: $t; URL=$u");
        debug_msg(1,"Jumping in $t seconds back to $u");
    }
    else {   
        
        // Are we 'done' yet?
        //
        if( strpos($next_url, "done") !== FALSE ){
            // or check for Swift completion...

            add_message( dateHms()."Analysis task $task_id is done.");
            set_step_status('main_steps', STEP_DONE);
            $t =  1 + $debug_level;  
            $u = $main_steps[$this_step+1]->url;  
            header("Refresh: $t; URL=$u");
            debug_msg(3,"Jumping in $t seconds forward to $u");
        }

        // Are we to check on progress?
        //
        elseif( 0 && strpos($next_url, "progress") !== FALSE ){
            // or check for Swift continuation...

            add_message( dateHms()."Analysis $task_id is still running.");
            debug_msg(1,"Still in progress... keep on truckin...");
            debug_msg(1," Hit: $next_url");

            //TODO: this may have to become POST not GET, to include 
            //      the session cookie
            //
            $response = http_get($next_url);
            $response_status = parse_http_response($response,
                                                   $response_headers,
                                                   $response_body);
            debug_msg(3,"HTTP status: $response_status");
            $t = $next_dt + $debug_level;
            $u = basename($self) . "?task_id=$task_id&slot=$slot&";
            header("Refresh: $t ; URL=$u");
            debug_msg(3, "Analysis is still running.  Try again in $t seconds...");
        }
        else {
            debug_msg(1, "Not done, not in progress.  Not sure what to do.");
        }
    }
 }// POST submission, local or Swift


 if( !empty($task_time_end) && $main_steps[$this_step]->status == STEP_IN_PROGRESS) 
    add_message("Expected to finish at " . gmdate('r',$task_time_end) );


/***********************************************************************\
 * Display Page:  form input for the basics
\***********************************************************************/

$title="Task progress: $task_id";
html_begin($title);
title_bar($title);
controls_begin();  // includes message area

// Task Control bar 
//
echo "<div class=\"control\">\n";

controls_next();

if( $task_rc != 0){
    show_log_files();
 }
 else{
	echo "<TABLE width='100%' border=0><TR>\n";
	if( $main_steps[$this_step]->status == 1){
		echo "<td valign='top'><b>Task completed!</b></td>\n";
	}
	else {
		echo "<td valign='top'><b>Task in progress...</b></td>\n";
	}
	echo "<td align='right' valign='top'>\n";
	echo GMT_clock_box();
	echo "</td></tr></table>\n";     

     // If we got a response body then strip out the insides
     // and show them.
     //
     if( !empty($response_body) ){

         debug_msg(4,"Size of response_body: ".strlen($response_body));
         $insides = "";

         $pattern = "%<content_body>(.*)</content_body>%si";
         debug_msg(4,"Range of content_body: "
                   . strpos($response_body,"content_body")." to "
                   . strrpos($response_body,"content_body") );

         $n = preg_match($pattern, $response_body, $matches);
         if($n>0) {
             list( $all, $insides ) = $matches;
             debug_msg(4,"Got content from <tt>content_body</tt> tag");
         }
         else{
             $pattern = "%<body .*>(.*)</body>%si";
             $n = preg_match($pattern, $response_body, $matches);
             if($n>0) {
                 list( $all, $insides ) = $matches;
                 debug_msg(4,"Got content from <tt>BODY</tt> tag");
             }
             else{
                 debug_msg(1,"Cannot parse response_body.", MSG_WARNING);
             }
         }


         // Strip out anything we don't want to show:
         //
         $insides= preg_replace("%<form.*</form>%si","",$insides); 
         $insides= preg_replace("%<script.*</script>%si","",$insides); 

         // If anything remains, show it 
         //
         if( !empty($insides) ){
             debug_msg(4,"Size of content body: ". strlen($insides));
             //TODO: convert ot iframe 
             echo "<TABLE width='100%' border=4 bgcolor=white><TR><TD>\n";
             echo $insides;
             echo "</TD></TR></TABLE>\n\n";
         }
         else {
             $x = 'img/busy2.gif';
             if( $exec_type=='post' && empty($next_url) ) {
                 $x = 'img/UnderConstruction.png';    // Until we get a "Warning" image
             }
             echo " <img width='50%' align='center' valign='middle' src='$x' >\n";
         }

     }
     else {// No response, so just show 'busy' image 
           // and something to think about while waiting.

         echo "<p style=\"text-align: center\">\n";

         $i = $Nbusy%4;
         debug_msg(3,"Nbusy is $Nbusy, i is $i");
         switch($i){
         case 0:
             $x = 'img/Speed_of_light_from_Earth_to_Moon.gif';
             echo " <img width='80%' align='center' valign='middle' src='$x'>\n";
             echo "</p>";
             echo "<p style=\"text-align: left;\">";
             echo " <br><b>Do you know?</b>
                The image above demonstrates the actual time 
                it would take for a beam of light to go from
                the Earth to the Moon. 
                How long does it take for light to go from the Moon
                to the Earth?
                <p>";
             break;
         case 1:
             $x = 'img/Speed_of_light_from_Earth_to_Moon.gif';
             echo " <img width='80%' align='center' valign='middle' src='$x'>\n";
             echo "</p>";
             echo "<p style=\"text-align: left;\">";
             echo " <br><b>Can you tell?</b>
                The image above shows a beam of light traveling from the 
                the Earth to the Moon.
                Are the sizes of the Earth and Moon
                to scale, or exagerated?
                <p>";
             break;
         case 2:
             $x = 'img/Speed_of_light_from_Earth_to_Moon.gif';
             echo " <img width='80%' align='center' valign='middle' src='$x'>\n";
             echo "</p>";
             echo "<p style=\"text-align: left;\">";
             echo " <br><b>Can you compute?</b>
                The image above shows a beam of light traveling from the 
                the Earth to the Moon.  
                How long would it take you to drive the same distance, 
                at 60 MPH?
                <p>";
             break;
         case 3:
             $x = 'img/Speed_of_light_from_Earth_to_Moon.gif';
             echo " <img width='80%' align='center' valign='middle' src='$x'>\n";
             echo "</p>";
             echo "<p style=\"text-align: left;\">";
             echo " <br><b>Do you know?</b>
                The image above shows a beam of light traveling from the 
                the Earth to the Moon.  
                How long does it take light to travel from the Earth
                to the Sun?
                <p>";
             break;
         }
         echo "</p>\n";


     }// response_body
}

echo "</div>\n";
echo "<div class=\"control\" style=\"text-align: center;\">\n";
if ($task_rc < 1) {
	echo "<input class=\"button\" type='submit' name='cancel' value='Cancel Task'>\n";
}
echo "<input class=\"button\" type='submit' name='refresh' value='Refresh Page'>\n";

echo " <a class='button' href='view_logs.php' target='_view'>
                  <input type='button' class='button' name='view_logs'
                                       value='View Logs'></a>\n";     

echo "</div>\n"; 


if( $debug_level > 2 && ($response_headers || $response_body) ) {
    display_http_response($response_headers,$response_body);
 }

controls_end();

echo "<P>\n";



/*******************************
 * DONE:
 */
debug_msg(9, "task_execution: End.");

remember_variable('main_steps'); 
remember_variable('this_step'); 
remember_variable('msgs_list');

// This page and the next:
remember_variable('WorkFlow');
remember_variable('Ninputs');
remember_variable('GPS_start_time');
remember_variable('GPS_end_time');
remember_variable('input_channels');

// Launch parameters:
remember_variable('launch_rc');
remember_variable('task_rc');
remember_variable('task_id');
remember_variable('exec_type');
remember_variable('task_time_end');
remember_variable('task_time_start');
  
// Launch response/Status Query:
remember_variable('response_status');
remember_variable('response_headers');
remember_variable('response_body');
remember_variable('Ntry');

tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: task_execution.php,v 1.30 2009/04/29 20:43:24 myers Exp $";
?>
