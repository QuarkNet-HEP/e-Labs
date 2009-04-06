<?php
/***********************************************************************\
 * channels.php - Functions for Input data channels
 *
 *  Input Channel selection information is maintained in an array
 *  called $input_channels containing objects of class InChannel. 
 *  The class and methods are defined below, along with a selector
 *  and function to process _POST changes.
 * 
 *  A list of *all* possible input channels is maintained in the array
 *  $channel_info.  This is built once by build_channel_info() based on
 *  a list of channels read from a file  (and rebuilt if the user level
 *  changes).  In future this information will  go into a database.
 *
 *
 * Eric Myers <myers@spy-hill.net  - 12 April 2006
 * @(#) $Id: channels.php,v 1.41 2009/02/11 20:04:05 myers Exp $
\***********************************************************************/

require_once("util.php");
require_once("debug.php");


// This might be useful later for building the channel hierarchy...
//
$channel_parts = array('source', 'subsys', 'station', 'sensor', 'ttype');


/***********************************************************************
 *  InChannel object class describes input data channels  */

class InChannel{
    var $name;      // full name of channel 
    var $site;      // Site = Hanford or Livingston, GEO, (or NOAA) etc..
    var $source;    // measurement source (H0, L0, NOAA, ... H2?) or source
    var $subsys;    // Subsystem (eg. DMT, GDS, PEM, ...)
    var $station;   // Sensor station/location at site (eg. LVEA, EX, EY...)
    var $sensor;    // Sensor name (eg, SEISZ, MAGX, RAIN...)
    var $rate;      // sampling rate, or trending rate, as appropriate
    var $ttype;     // trend type (T=second, M=Minute, R=Raw, etc...)
    var $tcomp;     // trend component (mean,min,max,rms,N)
    //var $file;      // file location of the data source
    //var $format;    // data file format: Frames, LIGO_LW, ASCII BUOY file?
    //var $domain;    // 't' for time, 'f' for frequency
    //var $bw_low;    // band-pass low freq
    //var $bw_high;   // band-pass high freq
    var $units;        // units of measurement 
    var $calib_slope;  // calibration slope (linear scale factor)
    var $calib_bias;   // calibration bias (DC offset = value when ADC=0) 

    // Display properties
    //var $axis_label; // y-axis label for plots  
    var $info;       // short description
    var $desc;       // long description
    var $user_level; // minimum user level for use

    /* TODO: when this becomes a database table, be sure to create 
     * separate tables for $site, $subsys, $station, $sensor 
     * so we can manage those properties separately */



    // Constructor: 
    function InChannel($name='', $subsys='DMT', $station='LVEA', $sensor=''){
        $this->name=$name;
        $this->site='Hanford';
        $this->source='H0';           // default, for now
        $this->subsys=$subsys;
        $this->station=$station;
        $this->sensor=$sensor;
        $this->ttype="M";
        $this->tcomp=  ($subsys=="PEM") ? "rms" : "mean" ;             
        $this->units="";
        $this->calib_slope=1.0;
        $this->calib_bias=0.0;
        return $this;
    }

    /*********************
     * Check validity of a channel:
     * Build list of valid channels if there isn't one.
     * Return true if channel exists and passes some tests.
     * Leaves the most valid part it could find in $last_valid_channel_part
     *  even if the whole channel specification is invalid. */

    function is_valid(){
        global $channel_info; 
        global $last_valid_channel_part;
        global $user_level, $channel_info_level;

        if( empty($channel_info) || ($channel_info_level != $user_level) ) {
            debug_msg(8,"is_valid: need to call build_channel_info() first... ");
            build_channel_info();
        }

        debug_msg(4,"is_valid: testing channel: ".
                      "[$this->source][$this->subsys][$this->station]".
                      "[$this->sensor][$this->ttype]");

        $last_valid_channel_part = new InChannel();

        //TODO: this could be done iteratively via an array of names 
        //      of object properties.  Someday...

        // Source:

        if( !$this->source ) return false;
        if( !isset($channel_info[$this->source]) ){
            debug_msg(2,"no such source: ".$this->source);
            return false;
        }
        $last_valid_channel_part->source = $this->source;

        // Subsystem:

        if( !$this->subsys ) return false;
        if( !isset($channel_info[$this->source][$this->subsys]) ){
            debug_msg(2,"no such subsystem: ".$this->subsys);
            return false;
        }
        $last_valid_channel_part->subsys = $this->subsys;


        // Station:

        if( !$this->station ) return false;
        if( !isset($channel_info[$this->source][$this->subsys][$this->station]) ){
            debug_msg(2,"no such station: ".$this->station);
            debug_msg(3,"Valid stations are: "
              .implode(" ", array_keys($channel_info[$this->source][$this->subsys])));


            return false;
        }
        $last_valid_channel_part->station = $this->station;

        // Sensor:

        if( !$this->sensor ) return false;
        if( !isset($channel_info[$this->source][$this->subsys][$this->station][$this->sensor]) ){
            debug_msg(2,"no such sensor: ".$this->sensor);
            debug_msg(3,"Valid sensors are: "
                      .implode(" ", array_keys($channel_info[$this->source][$this->subsys][$this->station])));
            return false;
        }
        $last_valid_channel_part->sensor = $this->sensor;


        // Trending type:

        if( !$this->ttype )  return false;
        if( !isset($channel_info[$this->source][$this->subsys]
                   [$this->station][$this->sensor][$this->ttype]) ){
            debug_msg(2,"no such trend type: ".$this->ttype);
            return false;
        }
        $last_valid_channel_part->ttype = $this->ttype;


        // Trending component: (raw channels have no trend component)

        if( !$this->ttype ) return false;
        if( $this->ttype == "R") {
            if( !isset($channel_info[$this->source][$this->subsys]
                       [$this->station][$this->sensor][$this->ttype]) ){
                debug_msg(3,"is_valid: Raw channel does not exist: channel_info".
                          "[$this->source][$this->subsys][$this->station]".
                          "[$this->sensor][$this->ttype]");
                return false;
            }
            return true;
        }

        // Trend channels have an extra component specification

        if( !$this->tcomp ) return false;

        if( !isset($channel_info[$this->source][$this->subsys][$this->station]
                   [$this->sensor][$this->ttype][$this->tcomp]) ){
            debug_msg(3,"is_valid: Trend channel does not exist: channel_info".
                      "[$this->source][$this->subsys][$this->station]".
                      "[$this->sensor][$this->ttype][$this->tcomp]");
            return false;
        }
        debug_msg(7,"is_valid: valid!");
        return true;
    }


    /*********************
     * Set the Units (and calibration factors) for a channel.
     * Note: calibration is now done in ROOT scripts, so we may want to 
     * take calibration out here to avoid confusion?
     */

    function set_units(){
        global $channel_info; 

        if( !$this->is_valid() ) return FALSE;

        $name = $this->name;
        $this->calib_slope=1.0;
        $this->calib_bias=0.0;

        // DMT SEISMIC
        if( strpos($name, "DMT-BRMS") !== FALSE ) {
            $this->units="(microns/s)^2";
            return $this;
        }

        // GDS Earthquake
        if( strpos($name, "GDS-EARTHQUAKE") !== FALSE ) {
            $this->units="1/0";
            return $this;
        }

        if( strpos($name, "PEM-") === FALSE ) {
            debug_msg(2, "InChannel: unknown  channel  $name");
            return FALSE;
        }

        // PEM SEISMIC (non DMT)
        if( strpos($name, "_SEIS") !== FALSE ) {
            $this->units = "microns/s";
            $this->calib_slope=-0.0076;
            return $this;
        }

        // PEM MAGNETIC
        if( strpos($name, "_MAG") !== FALSE ) {
            $this->units = "pT";
            $this->calib_slope=6.10;
            return $this;
        }

        // PEM TILT meters
        if( strpos($name, "_TILT") !== FALSE ) {
            $this->units = "microRadians";
            $this->calib_slope=0.0061;
            return $this;
        }

        // PEM RAIN
        if( strpos($name, "_RAIN") !== FALSE ) {
            $this->units = "mm";
        }

        // PEM WIND 
        if( strpos($name, "_WIND") !== FALSE ) {
            $this->units = "m/s";
        }

        // PEM WIND in MPH (check for this second!)
        if( strpos($name, "_WINDMPH") !== FALSE ) {
            $this->units = "mph";
        }

        return $this;
    }

}// end InChannel class




/****
 * Verify all channels have valid values
 * (for now, just that the names are filled in.  lots more to do here) */

function all_channels_valid($list){
    $n = count($list);
    if( $n < 1) return FALSE;

    debug_msg(4,"all_channels_valid: checking $n channels...");

    for($i=1;$i<=$n;$i++){
        $x = $list[$i];
        if( !($x instanceof InChannel) ) return FALSE;
        debug_msg(4,"Checking validity of channel: ". $x->name );

        if( !($x->is_valid()) ) return FALSE;
    }
    return TRUE;
}

/****
 * Maximum number of allowed channels is based on user level
 */

function get_max_channels(){
    global $WorkFlow, $user_level;
    $N=1;

    if( empty($wf) ) return $N;
    if( array_key_exists($user_level, $wf->maxInputs) ){
        $N = $wf->maxInputs[$user_level];
    }
    return $N;
}
//

/***********************************************************************\
 * Channel Selector Input
\***********************************************************************/


/* Update a single item (station, sensor, etc) for a given input 
 * channel $i in the temporary InChannel object $Inxx.  
 * Returns true if a change was made, otherwise false
 */

function update_channel_item($i, $item, &$Inxx){
    $x = get_posted($item.'_'.$i);
    if( empty($x) ) return false;
    if( $Inxx->$item != $x ) {// changed?
        $Inxx->$item = $x;
        debug_msg(3,"Item ".$item."_$i changed to $x");
        return true;
    }
    return false;
}


/**
 * Handle all channel selector inputs
 */

function handle_channel_input($wf){
    global $user_level;
    global $Ninputs, $input_channels, $channel_info;
    global $last_valid_channel_part;

    /* Number of input channels */

    if( empty($Ninputs) || $Ninputs < 1) {
        debug_msg(1, "Ninputs isn't valid.  $Ninputs");
        return;
    }

    /* Adjust in case of change of user level */

    $Nmax = $wf->max_channels();
    debug_msg(4,"Maximum inputs is $Nmax  while Ninputs is $Ninputs");
    if( $Ninputs > $Nmax ) {// this shouldn't happen
        debug_msg(1,"Forced Ninputs from $Ninputs to Nmax=$Nmax");
        $Ninputs=$Nmax;
    }

    for($i=1;$i<=$Ninputs;$i++){
        if( !isset($input_channels[$i]) )  {
            $input_channels[$i] = new InChannel();
        }

        $Inxx = $input_channels[$i];   // temporary working copy

        $dv_changed = update_channel_item($i,'source', $Inxx); 
        $dv=$Inxx->source;
        $su_changed = update_channel_item($i,'subsys', $Inxx);
        $su=$Inxx->subsys;
        $st_changed = update_channel_item($i,'station',$Inxx);
        $st=$Inxx->station;
        $se_changed = update_channel_item($i,'sensor', $Inxx); 
        $se=$Inxx->sensor;
        $tt_changed = update_channel_item($i,'ttype',  $Inxx); 
        $tt=$Inxx->ttype;
        $cp_changed = update_channel_item($i,'tcomp', $Inxx); 
        $cp=$Inxx->tcomp;

        if( $dv_changed || $su_changed || $st_changed || $se_changed
            || $tt_changed || $cp_changed ) {

            debug_msg(4,"New input channel is <pre>".print_r($Inxx,true)
                      ."</pre>");

            clear_steps_after(); // any change clears future steps

            if( !$Inxx->is_valid() ) {
                debug_msg(2,"Invalid input channel: [$dv][$su][$st][$se][$tt][$cp]");
                // do the best we can
                if( !empty($last_valid_channel_part) ){
                    $input_channels[$i] =  $last_valid_channel_part;
                    debug_msg(2,"The best we can do is:<pre>".
                              print_r($last_valid_channel_part,true)."</pre>");
                }
            }
            else{
                if($tt=='R') {
                    debug_msg(3,"Raw channel_info[$dv][$su][$st][$se][$tt]");
                    $input_channels[$i] =
                        $channel_info[$dv][$su][$st][$se][$tt];
                }
                else {
                    $cp=$Inxx->tcomp; 
                    debug_msg(3,"channel_info[$dv][$su][$st][$se][$tt][$cp]");
                    $input_channels[$i] =
                        $channel_info[$dv][$su][$st][$se][$tt][$cp];
                }
                debug_msg(4,"Input channel(s):<pre>".
                          print_r($input_channels,true)
                          ."</pre>");
            }// valid?
        }// something changed?
        unset($Inxx); // done with it
    }
    remember_variable('input_channels');
}


/* helpers...  */

function replace_if_set(&$list, $item, $text){
    if( !array_key_exists($item, $list) ) return;
    debug_msg(5,"replace '$item' with $text"); 
    $list[$item] = $text;
    return;
}
//


/************************************************
 * Show a single Input Channel Selector (control item).  
 * The channel specification is in the global $input_channels[$i] 
 * (which may be empty or incomplete or invalid).
 */

function input_channel_control($i){
    global $input_channels;
    global $user_level, $channel_info, $channel_info_level;
    global $station_desc;

    debug_msg(4,"input_channel_control() called");

    if( empty($channel_info) || ($channel_info_level != $user_level) ){
        build_channel_info();
    }

    /* In general we prepare lists first, then assemble the selectors */

    $Inxx = $input_channels[$i];   // temporary object, as much as we've got


    /* Source (H0, L0, NOAA, etc...) */

    $source_list = array_of_keys($channel_info);
    $source = 'H0';  // default value, then check what's already set
    $x = $Inxx->source;
    if( isset($x) && in_array($x, $source_list) ){
        $source=$x;
    }


    /* Subsystem: (DMT, GDS, PEM, etc... )  */
 
    $subsys_list = array_of_keys($channel_info[$source]);
    $subsys='DMT'; // default
    $x = $Inxx->subsys;
    if( isset($x) && in_array($x, $subsys_list) ){
        $subsys=$x;
    }


    /* Station (location, position of sensor)  */

    $station_list = array_of_keys($channel_info[$source][$subsys]);
    debug_msg(4, "Station list: ". print_r($station_list,true));

    $station=current($station_list);
    $x = $Inxx->station;
    if( isset($x) && in_array($x, $station_list) ){
        $station=$x;
    }


    /* Sensor list */

    $sensor_list = array_of_keys($channel_info[$source][$subsys][$station]);
    $x = $Inxx->sensor;
    if( isset($x) && array_key_exists($x, $sensor_list) ) {
        $sensor = $x;
    }
    else { // if a value is not already set then set defaults in a cycle
        debug_msg(2, "no previous sensor chosen.  Cycle through defaults");
        $keys = array_keys($sensor_list);
        $j = ($i-1) % sizeof($sensor_list);
        $sensor = $keys[$j];
    }


    /* Sampling: type (M,T,R) and component (mean, min, max...) lists     */

    $trend_list =
        array_of_keys($channel_info[$source][$subsys][$station][$sensor]);
    debug_msg(3, "Trend list: ". print_r($trend_list,true));

    $ttype='M';         // Default if unset
    $x = $Inxx->ttype;
    if( isset($x) && in_array($x, $trend_list) ){
        $ttype=$x;
    }

    $tcomp_list =
      array_of_keys($channel_info[$source][$subsys][$station][$sensor][$ttype]);
    debug_msg(3, "Trend component list: ". print_r($tcomp_list,true));

    $tcomp =  ($subsys=="PEM") ? "rms" : "mean" ; // default

    if( count($tcomp_list)==1) { // is there only one choice? 
        $x = array_values($tcomp_list);
        $tcomp = $x[0];
        debug_msg(3,"Forced tcomp to $tcomp");
    }

    $x = $Inxx->tcomp;          // previously selected value (may be invalid)
    if( isset($x) && in_array($x, $tcomp_list) ){ // if allowed, use it
        $tcomp=$x;
    }


    /* Now modify the item lists to be more helpful to newer users  */

    if($user_level==1) {
        replace_if_set($source_list, 'H0',   "Hanford");
        replace_if_set($source_list, 'L0',   "Livingston");
        replace_if_set($source_list, 'NOAA', "National Oceanic and Atmospheric Admin.");
    }
    if($user_level==2) {
        replace_if_set($source_list, 'H0', "Hanford (LHO)");
        replace_if_set($source_list, 'L0', "Livingston (LLO)");
        replace_if_set($source_list, 'NOAA', "Nat'l Oceanic and Atmospheric Admin. (NOAA)");
    }

    // Subsystems:

    if( $user_level<=2 ){
        replace_if_set($subsys_list, 'DMT', "Data Monitoring Tool");
        replace_if_set($subsys_list, 'GDS', "Global Diagnostic System");
        replace_if_set($subsys_list, 'PEM', "Physics Environment Monitoring");
        replace_if_set($subsys_list, 'NDBC', "National Data Buoy Center");
        replace_if_set($subsys_list, 'METAR', "Meteorlogical Airport Report");
        replace_if_set($subsys_list, 'LSC',  "Length Sensing and Control");
    }
    if($user_level==2){
        foreach($subsys_list as $key=>$text){
            $subsys_list[$key]= "$text ($key)";
        }
    }

    // Stations:

    if( $user_level <=2 ){
        replace_if_set($station_list, 'LVEA', 'Corner Station');
        replace_if_set($station_list, 'EX', 'End Station, X-arm');
        replace_if_set($station_list, 'EY', 'End Station, Y-arm');
        replace_if_set($station_list, 'MX', 'Middle Station, X-arm');
        replace_if_set($station_list, 'MY', 'Middle Station, Y-arm');
        replace_if_set($station_list, 'VAULT', 'Seismometer Vault');
        replace_if_set($station_list, 'MONITOR', 'Control Room');
    }
    if( $user_level==2 ){
        foreach($station_list as $key=>$text){
            $station_list[$key]= "$text ($key)";
        }
    }

    // Sensor description from ->desc or ->info

    foreach( $sensor_list as $s=>$text ){
        $text = $s;
        if( $ttype=='R'){
            $Inxx = $channel_info[$source][$subsys][$station][$s][$ttype];
        }
        else {
            $Inxx = $channel_info[$source][$subsys][$station][$s][$ttype][$tcomp];
        }
        if( $user_level == 1)   $text=$Inxx->desc;  // verbose description
        if( $user_level == 2)   $text=$Inxx->info;  // terse description
        if( empty($text) ) $text=$s;
        $sensor_list[$s]=$text;  // will be $x->info or $x->desc
    }


    // Trend type

    replace_if_set($trend_list, 'M', 'minute trend');
    replace_if_set($trend_list, 'T', 'second trend');
    replace_if_set($trend_list, 'R', 'raw');
    replace_if_set($trend_list, 'D', '10-minute trend');
    replace_if_set($trend_list, 'H', 'hour trend');

    if( $user_level==2 ){
        foreach($trend_list as $key=>$text){
            $trend_list[$key]= "$text [$key]";
        }
    }


    /*********************************
     * Display the channel control.    There are two forms. 
     * Multi-line is easier to read if you are a new user.
     * Single line is more compact and easier to use when you know
     *   what you are doing, and when there are several channels. */

    $dev_hdr="Site";
    if($user_level>3) $dev_hdr="Instrument";

    // DAQ sensors are "sensors", DMT Monitors are "Monitors"
    $sensor_hdr="Sensor";
    if( $subsys=='GDS' ) $sensor_hdr="Monitor";

    if($user_level > 2){

        echo "\n <TABLE align='left' border=1><TR>
        <th>$dev_hdr</th><th>Subsys</th><th>Station</th>
                <th>$sensor_hdr</th><th>Sampling</th></TR>
        <TR>";

        echo "<TD align='center' valign='top'>\n";  
        echo auto_select_from_array('source_'.$i, $source_list, $source);
        echo "</TD>\n";

        echo "<TD align='center' valign='top'>\n";
        echo auto_select_from_array('subsys_'.$i, $subsys_list, $subsys);
        echo "</TD>\n";

        echo "<TD align='center' valign='top'>\n";
        echo auto_select_from_array('station_'.$i, $station_list, $station);
        echo "</TD>\n";

        echo "<TD align='center' valign='top'>\n";
        echo auto_select_from_array('sensor_'.$i, $sensor_list, $sensor);
        echo "</TD>\n";

        //TODO: Make this sampling selector work
        echo "<TD align='center' valign='top'>\n";
        echo auto_select_from_array('ttype_'.$i, $trend_list, $ttype);
        if( $ttype!='R' ){
            echo auto_select_from_array('tcomp_'.$i, $tcomp_list, $tcomp);        
        }
        echo "</TD>\n";

        echo "   </TR></TABLE>\n ";

    }
    else { // level 1 & 2
        $help="[what's this?]";          // TODO: replace with an image?       
        if($user_level==2) $help="[?]";  // TODO: replace with an image?

        echo "\n <TABLE align='left' border=0>  \n";

        echo "<TR><TD class='input-item-beginnner' > $dev_hdr: </td><TD>   \n";  
        echo auto_select_from_array('source_'.$i, $source_list, $source);
        echo help_link("Data_Channel#Source");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > Subsystem: </td><TD>  \n";
        echo auto_select_from_array('subsys_'.$i, $subsys_list, $subsys);
        echo help_link("Data_Channel#Subsystem");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > Station: </td><TD>   \n";
        echo auto_select_from_array('station_'.$i, $station_list, $station);
        echo help_link("Data_Channel#Station");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > $sensor_hdr:  </td><TD>\n";
        echo auto_select_from_array('sensor_'.$i, $sensor_list, $sensor);
        echo help_link("Data_Channel#Sensor");
        echo "</TD></TR>\n";


        // Assuming we have a choice, show trend type/component
        //
        if( sizeof($trend_list) > 1 || sizeof($tcomp_list) > 1 ){
            echo "<TR><TD class='input-item-beginnner' > Sampling:  </td><TD>\n";
            echo auto_select_from_array('ttype_'.$i, $trend_list, $ttype);
            if( $ttype!='R' ){
                echo auto_select_from_array('tcomp_'.$i, $tcomp_list, $tcomp); 
            }
            echo help_link("Data_Channel#Sampling");
            echo "</TD></TR>\n";
        }

        // If no choices  then just use hidden variables 
        //
        else {
            echo "<TR><TD>\n ";
            echo " <input type='hidden' name='ttype_$i' value='$ttype'>\n";
            if( $ttype!='R' ){// all but raw frames have a trend component too
                if( !array_key_exists($tcomp, $tcomp_list) ){// need default?
                    $x = array_values($tcomp_list);
                    $tcomp = $x[0];
                }
                echo " <input type='hidden' name='tcomp_$i' value='$tcomp'>\n";
            }
            echo "</TD></TR>\n ";
        }

        echo "   </TABLE>\n ";
    }
}




//

/***********************************************************************\
 * Channel info array 
 \***********************************************************************/

/* TODO: At some point this will be used to populate a database of 
 * channels, rather than rebuilding this large array each time
 * someone uses the Analysis Tool.  
 */


/****
 * Built the $channel_info array for all available channels for
 * this user level, but only if it's changed or empty.
 */

function build_channel_info(){
    global $user_level;
    global $channel_info, $channel_info_level;

    // only rebuild if empty or differing user level

    if( !empty($channel_info) && ($channel_info_level == $user_level) ){
        return count($channel_info);
    }

    $channel_info=array();              // fresh start
    $_SESSION['channel_info'] = array();

    $Nsensors = 0;

    $Nsensors += build_channel_info_subset("M");
    $Nsensors += build_channel_info_subset("T");
    // Warning: Raw data fails horribly, don't uncomment until fixed.
    //$Nsensors += build_channel_info_subset("R");

    return $Nsensors;
}



/****
 * Build channel info array for minute, second, or raw data, etc..
 * (Someday we will put all the channel information into a database.
 * This function can be used to do the initial population of that
 * database.)
 */

function build_channel_info_subset($ttype){
    global $TLA_TOP_DIR;
    global $user_level; 
    global $channel_info, $channel_info_level;

    $channel_file = $TLA_TOP_DIR."/etc/Channels-" .$ttype. ".txt";

    $h = @fopen($channel_file, 'r');
    if(!$h) {
        debug_msg(1,"build_channel_info(): could not open file ".
        $channel_file);
        return 0;
    } 

    $Nsensors=0;
    $req_user_level=1;

    while( $line = fgets($h) ){
        if( trim($line)=='' ) continue;                 // ignore blank lines
        if( substr(ltrim($line),0,1) == '#') continue;  // ignore comment lines

        /* [user_level=?] blocks  specify the required user level.  We
         * only include the channel if the current user's level is higher.  */

        if( substr($line,0,1) == '['){
            list($u) = sscanf($line,"[user_level=%d]");      
            if( !empty($u) ) $req_user_level=$u;
            continue;
        }

        // Don't include stuff from higher user levels
        //TODO: skip this, make the decision when we SHOW the selector
        if( $req_user_level > $user_level ) continue;  

        $name='';

        // break out line fields:
        list($name, $rate) = sscanf($line,"%s %s");


        /* Break out main channel elements: source & subsystem */

        $ch_pat="/^(\w+)\:(\w+)-(.+)$/";
        $n = preg_match($ch_pat, $name, $matches);
        if($n<1) continue;
        list($all, $source, $subsys, $full_sensor ) = $matches;

        if($source=='H0' || $source=='H1' || $source=='H2' )  $site="Hanford";
        if($source=='L0' || $source=='L1' )   $site="Livingston";



        if( $subsys == "GDS" ){
            debug_msg(8,"GDS channel: $full_sensor [$ttype]");
            $station="MONITOR";
            $sensor = $full_sensor;
        }
        else {

          /* Now get station and sensor */

          $station_pat = "/(.*)(LVEA|EX|EY|MX|MY|VAULT|BSC\d+|COIL)_(\S+)/";
          $n = preg_match($station_pat, $full_sensor, $matches);
          if($n >0) {// if no match it's probably GDS, so try that
              $blrm = $matches[1];
              $station = $matches[2];
              $sensor = $matches[3];
          }

          if( !empty($blrm) ) {
              debug_msg(8, "BLRM? ($blrm)  $station / $sensor");
          }
        }


        /* Trended data channel component type (ie. extract suffix) */

        $tcomp = '';
        if( $ttype !='R' ) {
            $trend_pat="/(\S+)\.(rms|min|max|mean|n)$/";
            $n = preg_match($trend_pat, $sensor, $matches); 
            if( $n>0 ) {
                $sensor = $matches[1];
                $tcomp = $matches[2];
            }
        }


        /* Create new channel object.
         * (This is clearer than positional parameters in constructor.) */

        $Inxx = new InChannel();

        $Inxx->name=$name;
        $Inxx->site=$site;
        $Inxx->rate=$rate;
        $Inxx->source=$source;  // H0, L0, (or H1, H2, L1, G1 someday?) or NOAA
        $Inxx->subsys=$subsys;
        $Inxx->station=$station;
        $Inxx->sensor=$sensor;
        $Inxx->ttype=$ttype;
        $Inxx->tcomp=$tcomp;
        $Inxx->domain='t';
        $Inxx->file="(unused)"; // Unused: change some day to real data source
        $Inxx->format='frame';
        $Inxx->user_level= $req_user_level;

        $Nsensors++;


        /* Now fill in particular properties of particular 
         * types of channels */



        /* PEM Seismic, Tiltmeter, Magnetometer -- extract direction */

        $pem_pat="/:PEM-([^_]+)_(SEIS|TILT|MAG)(.)/";
        $n = preg_match($pem_pat,$name,$matches);
        if($n >0) {
            list($all, $st, $stype, $xyz) = $matches;
            $xyz=strtolower($xyz);   
            $x = "";
            if( !empty($blrm) ) $x ="BLRMS ";
            if($stype=='SEIS') $x .= "Seismic";
            if($stype=='TILT') $x .= "Tiltmeter";
            if($stype=='MAG')  $x .= "Magnetometer";
            $Inxx->desc="$x $xyz";
            $Inxx->info="$x $xyz";
        }


        /* GDS Channel(s) - so far just eqMon for earthquakes */

        if( $Inxx->subsys == "GDS" ){
            $monitor = $Inxx->sensor;
            $Inxx->desc="$monitor Monitor";
            $Inxx->info=$monitor;
            $Inxx->units = "1/0";
        }

        /* Bandwidth limited RMS (BLRMS) channel filter limits */

        $blrm_pat="/BRMS_.*(SEIS|TILT|MAG)(.)_([^_]+)(-|_)([^_]+)Hz/";
        $n = preg_match($blrm_pat,$name,$matches);
        if($n >0) {
            list($all, $stype, $xyz, $bw_low, $sep, $bw_high) = $matches;
            $xyz=strtolower($xyz);   
            $x = "";
            if($stype=='SEIS') $x .= "Seismic";
            if($stype=='TILT') $x .= "Tiltmeter";
            if($stype=='MAG')  $x .= "Magnetometer";

            $Inxx->bw_low=$bw_low;
            $Inxx->bw_high=$bw_high;
            $Inxx->desc="$x $xyz, Bandwidth filtered, $bw_low to $bw_high Hz"; 
            $Inxx->info="$x $xyz, BW filtered $bw_low to $bw_high Hz ($sensor)"; 
            $Inxx->units="(microns/s)^2";
        }


        /* Place it in channel tree array */

        if( $ttype == 'R' ){
            $channel_info[$source][$subsys][$station][$sensor][$ttype]
                = $Inxx;
        }
        else {
            $channel_info[$source][$subsys][$station][$sensor][$ttype][$tcomp]
                = $Inxx;
        }

        unset($Inxx);
    }
    fclose($h);
    return $Nsensors;
}


// Since the channel_info[] array is large, it's a good idea
// to clear it out once we don't need it anymore.
//
function flush_channel_info(){
    global $channel_info;               // global variable

    recall_variable('channel_info');    // from $_SESSION
    $channel_info=array(); 
    remember_variable('channel_info');    // into $_SESSION
}


$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: channels.php,v 1.41 2009/02/11 20:04:05 myers Exp $";
?>
