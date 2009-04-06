<?php
/***********************************************************************\
 * transformations.php  - Functions to support data transformations
 *                        (aka workflows, or virtual instruments (vi's)
 *
 * 
 * This file is implementation code, not presentation code.
 * No direct user output should be generated, except that you can 
 * use add_message() to show something to the user.
 *
 * Eric Myers <myers@spy-hill.net>  - 15 July 2008
 * @(#) $Id: transformations.php,v 1.4 2008/10/27 18:37:16 myers Exp $
\***********************************************************************/


/*************************
 * Object class for workflow selection 
 */

class Work_Flow {
    var $name;          // full name of channel 
    var $info;          // short description
    var $desc;          // long description
    var $user_level;    // minimum user level for use
    var $orderID;       // sort ordering
    var $maxInputs;     // _array_ of max channels for each user_level


    // Constructor: 
    function Work_Flow($name='', $info='', $desc='',$user_level=1, $orderID=10){
        $this->name=$name;
        $this->info=$info;
        $this->desc=$desc;
        $this->user_level=$user_level;
        $this->orderID=$orderID;
        $this->maxInputs=array(1,1,1,1,1);
        return $this;
    }

    function max_channels(){
        global $user_level;
        $N=1;
        if( array_key_exists($user_level, $this->maxInputs) ){
            $N = $this->maxInputs[$user_level-1];
        }
        return $N;
    }


}// end of Work_Flow class


/****
 * Maximum number of allowed channels is based on user level
 */

function get_wf_max_channels($wf,$user_level=1){
    $N=1;
    if( empty($wf) ) return $N;
    if( array_key_exists($user_level, $wf->maxInputs) ){
        $N = $wf->maxInputs[$user_level-1];
    }
    return $N;
}





/**
 * Handle user input of number of input channelsfpuna
 */

function handle_Ninputs($wf){
    global $Ninputs;

    if( $n = get_posted('Ninputs') ) {
        debug_msg(1,"Ninputs proposed to be set to $n, whereas max is "
                  .$wf->max_channels() );

        if( is_numeric($n) && $n > 0 && $n <= $wf->max_channels() ){
          $Ninputs=$n;
        }
    }
}



 

/*******************************
 *  VI specific settings:  load the file settings.php for one or all
 *  virutal instruments (workflows)
 */

// Load the settings for ALL VI's
//
function load_all_vi_settings(){
    global $TLA_VI_DIR;

    $dh = opendir($TLA_VI_DIR);
    while( false != ($d = readdir($dh)) ){
        if( !is_dir($TLA_VI_DIR."/$d") ) continue;
        $settings = $TLA_VI_DIR. "/$d/settings.php";
        if( file_exists($settings) ){
            require_once($settings);

        }
    }

}

// Load the settings for a given VI
//
function load_vi_settings($d){
    global $TLA_VI_DIR;

    if( empty($d) ) {
        debug_msg(1,"load_vi_settings(): Empty name.");
        return FALSE;
    } 
    if( !is_dir($TLA_VI_DIR."/$d") ) return FALSE;
    $settings = $TLA_VI_DIR. "/$d/settings.php";
    if( !file_exists($settings) ) return FALSE;
    require_once($settings);
    return TRUE;

}



/**
 * Conditionals for particular steps
 * Used in vi/$WorkFlow/settings.php for conditional code which
 * only needs to be done for a particular step.
 */

// Returns TRUE/FALSE based on name of step (filename) 

function is_step_named($name){
    if( empty($name) ) return FALSE;
    $fname = basename($_SERVER['PHP_SELF'], '.php');  // get current filename
    if( $name == $fname ) return TRUE;
    return FALSE;
}


$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: transformations.php,v 1.4 2008/10/27 18:37:16 myers Exp $";
?>
