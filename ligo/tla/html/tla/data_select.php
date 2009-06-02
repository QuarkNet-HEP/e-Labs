<?php
/***********************************************************************\
 * data_select.php - select input data source and channels
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: data_select.php,v 1.50 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities

check_authentication();
handle_user_level();
handle_auto_update();
handle_reset();

$this_step = update_step('main_steps');
recall_variable('msgs_list');

// General:
recall_variable('elab_group');
recall_variable('elab_cookies');


// Previous page:
recall_variable('WorkFlow');

// This page:
recall_variable('GPS_start_time');
recall_variable('GPS_end_time');
recall_variable('time_input_pref');
recall_variable('Ninputs');
recall_variable('channel_info');
recall_variable('channel_info_level');
recall_variable('input_channels');


/***********************************************************************\
 * Action:
\***********************************************************************/

elab_ping();

clear_log_files();

if($user_level==1){
  add_message(" Use the controls below to select the data you wish
          to include in your analysis. 
          <br>
          You must select both a <i>".glink('time interval')."</i>  to view
          and a <i>".glink('data channel')."</i> to plot. 
          <P>
          Press \"Apply\" to make your selections take effect.<br>
          Then press the \"Next Step\" button at the bottom of the page.
          ");
 }


/**
 * Get workflow details (way too much checking, but for starters...)
 */

debug_msg(1, "WorkFlow: $WorkFlow");

$u='';

// Make sure we have a valid VI selected
//
if( empty($WorkFlow) ) {
    add_message("You need to select a data transformation (workflow).",
                MSG_ERROR, 2);
    $main_steps[$this_step]->status=STEP_FAIL;    
    $u = $main_steps[$this_step-1]->url;
 }

// Load VI settings
//
if( !load_vi_settings($WorkFlow) ){
    add_message("Error: Could not load settings for workflow $WorkFlow.",
                MSG_ERROR, 2);
    $main_steps[$this_step]->status=STEP_FAIL;    
    $u = $main_steps[$this_step-1]->url;

 }

if( empty($WorkFlow_list) || !array_key_exists($WorkFlow, $WorkFlow_list) ){
    add_message("Error: did not get workflow settings for $WorkFlow.",
                MSG_ERROR, 2);
    $main_steps[$this_step]->status=STEP_FAIL;    
    $u = $main_steps[$this_step-1]->url;
 }   

if(!empty($u) ){
    header("Refresh: ".(7+$debug_level)." ; $u");
 }

$wf = $WorkFlow_list[$WorkFlow];

if( empty($wf) ) {
    add_message("Error: could not find workflow settings for $WorkFlow.",
                MSG_ERROR, 2);
    $main_steps[$this_step]->status=STEP_FAIL;    
    $u = $main_steps[$this_step-1]->url;
 }   



/**
 * Process time interval 
 */

handle_time_input();
$dt = $GPS_end_time - $GPS_start_time;


$start_time = GPS_to_User($GPS_start_time); 
$end_time   = GPS_to_User($GPS_end_time);       

debug_msg(5, "Time input pref is: '".$time_input_pref."'");


/**
 * Process channel selection
 */

handle_Ninputs($wf);
debug_msg(3,"Ninputs is $Ninputs.  Channel list has ".
          count($input_channels)." elements. ");
if( $Ninputs < count($input_channels) ){// Need to slice the list?
    $x = array_slice($input_channels,0,$Ninputs,true);
    $input_channels = $x;
    debug_msg(3,"Sliced the channel list to ".
          count($input_channels)." element(s). ");
 }
$n =  build_channel_info();
debug_msg(4,"Channel selector has $n items. ");
if( !empty($wf) )  handle_channel_input($wf);  


/**
 * Process previous/next buttons
 */

handle_prev_next('main_steps');  // do this *after* user input is processed

// Step status:
//
if( all_channels_valid($input_channels) ){
   set_step_status('main_steps', STEP_DONE ) ;
}
 else {
     debug_msg(1, "Invalid input channel(s).");
     $main_steps[$this_step]->status=STEP_FAIL;    
 }


/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="Data Selection";
html_begin($title);
title_bar($title);
controls_begin();


/**
 * Time Interval selection:
 */

/**********
echo "  <!-- cute, but may not work over a long time?
        <img src='http://tycho.usno.navy.mil/cgi-bin/nph-usnoclock.gif?zone=UTC;ticks=600'
             align='right'     title='USNO UTC clock' alt='USNO UTC clock'> <! -- -->
        \n";
*******/


echo "<TABLE width='100%' border=1><TR><TD>\n";
echo "<TABLE width='100%' border=0><TR>\n";

echo "<TD valign='top'> <b>Time Interval:</b> ";
echo printable_dt($dt);

echo "</td><td align='right' valign='top'>\n";
if( $user_level > 2) echo GPS_clock_box();
echo GMT_clock_box();

echo "</td></tr>\n";
 
if($user_level<3) {
  echo "<tr><td colspan='2'> Select start and stop times for your analysis:
        </td></tr>";
 }


echo " <TR><TD> Starting Date/Time:
                <input type='text' name='start_time'
                       size=25 value='$start_time'>
                ";

if($user_level >=3) {
  echo " <br><center><font size=-1>
                 (" .GPS_to_Other($GPS_start_time). ")
                </font>
        ";
 }
echo "  </TD>\n ";

echo "<TD> Ending Date/Time:
                <input type='text' name='end_time'
                       size=25 value='$end_time'>
                ";
if($user_level >=3) {
  echo " <br><center><font size=-1>
                 (" .GPS_to_Other($GPS_end_time). ")
                </font>
        ";
 }

echo "  </TD>\n ";

echo " </TR>\n</TABLE>\n ";
echo " </TD></TR></TABLE>\n ";

controls_next();



/**
 * Display the Workflow and get number of inputs
 */

echo "<TABLE width='100%' border=1><TR>\n";
echo "<TD><b>Work Flow:</b> $wf->name ";
if( $user_level == 1 ) echo "- $wf->desc "; 
if( $user_level == 2 ) echo "- $wf->info "; 


$NinMax = $wf->max_channels();
if( $NinMax > 1 ){
    echo "<br>";
    echo "&nbsp;&nbsp; Number of input channels: \n";

    $x = array();
    for($i=2;$i<=$NinMax;$i++) $x[$i]=$i;

    echo  auto_select_from_array('Ninputs', $x, $selection=$Ninputs);
    //echo "<input type='text' size='2' name='Ninputs' value='$Ninputs'> \n";
    //if( $user_level < 4 )  echo " (maximum $ninmax)";
 }
echo "</td>\n";
echo " </tr>\n</table>\n ";

controls_next();
 

/**
 * Now an input  Selector for each channel
 */
for($i=1; $i<=$Ninputs;$i++){

  echo "<TABLE width='100%' border='1'><TR><TD>\n";
   
  $icon='signal_white.gif';
  $status='';

  if( !isset($input_channels[$i]) ){
      $icon='signal_blue.gif';
  }
  else{
      $Inxx = $input_channels[$i];
      if( !$Inxx->is_valid() ){
          $icon='signal_yellow.gif';
      }
      else {
          $icon='signal_green.gif';
          if( $user_level == 1 ){
              $status='OK';
              //echo "<font size='-1'>OK</font>\n";
          }
          else {
              $name = $Inxx->name;
              if( $name ){
                  $name .= " [" .$Inxx->ttype. "] ";
                  $status=$name;
                  //echo "<font size='-1'>$name</font>\n";
              }
          }
      }
  }

  //  echo "[$icon]&nbsp;";
  echo "<img src='img/$icon'>&nbsp;";
  echo "<b>Input ";
  printf("In%02d", $i);
  echo ": </b> ";
  echo "<font size='-1'>$status</font>\n";

  echo " <br> ";
  input_channel_control($i);
  echo "</TD></TR></TABLE>\n";
 }
/*******/

controls_end();


/*******************************************************8
 * DONE:
 */

// General:
remember_variable('main_steps'); 
remember_variable('this_step'); 
remember_variable('msg_list'); 

// This page:
remember_variable('channel_info');
remember_variable('channel_info_level');

// Following pages:
remember_variable('WorkFlow');
remember_variable('Ninputs');
remember_variable('GPS_start_time');
remember_variable('GPS_end_time');
remember_variable('input_channels');
remember_variable('time_input_pref');

tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: data_select.php,v 1.50 2009/04/29 20:43:24 myers Exp $";
?>
