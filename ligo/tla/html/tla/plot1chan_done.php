<?php
/***********************************************************************\
 * task_show.php - show the results of the execution of a task
 *
 *
 * Eric Myers <myers@spy-hill.net  - 25 October 2007
 * @(#) $Id: plot1chan_done.php,v 1.5 2008/03/27 16:22:25 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities
require_once("root.php");                // also ROOT stuff

require_once("../boinc_html/inc/util.inc");  // for the table stuff 

handle_debug_level();                   // so we can get more verbose
//require_authentication();

recall_variable('task_id');

/***********************************************************************\
 * Action:  look for task files
\***********************************************************************/

// If task_id is in the URL use that
//
if( isset($_GET['task_id']) ){
    $task_id = $_GET['task_id'];
 }

if( isset($_GET['Ntry']) ){
    $Ntry = $_GET['Ntry'];
 }
if( empty($Ntry) ) {
    $Ntry = 0;
 }

if( isset($_GET['slot']) ){
    $slot = $_GET['slot'];
 }
if( empty($slot) ){
    $slot=slot_dir()."/";
 }

add_message("Task ID: $task_id");

// Look for output file
//
$plot_id = $task_id ."_1";
$imgfile = $slot."/".$plot_id.".jpg";

if ( !file_exists($imgfile) ) {
    add_message("Image file not found: $imgfile  ", MSG_WARNING);
}


/***********************************************************************\
 * Display Page:  show the graph
 */

html_begin("Task results: $task_id");


controls_begin();  // includes message area

echo "<TABLE width='100%' bgcolor='white' border=4>
         <TR>\n";

if ( !file_exists($imgfile) ) {
  echo "<blockquote>(No image file available.)</blockquote>\n";
 }
 else {
   echo "<TD valign='TOP'>      <img src='$imgfile' border='1'>   </TD>\n";

   // Controls to the right

   echo "<TD class='control' width='20%' valign='top'>\n";

   time_axis_control();
   hrule();
   max_y_control();
   hrule();
   pen_color_control();
   hrule();
   // any other controls here?
   echo "</TD>\n";
 }

echo "</TR>\n</TABLE>\n";

// Control bar under plot
//
controls_next();

echo "<P align='LEFT'>
          <input type='submit' name='apply' value='Apply'>
          <input type='submit' name='reset_session' value='Reset'>
        ";

if( $Nplot > 1 ) {
  echo "<input type='submit' name='undo_plot' value='Undo'>";
 }

echo "
       <a href='view_logs.php' target='_view'>
          <input type='submit' name='view_logs' value='View Logs'></a>
              ";

  // Downloadable Image files:
  //
  echo "&nbsp;|&nbsp;  Download links: ";

  $imgfile = $slot.$plot_id.".jpg";
  if( file_exists($imgfile) ) {
    echo "[<a href='$imgfile' target='_view'>JPEG</a>]\n";
   }

  $imgfile = $slot.$plot_id.".eps";
  if( file_exists($imgfile) ) {
    echo "[<a href='$imgfile' target='_view'>EPS</a>]\n";
   }

  $imgfile = $slot.$plot_id.".png";
  if( file_exists($imgfile) ) {
    echo "[<a href='$imgfile' target='_view'>PNG</a>]\n";
   }

  $imgfile = $slot.$plot_id.".svg";
  if( file_exists($imgfile) ) {
    echo "[<a href='$imgfile' target='_view'>SVG</a>]\n";
   }

if( $user_level>2 ){
   $imgfile = $slot.$plot_id.".C";
  if( file_exists($imgfile) ) {
    echo "[<a href='$imgfile' target='_view'>ROOT</a>]\n";
   }
 }


// Task id:
//
echo "&nbsp;|&nbsp;  Task ID: $task_id ";


// Bottom controls:

controls_next();

   echo "<TABLE class='control' width='100%'>
        <TR><TD ALIGN='left'>
        ";

   plot_title_control();
   y_axis_control();
   //
   // Any other controls to go here?
   //
   echo "
        </TD></TR></TABLE>\n";




/****************************
 * Log files?  Debug control?
 */

if( !empty($root_rc) || $debug_level > 2 ) {
    controls_next();
    show_log_files($Nplot);
 }

controls_end();

echo "<P>\n";


/*******************************************************8
 * DONE: */

  echo "\n</form>\n";    
  echo "</BODY>\n</HTML>\n";

?>
