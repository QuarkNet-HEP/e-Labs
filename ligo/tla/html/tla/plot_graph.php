<?php
/***********************************************************************\
 * plot_graph.php - display (and possibly re-plot) graphical output
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: plot_graph.php,v 1.57 2009/05/26 20:55:38 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities
require_once("root.php");               // ROOT stuff too

check_authentication();
handle_debug_level();
handle_user_level();
handle_auto_update();
handle_reset();

$this_step = update_step('main_steps');
recall_variable('msgs_list');
recall_variable('SESSION');

// General:
//
recall_variable('elab_group');
recall_variable('elab_cookies');

// From previous pages:
recall_variable('Ninputs');
recall_variable('input_channels');
recall_variable('WorkFlow');

recall_variable('GPS_start_time');
recall_variable('GPS_end_time');

// This page:
recall_variable('root_rc');
recall_variable('Npens');
recall_variable('channel_description');
recall_variable('plot_options');
recall_variable('time_input_pref');
recall_variable('task_id');
recall_variable('Nplot');
recall_variable('Ntry');
recall_variable('exec_type');


$slot=slot_dir()."/";
chdir($slot);           // all work in the slot

// Links are into the slot
$slot_url = "slot/" . basename($slot) ."/";


load_vi_settings($WorkFlow);


/***********************************************************************\
 * Action:
\***********************************************************************/

elab_ping();


// Return code from ROOT script, either task execution or plot options.
//
if( empty($root_rc) ) $root_rc=0;



// Don't come here if previous steps did not complete successfully
//
if( $main_steps[$this_step-1]->status != STEP_DONE ){
    add_message("The analysis step did not complete.  ",  MSG_ERROR);
    $u = $main_steps[$this_step-1]->url;

    //TEST//
    $t = 1 + $debug_level;
    $u = $main_steps[$this_step-2]->url;
    debug_msg(1,"Going back to control panel in $t seconds...");
    header("Refresh: $t ; URL=$u");
    //TEST//
    //    header("Location: " .$u);      // Redirect!
    //exit();
 }

if( empty($Nplot) || !is_numeric($Nplot) || $Nplot < 1 )  $Nplot=1;
if( empty($Ntry)) $Ntry=0;

recall_variable('plot_id');
if (empty($plot_id)) {
	$plot_id = uniq_id($Nplot);
}

debug_msg(2, "Plot id is ".$plot_id);

// deal with 'undo' button
//
$undo = handle_undo();


// see if there are any plot options.  
// If there are it will create a file of ROOT commands 
// to be run as an update
//
if( !$undo ) {  
  handle_plot_options();        
 }
handle_prev_next('main_steps');



// Get workflow settings (like Npens)
//
load_vi_settings($WorkFlow);


// Check number of pens is set
//
if( empty($Npens) ) {
    $Npens = $Ninputs;   // recover, for now
    add_message("Error: Number of pens (Npens) not set. Fixed.", MSG_WARNING);
 }



// Give beginners nicer plot titles
// (this will trigger plot update in plot_graph.php)
//
if( $Nplot==1 &&  $user_level < 3 ) {

    // Overall plot title defaults to channel description
    update_plot_option_item('plot_title', $channel_description[1]);
    set_plot_title_root_cmd();


    // Units [DISABLED - this is now done in ROOT]
    $u = $input_channels[1]->units;
    if( 0 && !empty($u) ){// test that ROOT does it right
        update_plot_option_item('y_axis_title', $u);        
        set_y_axis_title_root_cmd();
    }
    else {
        debug_msg(3,"No units for input channel 1");
    }

    apply_plot_options();      // creates update file
}




/**
 *  Apply an update to the plot?
 */

if( empty($task_id) ){
    $task_id = uniq_id();
 }

$update_file=$task_id."_update.C";
debug_msg(2, " Nplot is  '$Nplot'");
debug_msg(2, " Checking for update file: $update_file");
if( file_exists($update_file) ){
  $Nplot++;
  $plot_id = uniq_id($Nplot);
  debug_msg(2, " Found update file.  Updating to Nplot='$Nplot' ....");
  $root_rc = plot_update($task_id, $Nplot); // removes update file
  if( $root_rc != 0 ) {
    debug_msg(2, "ROOT RC=". $root_rc );
  }
}


/**
 *  Look for output file
 */

if(empty($plot_id)) $plot_id = uniq_id($Nplot);
$imgfile = $plot_id.".png";

if ( !file_exists($imgfile) ) {
    add_message("Image file not found: $imgfile  ", MSG_WARNING);

  /*if( $Ntry < 5 ) {
      add_message("Trying again in a second (try $Ntry)... ", MSG_WARNING);
      header("Refresh: 1; URL=plot_graph.php");
      $Ntry ++;
  }
  else {
      add_message("After $Ntry attempts I give up.", MSG_ERROR);
      $main_steps[$this_step]->status=STEP_FAIL;    
      $Ntry = 0;
  }*/
}
 else {
     $main_steps[$this_step]->status=STEP_DONE;    
 }


/*****************
 *  Save the plot?  User must press "Save Plot As:"
 */

$plot_name="";

// Name to save the plot under...
//
if( isset($_GET['plot_name']) && !empty($_GET['plot_name'])) {
    $plot_name = $_GET['plot_name']; 
}

if( isset($_POST['plot_name']) && !empty($_POST['plot_name'])){
    $plot_name = $_POST['plot_name'];
}

debug_msg(3, "metadata array has size ". sizeof($metadata) );
debug_msg(4, "metadata array: <hr><pre>".print_r($metadata,true)."</pre><hr>");

if( !empty($_POST['save_plot']) || !empty($_GET['save_plot']) ){

    if( empty($plot_name) ) $plot_name = $plot_id.".jpg";
    if( $plot_name == ".jpg" ) $plot_name = "temp.jpg";

    // If we are not yet logged into the e-Lab (JSP site) then we
    // have to do that now (once)
    //
    if( empty($elab_cookies[$elab]) || empty($elab_group) ){
        add_message("You must grant Bluestone access to your LIGO e-Lab group to save a plot",
                    MSG_WARNING,2);
	$next_url = $self."?save_plot=1&plot_name=$plot_name";
	set_destination($next_url);
        $u = "elab_login.php";
        debug_msg(1,"Jumping to $u...");
        header("Location: " .$u);      // Redirect!
        exit(0);
    }

    debug_msg(1,"save_plot: are authenticated to e-lab as group $elab_group.");
    debug_msg(1,"save_plot: Auth cookie: ".$elab_cookies[$elab]['Value']);


    $file_path = "$TLA_TOP_DIR/html/tla/$slot_url$imgfile";

    $link = elab_upload($file_path, $plot_name,
                        '(Saved from Bluestone)', 'image/jpeg');

    if( empty($link) ){
        debug_msg(1,"elab_upload() failed! ");
        add_message("Failed to save image file $plot_name", MSG_ERROR);
    }
    else {
        add_message("Saved plot as file <a target='_blank' href='$link'>".
                    $plot_name."</a> for research group '$elab_group'."
                    , MSG_GOOD);
    }

 }// Save?



/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="Plot Graph";
html_begin($title);
title_bar($title,"Plot # ".$Nplot);

controls_begin();  // includes message area

if (!file_exists($imgfile)) {
	echo "(No image file available.)\n";
}
else {

	echo <<<END
		<table border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td class="control">
   					<div class="textarea">
   						<img src="$slot_url$imgfile" />   
   					</div>
   				</td>
   				<td class="control" valign="top" width="100%">
END;
	plot_title_control();
	if (function_exists("http_get")) {
		hrule(); 
echo <<<END
	<div class="vindent">
    	<b>Plot Filename:</b><br/>
    	<input class="textfield" type="text" name="plot_name" value="$plot_name" size="18"></input>
    </div>
END;
	}
	hrule();
	time_axis_control();
	y_axis_control();
	hrule();
	max_y_control();
	min_y_control();
	hrule();
	pen_color_control();
	hrule();
	echo "<input class=\"button\" type=\"submit\" name=\"apply\" value=\"Update\" />";
	if ($Nplot > 1) {
		echo "<input class=\"button\" type=\"submit\" name=\"undo_plot\" value=\"Undo\" />";
	}
	// View Logs is not shown to Beginners.
	//
	if ($user_level > 1) {
	    echo "
	       <a class='button' href='view_logs.php' target='_view'>
	          <input type='button' class='button' name='view_logs'
	                 value='View Logs'></a>
	              ";
	}
	echo "<br />";
	// Save this plot (to the e-Lab, if we are logged in to it) 
	//

	if (function_exists("http_get")) {
		hrule(); 
echo <<<END
    	<input class="button" type="submit" name='save_plot' value="Save Plot"><br />
END;
	}
	
	//
	// Any other controls would go here
	//
	echo "</td></tr></table>\n";
}

// Bottom controls:
echo "<TABLE class='control' width='100%'>
        <TR><TD ALIGN='left'>
        ";


// Downloadable image and metadata files:
//
echo "<b>Download plot as:</b>&nbsp;&nbsp; ";

function download_image_link($imgfile ,$tag){
    global $slot_url;
    if( !file_exists($imgfile) ) return;
    echo "[<a href='$slot_url$imgfile' target='_image'><span
        title='right click to download image'>$tag</span></a>]&nbsp;\n";
}

$imgfile = $plot_id.".jpg";
download_image_link($imgfile,"JPEG");

$imgfile = $plot_id.".eps";
download_image_link($imgfile,"EPS");

$imgfile = $plot_id.".png";
download_image_link($imgfile,"PNG");

$imgfile = $plot_id.".svg";
download_image_link($imgfile,"SVG");

if( $user_level>2 ){
    $imgfile = $plot_id.".C";
    if( file_exists($imgfile) ) {
        echo "[<a href='$slot_url$imgfile' target='_image'><span
        title='right click to download ROOT code for this plot'>ROOT</span></a>]\n";
    }
 }

// Workflow Parameter file (task metadata):
//
$param_file = $WorkFlow.".dat";
if( file_exists($param_file) ) {
    echo "[<a href='$slot_url$param_file' target='_metadata'><span
        title='Right click to download task parameters used to generate this plot'>Task Params</span></a>]\n";
 }

// R/CSV data file:
//
if( $user_level>2 ){
    $data_file = $plot_id.".R";
    if( file_exists($data_file) ) {
        echo "[<a href='$slot_url$data_file' target='_image'><span
        title='right click to download data file for R or eXcel'>R/CSV</span></a>]\n";
    }
 }






echo "
        </TD></TR></TABLE>\n";



/****************************
 * Log files?  Debug control?
 */
if( !empty($root_rc) || $debug_level > 2 ) {
    show_log_files($Nplot);
 }

controls_end();

echo "<P>\n";


/***********************************************************************\ 
 * DONE:
 */

remember_variable('SESSION'); 
remember_variable('main_steps'); 
remember_variable('this_step'); 

// General:
remember_variable('elab_group');
remember_variable('elab_cookies');

// This page:
remember_variable('Nplot');
remember_variable('root_rc');
remember_variable('task_id');
remember_variable('plot_options');
remember_variable('debug_level');
remember_variable('Ntry');
remember_variable('exec_type');

tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: plot_graph.php,v 1.57 2009/05/26 20:55:38 myers Exp $";
?>
