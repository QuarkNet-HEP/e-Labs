<?php 
/***********************************************************************\
 * time.php - time convertions and display
 *
 * There are necessarily several different time scales that we must use,
 * so we have to be able to convert between them while always making it
 * easy for the user to do things using the time scale(s) *they* want to use.
 *
 * LIGO data are collected using GPS times, which are seconds past the
 * GPS epoch, 6 January 1980 at 00:00:00 UTC, with no leap seconds.   
 *
 * The server and processing machines which run on Unix use timestamps which
 * are (roughly), seconds past the Unix epoch, which is 1 January 1970 at
 * 00:00:00 UTC.  However, Unix times are affected (altered) by leap seconds.
 * 
 * ROOT plots which have a time axis need a reference time (which is assigned 
 * to x=0).  This is set with SetTimeOffset(t, "gmt")  where t is a Unix time.
 * (Do not forget the "gmt" or the conversion is to "local" time.)
 * We want to avoid large values for this, because they are saved with low
 * precision when a plot is saved as the root macros that produce it, so we 
 * almost always want the reference time in a plot to be the earliert time 
 * value.  ROOT saves this as a character string in SetTimeFormat().
 *
 * ROOT TDatime objects store dates internally as seconds past the ROOT epoch, 
 * which is 1 January 1995.   It is not possible to store dates earlier than 
 * this in this structure.   I think we need to avoid this when possible.
 * Coincidentally, there are no LIGO data before 1995, the year construction 
 * began, but this is only important to note that the 1995 reference point
 * comes from ROOT not LIGO.   I do not yet know if this limitation means we 
 * will have difficulty plotting data before 1995 (eg. for NOAA buoys).
 *
 * Right now the earliest PEM data available to us is GPS 749494800 which
 * is ~about~ 6 Oct 2003 17:00 GMT.
 * 
 * UTC (formerly GMT) includes occasional leap seconds, so when converting
 * between Unix or GPS times these need to be accounted for.  The Unix 
 * utilities should take care of this.  Until I have leap seconds properly 
 * accounted for in the conversion I will refer to times as GMT not UTC
 * (this usage is non-standard, and will be moot when everything is working
 * properly). 
 *
 * If we convert GPS times to Unix times using the known constant offset,
 * then we can use the Unix routines to convert to UTC or local time and 
 * Unix will properly take care of leap seconds. 
 * 
 * Users may wish to enter or display times in their own timezone. 
 * 
 * We distinguish between user preferences for time input (which we should 
 * be able to detect from the style of the input) and preferences for output
 * (which can be set explicitly or default to whatever was used for input).
 * The point is, there are two different choices to make, not one.
 * 
 * PHP has some very robust time conversion routines which we should make use 
 * of as much as possible to make time input and output easy for the user.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 5 May 2006
 * @(#) $Id: time.php,v 1.23 2009/01/27 18:58:08 myers Exp $
\***********************************************************************/

require_once("messages.php");

// Useful constant times, in Unix time.

$GPS_epoch=date("U",strtotime("6 Jan 1980 00:00:00 GMT"));  
$ROOT_epoch=date("U",strtotime("1 Jan 1995 00:00:00 GMT"));  
$LIGO_epoch=date("U",strtotime("6 Oct 2003 16:59:47 GMT"));

// make sure server times are GMT

putenv('TZ=GMT'); 

function Unix_to_GPS($time_t) { 
  global $GPS_epoch;
  return $time_t - $GPS_epoch;
}

function GPS_to_Unix($gps_t) {
  global $GPS_epoch;
  return $gps_t + $GPS_epoch;
}


/**
 * GPS_to_User($gps_t) converts the GPS time argument into a time displayed
 * as the user wants it displayed, either Local, GMT, or GPS.  
 * (For now just GMT or GPS)
 */

function GPS_to_User($gps_t){
  global $time_input_pref;
 
  $ut = GPS_to_Unix($gps_t);   // unix timestamp

  if( empty($time_input_pref) || $time_input_pref=='GMT'){
    return gmdate("j M Y H:i:s ", $ut) . "GMT";
  }

  if( $time_input_pref=='GPS' ){
    return "$gps_t";
  }

  return "unknown time pref";
}


/**
 * GPS_to_Other($gps_t) converts the GPS time argument into a time displayed
 * as the *opposite* of what the user wants by default (for help).
 */

function GPS_to_Other($gps_t){
  global $time_input_pref;
 
  $ut = GPS_to_Unix($gps_t);   // unix timestamp

  if( empty($time_input_pref) || $time_input_pref=='GMT'){
    return "GPS $gps_t";
  }

  if( $time_input_pref=='GPS' ){
    return gmdate("j M Y H:i:s ", $ut) . "GMT";

  }
  return "unknown time pref";

}


/**
 * Given a raw time interval $dt, in seconds, return a printable
 * version with appropriate units and reasonable places past decimal.
 */

function printable_dt($dt, $Ndecimals=2){
  $p10 = pow(10,$Ndecimals);

   $dt_units = "seconds";
   if($dt > 5*60) {
     $dt = $dt / 60;
     $dt_units = "minutes";

     if($dt > 2*60) {
       $dt = $dt / 60;
       $dt_units = "hours";

       if($dt > 30) {
         $dt = $dt / 24;
         $dt_units = "days";
        }
     }
    }
   $dt =  intval($dt*$p10+0.5)/$p10;   // truncate
   return " $dt $dt_units \n";
 }


/**
 * Update start or end time based on user input
 * TODO: needs work - should be able to check conditions for both 
 */

function process_time_input($global_var, $posted_var, $name){
  global $$global_var;          // the variable we are modifying
  global $GPS_epoch, $LIGO_epoch;
  global $time_input_pref;

  $x = trim(get_posted($posted_var));
  if( empty($x) ) return;

  recall_variable($global_var);

  $y = GPS_to_User($$global_var);
  $z = GPS_to_Other($$global_var);
  debug_msg(5,"$name - Compare input $x with current value $y.");

  if( $x == $y || $x == $z ) {
    debug_msg(5,"$name - no change, so don't make a change.");
    return;   // no change?
  }
  if( is_numeric($x) ) { // GPS time is pure number?
    debug_msg(5, "$name - Numeric time $x assumed to be GPS time.");
    $time_input_pref='GPS';             

    if( $x < Unix_to_GPS($LIGO_epoch) ) { // before there is any data?
      add_message("LIGO GPS times must be after "
                  .GPS_to_User(Unix_to_GPS($LIGO_epoch)), MSG_ERROR);      
    }
    elseif( $x > Unix_to_GPS(time()) ){
      //TODO: could it be a Unix timestamp rather than GPS?  Test here.
      add_message($name." time cannot be in the future.", MSG_ERROR);      
    }
    else {
      if( $$global_var != $x ) {
        $$global_var = $x;
        clear_steps_after(); // any change clears future steps
      }
    }
  }

  else { // not a pure number?  then try to parse it as a date.
    debug_msg(5, "$name - Non-numeric time $x assumed to be GMT time.");
    $time_input_pref='GMT';             

    $u = strtotime($x);
    if($u === FALSE || $u == -1) {
      add_message("I cannot understand the time/date '$x' as a $name time.");
    }
    elseif( $u < $GPS_epoch ){
      add_message("The date '$x' is too far back.", MSG_WARNING);
    }
    elseif( $u > time() ){
      add_message($name." time cannot be in the future.", MSG_ERROR);      
    }
    elseif( $u < $LIGO_epoch ) { // before there is any data?
      add_message("LIGO data are only available after "
                  .GPS_to_User(Unix_to_GPS($LIGO_epoch)), MSG_ERROR);      
    }
    else {
        $x = Unix_to_GPS($u);
        if( $$global_var != $x) {
          $$global_var = $x;
          clear_steps_after(); // any change clears future steps
          debug_msg(6,"$name time: Unix=$u");
        }
    }
  }
}


/****************************************\
 *  update_time_info() takes user's input for start/stop time and applies
 *  it, assuming that the input was good.  It also infers the user's input
 *  preference based on how they input the time
\*/


function update_time_info(){
    debug_msg(1,"Please use handle_time_input() instead!");
    handle_time_input();
}

function handle_time_input(){
  global $GPS_epoch, $LIGO_epoch, $GPS_start_time, $GPS_end_time; 
  global $time_input_pref;

  $GPS_now = Unix_to_GPS(time());  
  //FIXME: remove the next line when new data are available from Caltech
  $GPS_now = 915109200;

  if( empty($GPS_start_time) )  $GPS_start_time=$GPS_now-12*3600;
  if( empty($GPS_end_time) || $GPS_end_time <= $GPS_start_time ) {
    $GPS_end_time=$GPS_now;
  }

  $old_start = $GPS_start_time;
  $old_end = $GPS_end_time;

  process_time_input('GPS_start_time', 'start_time', 'Start');
  process_time_input('GPS_end_time', 'end_time', 'End');



  if($GPS_end_time <= $GPS_start_time) {
    add_message("Starting time must be before ending time.", MSG_ERROR);
    $GPS_start_time = $old_start;
    $GPS_end_time = $old_end; 
  }

  if( empty($time_input_pref)) $time_input_pref='GMT';
 
  remember_variable('GPS_start_time');
  remember_variable('GPS_end_time');
  remember_variable('time_input_pref');
}


/**
 * Real-time GPS clock implemented with JavaScript
 * (if scripting is turned off it just shows the time the page was loaded, for context)
 */

function GPS_clock_box(){
    $gps_now =  Unix_to_GPS(time());
    $x = "
     <div class='clock_box'><b>GPS Time:  </b><span id='gps_clock_field' > $gps_now </span></div> \n";
    $x .= "
     <script language='JavaScript'>
     function updateGPStime(){
        var gps_time;
        d = new Date;
        unix_time = d.getTime()/1000;
        gps_epoch = Date.parse('6 Jan 1980 00:00:00 GMT')/1000;
        leap_seconds = 14; 
        gps_time = (unix_time + leap_seconds - gps_epoch);
        gps_time = Math.floor(gps_time);
        clock_div = document.getElementById('gps_clock_field');
        clock_div.firstChild.nodeValue = gps_time;
        setTimeout('updateGPStime()', 250);
     }
     updateGPStime();  
     </script>\n\n";
    return $x;
}

/**
 * Real-time GPS clock implemented with JavaScript
 * (if scripting is turned off it just shows the time the page was loaded, for context)
 */

function GMT_clock_box(){
    $gmt_now = gmdate("j M Y H:i:s ",time())." GMT";
    $x = "
     <div class=\"clock_box\"><b>Time:  </b><span id='gmt_clock_field' > $gmt_now </span></div>\n";
    $x .= "
     <script language='JavaScript'>
     function updateGMTtime(){
        var gmt_time;

        d = new Date();
        gmt_time = d.toUTCString();
        clock_div = document.getElementById('gmt_clock_field');
        clock_div.firstChild.nodeValue = gmt_time;
        setTimeout('updateGMTtime()', 250);
     }
     updateGMTtime();  
     </script>\n\n";
    return $x;
}

// Printable hr:min:sec timestamp
//
function dateHms($t=NULL){
    if(!$t) $t=time();
    $x = "<font color='BLUE'>".date("H:i:s ",$t)."GMT </font>\n";
    return $x;
}

?>
