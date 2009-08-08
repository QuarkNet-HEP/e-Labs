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
            debug_msg(3,"is_valid: Trend channel (".$this->tcomp.") does not exist: channel_info".
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

define("SITE_LEVEL", 0);
define("SUBSYS_LEVEL", 1);
define("STATION_LEVEL", 2);
define("SENSOR_LEVEL", 3);
define("TREND_LEVEL", 4);
define("TCOMP_LEVEL", 5);

function nice_name($item, $node, $itemlevel) {
	global $user_level;
	if ($itemlevel == SITE_LEVEL) {
		//site
		if ($user_level == 1) {
			if ($item == "H0") return "Hanford";
			if ($item == "L0") return "Livingston";
			if ($item == "NOAA") return "National Oceanic and Atmospheric Admin.";
    	}
    	else if($user_level == 2) {
    		if ($item == "H0") return "Hanford (LHO)";
			if ($item == "L0") return "Livingston (LLO)";
			if ($item == "NOAA") return "National Oceanic and Atmospheric Admin. (NOAA)";
    	}
    	else {
    		return $item;
    	}
	}
	else if ($itemlevel == SUBSYS_LEVEL) {
		//subsystem
		$k = $item;
		if ($user_level <= 2){ 
	        if ($item == "DMT") $k = "Data Monitoring Tool";
	        if ($item == "GDS") $k = "Global Diagnostic System";
	        if ($item == "PEM") $k = "Physics Environment Monitoring";
	        if ($item == "NDBC") $k = "National Data Buoy Center";
	        if ($item == "METAR") $k = "Meteorlogical Airport Report";
	        if ($item == "LSC") $k = "Length Sensing and Control";
	    }
	    if ($user_level == 2) {
	        $k = $k." (".$item.")";
	    }
	    return $k;
	}
	else if ($itemlevel == STATION_LEVEL) {
		//station
		$k = $item;
		if ($user_level <= 2) {
	        if ($item == "LVEA") $k = 'Corner Station';
	        if ($item == "EX") $k = 'End Station, X-arm';
	        if ($item == "EY") $k = 'End Station, Y-arm';
	        if ($item == "MX") $k = 'Middle Station, X-arm';
	        if ($item == "MY") $k = 'Middle Station, Y-arm';
	        if ($item == "VAULT") $k = 'Seismometer Vault';
	        if ($item == "MONITOR") $k = 'Control Room';
	    }
	    if ($user_level == 2) {
	        $k = $k." (".$item.")";
	    }
	    return $k;
	}
	else if ($itemlevel == SENSOR_LEVEL) {
		//sensor
		$a = array_keys($node);
		if (!empty($a)) {
			$node = $node[$a[0]];
			$a = array_keys($node);
			if (!empty($a)) {
				$node = $node[$a[0]];
			}
		}
        if ($user_level == 1) $text = $node->desc;  // verbose description
        if ($user_level == 2) $text=$node->info;  // terse description
        if (empty($text)) $text = $item;
        return $text;
	}
	else if ($itemlevel == TREND_LEVEL) {
		if ($item == "M") return 'minute trend';
    	if ($item == "T") return 'second trend';
    	if ($item == "R") return 'raw';
    	if ($item == "D") return '10-minute trend';
    	if ($item == "H") return 'hour trend';
	}
	else if ($itemlevel == TCOMP_LEVEL) {
		return $item;
	}
	return $itemlevel.$item;
}

function mahash($list, $level) {
	ksort($list);
	$s = "";
	foreach ($list as $k => $v) {
		if (is_array($v)) {
			$s = $s.$k.".".mahash($v, $level + 1);
		}
		else {
			$s = $s.$level.".".$k.",";
		}
	}
	return $s;
}

function generate_array($list, $level, &$cache, &$count) {
	if ($level > TCOMP_LEVEL) {
		return "null";
	}
	$hash = mahash($list, 0);
	if (array_key_exists($hash, $cache)) {
		$sym = $cache[$hash];
		return $sym;
	}
	$i = count($list);
	$l = array();
	$s = array();
	foreach($list as $k => $v) {
		$l[$k] = generate_array($v, $level + 1, $cache, $count);
	}
	$sym = "c".$count;
	$count++;
	echo($sym." = new Array(");
	$i = count($l);
	foreach ($l as $key => $value) {
		$nice = nice_name($key, $list[$key], $level);
		echo("new Node(\"".$key."\", \"".$nice."\", ".$value.")");
		if ($i > 1) {
			echo(", ");
		}
		$i--;
	}
	echo(");\n");
	$cache[$hash] = $sym;
	return $sym;
}

/***********************************************
 * Generates a tree of javascript arrays containing
 * all the possible selections
 */
function generate_data_tree($i, $channel_info) {
	if ($i != 1) {
		//only do this once
		return;
	}
	
echo <<<END
	<script language="JavaScript">
		function Node(name, niceName, subtree) {
			this.name = name;
			this.niceName = niceName;
			this.subtree = subtree;
		}

END;
	
	$cache = array();
	$count = 0;
	$sym = generate_array($channel_info, 0, $cache, $count);
echo <<<END
		var choiceTree = $sym;
	</script>
END;
}

function _list_all_types($level, $crt, $list, &$result) {
	foreach ($list as $k => $v) {
		if ($level == $crt) {
			$result[$k] = nice_name($k, $v, $crt);
		}
		else {
			_list_all_types($level, $crt + 1, $v, $result);
		}
	}
}

function list_all_types($level, $channel_info) {
	$l = array();
	_list_all_types($level, 0, $channel_info, $l);
	return $l;
}


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

    /*********************************
     * Display the channel control.    There are two forms. 
     * Multi-line is easier to read if you are a new user.
     * Single line is more compact and easier to use when you know
     *   what you are doing, and when there are several channels. */
    
    generate_data_tree($i, $channel_info);

    $dev_hdr="Site";
    if($user_level>3) $dev_hdr="Instrument";

    // DAQ sensors are "sensors", DMT Monitors are "Monitors"
    $sensor_hdr="Sensor";
    if( $subsys=='GDS' ) $sensor_hdr="Monitor";
	echo "<div class=\"control\">\n";
    if($user_level > 2){
        echo "\n <TABLE cellspacing=\"0\" class=\"input\"><TR>
        <th>$dev_hdr</th><th>Subsys</th><th>Station</th>
                <th>$sensor_hdr</th><th>Sampling</th></TR>
        <TR>";

        echo "<TD align='center' valign='top'>&nbsp;\n";  
        echo auto_select_from_array('source_'.$i, list_all_types(SITE_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo "</TD>\n";

        
        echo "<TD align='left' valign='top'>&nbsp;\n"; 
		echo auto_select_from_array('subsys_'.$i, list_all_types(SUBSYS_LEVEL, $channel_info), 
			array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo "</TD>\n";

        echo "<TD align='left' valign='top'>&nbsp;\n";
        echo auto_select_from_array('station_'.$i, list_all_types(STATION_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo "</TD>\n";
        	

        echo "<TD align='left' valign='top'>&nbsp;\n";
        echo auto_select_from_array('sensor_'.$i, list_all_types(SENSOR_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo "</TD>\n";
        	
        	
        //TODO: Make this sampling selector work
        echo "<TD align='left' valign='top'>\n";
        echo auto_select_from_array('ttype_'.$i, list_all_types(TREND_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        
        echo auto_select_from_array('tcomp_'.$i, list_all_types(TCOMP_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        
        echo "</TD></tr>\n";
        echo "   </TR></TABLE>\n ";

    }
    else { // level 1 & 2
        $help="[what's this?]";          // TODO: replace with an image?       
        if($user_level==2) $help="[?]";  // TODO: replace with an image?
        echo "\n <TABLE border=\"0\">  \n";

        echo "<TR><TD class='input-item-beginnner' > $dev_hdr: </td><TD>   \n";  
        echo auto_select_from_array('source_'.$i, list_all_types(SITE_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo help_link("Data_Channel_Source");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > Subsystem: </td><TD>  \n";
        echo auto_select_from_array('subsys_'.$i, list_all_types(SUBSYS_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo help_link("Data_Channel_Subsystem");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > Station: </td><TD>   \n";
        echo auto_select_from_array('station_'.$i, list_all_types(STATION_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo help_link("Data_Channel_Station");
        echo "</TD></TR>\n";

        echo "<TR><TD class='input-item-beginnner' > $sensor_hdr:  </td><TD>\n";
        echo auto_select_from_array('sensor_'.$i, list_all_types(SENSOR_LEVEL, $channel_info), 
        	array("selected" => $source, "changeHandler" => "updateSelectors"));
        echo help_link("Data_Channel_Sensor");
        echo "</TD></TR>\n";


        // Assuming we have a choice, show trend type/component
        //
        if( sizeof($trend_list) > 1 || sizeof($tcomp_list) > 1 ){
            echo "<TR><TD class='input-item-beginnner' > Sampling:  </td><TD>\n";
            echo auto_select_from_array('ttype_'.$i, list_all_types(TREND_LEVEL, $channel_info), 
            	array("selected" => $source, "changeHandler" => "updateSelectors"));
            if( $ttype!='R' ){
                echo auto_select_from_array('tcomp_'.$i, list_all_types(TCOMP_LEVEL, $channel_info), 
                	array("selected" => $source, "changeHandler" => "updateSelectors")); 
            }
            echo help_link("Data_Channel_Sampling");
            echo "</TD></TR>\n";
        }

        // If no choices  then just use hidden variables 
        //
        else {
            echo "<TR><TD colspan=\"2\">\n ";
            echo " <input type='hidden' id=\"ttype_$i\" name='ttype_$i' value='M'>\n";
            if( $ttype!='R' ){// all but raw frames have a trend component too
                if( !array_key_exists($tcomp, $tcomp_list) ){// need default?
                    $x = array_values($tcomp_list);
                    $tcomp = $x[0];
                }
                echo " <input type='hidden' id=\"tcomp_$i\" name='tcomp_$i' value='mean'>\n";
            }
            echo "</TD></TR>\n ";
        }

        echo "   </TABLE>\n ";
    }
    echo "</div>\n";
    
echo <<<END
		<script language="JavaScript">
			var types = ["source", "subsys", "station", "sensor", "ttype", "tcomp"];
			
			function getSelector(i, j) {
				var id = types[j] + "_" + i;
				return document.getElementById(id);
			}
			
			function getSelected(i, j) {
				var d = getSelector(i, j);
				if (d == null) {
					return null;
				}
				if (d.nodeName.toLowerCase() == "select") {
					var index = d.selectedIndex;
					if (index < 0) {
						return null;
					}
					else {
						return d.options[index].value;
					}
				}
				else if (d.nodeName.toLowerCase() == "input") {
					return d.value;
				}
				else {
					return null;
				}
			}
			
			function trace(i, j) {
				var a = new Array();
				for (var k = 0; k <= j; k++) {
					a.push(getSelected(i, k));
				}
				return a;
			}
			
			function getSubNode(node, option) {
				for (var j in node.subtree) {
					if (option == node.subtree[j].name) {
						return node.subtree[j];
					}
				}
			}
			
			function getNode(t) {
				var crt = new Node("", "", choiceTree);
				for (var i in t) {
					crt = getSubNode(crt, t[i]);
				}
				return crt;
			}
			
			function setSignal(i) {
				var s = document.getElementById("signal_" + i);
				if (s == null) {
					return;
				}
				else {
					s.src = "img/signal_green.gif";
				}
			}
			
			function updateChannelStatus(i) {
				//site:subsys-station_sensor.sampling [trend]
				if ($user_level != 1) {
					var d = document.getElementById("status_" + i);
					if (d != null) {
						var s = getSelected(i, 0) + ":" + getSelected(i, 1) + "-" + 
							getSelected(i, 2) + "_" + getSelected(i, 3) + "." + 
							getSelected(i, 5) + " [" + getSelected(i, 4) + "]";
						d.innerHTML = s;
					}
				}
			}
			
			function populateSelect(i, j, node, s) {
				var o = getSelected(i, j);
				while (s.length > 0) {
					s.remove(0);
				}
				
				var found = false;
				for (var newo in node.subtree) {
					var opt = new Option();
					opt.value = node.subtree[newo].name;
					opt.text = node.subtree[newo].niceName;
					try {
						s.add(opt, null);
					}
					catch (ex) {
						s.add(opt);
					}
					if (opt.value == o) {
						opt.selected = true;
						found = true;
					}
				}
				if (!found) {
					s.selectedIndex = 0;
					o = s.options[0].value;
				}
				populate(i, j + 1, getSubNode(node, o));
			}
			
			function hasValue(node, v) {
				for (var i in node.subtree) {
					if (node.subtree[i].name == v) {
						return true;
					}
				}
				return false;
			}
			
			function populateHidden(i, j, node, s) {
				//return;
				// for hidden trend preference is: minute trend, second trend
				// for hidden trend subchannel: mean, rms
				if (hasValue(node, "M")) {
					s.value = "M";
				}
				else if (hasValue(node, "T")) {
					s.value = "T";
				}
				else if (hasValue(node, "mean")) {
					s.value = "mean";
				}
				else if (hasValue(node, "rms")) {
					s.value = "rms";
				}
				else {
					//last resort: use first
					s.value = node.subtree[0].name;
				}
				populate(i, j + 1, getSubNode(node, s.value));
			}
			
			function populate(i, j, node) {
				var s = getSelector(i, j);
				if (s == null) {
					return;
				}
				if (s.nodeName.toLowerCase() == "select") {
					populateSelect(i, j, node, s);
				}
				else if (s.nodeName.toLowerCase() == "input") {
					populateHidden(i, j, node, s);
				}
			}
			
			function _updateSelectors(i, j) {
				var node = getNode(trace(i, j));
				populate(i, j + 1, node);
				setSignal(i);
				updateChannelStatus(i);
			}
			
			function findIndex(type) {
				for (var i = 0; i < types.length; i++) {
					if (types[i] == type) {
						return i;
					}
				}
				return -1;
			}
			
			function updateSelectors(id) {
				var s = id.split("_");
				_updateSelectors(s[1], findIndex(s[0]));
			}
			
			//discover how many channels we have
			
			for (var i = 1; i <= 10; i++) {
				var d = document.getElementById("source_" + i);
				if (d == null) {
					document.channelCount = i - 1;
					break;
				}
				else {
					_updateSelectors(i, 0);
				}
			}
		</script>
END;
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
