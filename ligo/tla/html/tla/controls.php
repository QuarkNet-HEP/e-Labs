<?php 
/***********************************************************************\
 * Specific controls for user input.
 *
 * The general idea is that there is one function for the "control",
 * the input field or button or box on the web page, and another
 * function to "handle" the input from the control.
 * 
 * There may also be controls in other files for more specific purposes.
 *
 * Eric Myers <myers@spy-hill.net  - 11 August 2006
 * @(#) $Id: controls.php,v 1.24 2008/12/11 20:25:51 myers Exp $
\***********************************************************************/

require_once("debug.php");         
require_once("messages.php");      


/*********************
 * Automatic update feature control
 * (checkboxes in HTML suck - they are empty if unset)
 */

function apply_control(){//TODO:  Delete this by 0.34
    debug_msg(1,"please change apply_control() to auto_update_control()");
    auto_update_control();
}


/* Sets global auto_update to current value, if set, or else a
 * default appropraite to the user level */

function auto_update_default(){
    global $auto_update;
    global $user_level;

    $auto_update='on';   // experts

    if( isset($user_level) && $user_level<3 ) {
        $auto_update='off';  
    }
    debug_msg(1,"auto_update set to DEFAULT value '$auto_update'");
    return $auto_update;
}



// Display user control for auto_update

function auto_update_control(){
    global $auto_update;

    // <noscript> only? No, you need to be able to go back and forth
    echo "<input type='submit' name='apply' value='Apply'>\n";
    // </noscript>

    //TODO: turn the checkbox yellow if a change is pending

    $x =  $auto_update=='on' ?' CHECKED ' : ' ';
    echo "<input type='checkbox' name='auto_update' ";
    if( $auto_update=='on' ) echo " CHECKED ";
    echo " onChange='submit_form(this.form)'>\n"; 

    $x =  $auto_update=='on' ?'on' : 'off';
    echo "<input type='hidden' name='auto_update_prev' ".
                " value='$x'>\n";

    $x = ( $auto_update == 'on' ) ? "changes are applied immediately" 
                                  : "check to apply changes immediately";

    echo "<script language='JavaScript' type='text/javascript'>
                document.write(\" $x \");
          </script>\n";
    echo "<noscript>
               Press 'Apply' to make your changes take effect.
          </noscript>\n";
}


/**
 * User selection of auto_update control..  

 */

function handle_auto_update(){

    recall_variable('auto_update');
    global $auto_update;

    if( empty($auto_update) ) auto_update_default(); 

    $x = get_posted('auto_update') ;
    debug_msg(3,"auto_update POST value was '$x'");
    $y = get_posted('auto_update_prev'); // was it on the menu?
    debug_msg(3,"auto_update_prev POST value was '$y'");
    if( $y && !$x ) $x = 'off';
    if( $x )  $auto_update = $x;

    debug_msg(3,"auto_update VALUE is now '$auto_update'");
    remember_variable('auto_update');   
}



/**
 * Reset button:
 */

function check_for_reset(){   // old name.  Delete by 0.34
    debug_msg(1,"Please change from check_for_reset() to handle_reset()");
    exit(47);
}


function reset_session(){
    global $messages_shown;
    global $main_steps;

    debug_msg(2,"RESET!");

    clear_log_files();
    clear_plot_files();

    $messages_shown=false;

    // TODO: Why not just clear all files for this user, to be sure?
    $lockfile=$id . ".lock"; 
    if( file_exists($lockfile) ) {
        //TODO:  need to terminate any running tasks? JA oder Nein?
        @unlink($lockfile);   
    }

    // Preserve authentication info, if there is any
    $auth_type=$_SESSION['AUTH_TYPE'];
    $u = $_SESSION['PHP_AUTH_USER'];
    $p = $_SESSION['PHP_AUTH_PW'];
    $authenticator = $_SESSION['authenticator'];

    // Unset ALL of the session variables.
    $_SESSION = array();       

    // Restore authentication information
    $_SESSION['AUTH_TYPE'] = $auth_type;
    $_SESSION['PHP_AUTH_USER'] = $u;
    $_SESSION['PHP_AUTH_PW'] = $p;
    $_SESSION['authenticator']= $authenticator ;


    // Initialize steps and get started
    main_steps_init();
    $jumpto = $main_steps[1]->url;      // steps start at 1 not zero

    debug_msg(3,"Session reset. Jumping to $jumpto");
    header("Location: ". $jumpto);
    exit(0);
}


function handle_reset(){
    global $sw_release, $self;

    $do_reset=false;    

    // An explicit request for a reset?
    //
    debug_msg(5,"check for reset:" . get_posted('reset_session') );
    if( get_posted('reset_session') ) $do_reset=true;

    // Was the last time we did _anything_ too long ago? 
    //
    if( $_SESSION && array_key_exists('reset_timestamp', $_SESSION) ){
        $last_reset=$_SESSION['reset_timestamp'];
        if( time()-$last_reset > MAX_SESSION_AGE ) $do_reset=true;
    }
    $_SESSION['reset_timestamp']= time();   // update the timestamp


    // Did we change from production/test/dev to something else? 
    //
    recall_variable('sw_release');  
    $this_release = 'tla';

    if( strpos($self,'tla_dev') !== FALSE ) {// URL contains "tla_dev"?
        $this_release = 'tla_dev';
        add_message("Warning: this is DEVELOPMENT software, which may be unstable.", 
                MSG_WARNING);
    }
    if( strpos($self,'tla_test') !== FALSE ) {// URL contains "tla_test"?
        $this_release = 'tla_test';
        add_message("Warning, this is TEST software, which may be unstable.  " 
                ."Please report any bugs! ", MSG_WARNING);
    }

    if( !empty($sw_release) && $this_release != $sw_release ) {
       debug_msg(1,"Software release changed from $sw_release to $this_release");
        $do_reset=true;
        add_message("SW release changed, causing a reset", MSG_WARNING);
    }


    // Remember the current release, whatever it is
    //
    if( !empty($this_release) ) $sw_release = $this_release;  
    remember_variable('sw_release');

    // If any of the conditions above apply then do the reset
    //
    if( $do_reset ) reset_session();
    return;
}

    


/***********************************************************************
 * Plots are given sequential numbers, so to undo we just step back.
 * Each $plot_option item reverts back to previous value.
 * Return false if nothing done, true if we really stepped back.
 */

function handle_undo(){
    recall_variable('Nplot');
    global $Nplot, $plot_options;
 
    if( !get_posted('undo_plot') ) return false;

    if( empty($Nplot) ||  $Nplot <= 1) {
        add_message("Cannot Undo.", MSG_WARNING);
        return false;
    }

    // remove any existing plot and update files

    clear_plot_files($Nplot);  
    //clear_log_files($Nplot);  

    $id0=uniq_id();
    $updates = slot_dir()."/".$id0."_update.C";
    @unlink($updates);

    // revert the display options

    foreach($plot_options as $opt){
        $opt->undo($Nplot);
    }

    // now backup up to previous 

    $Nplot--;
    //remember_variable('Nplot');
    add_message("Undo.  Back to step $Nplot.", MSG_GOOD);
    return true;
} 


/***********************************************************************\
 * The 'user level' controls the complexity of the display of information
 * and controls throughout the session.   Lower levels present fewer 
 * options and more verbose help information.  Higher levels present more 
 * options and less verbose assistance.    This 'control' displays the 
 * setting and lets the user change the setting.
\***********************************************************************/

function update_user_level(){ // OLD NAME
    debug_msg(1,"Please change from update_user_level() to handle_user_level()");
    handle_user_level();
}

function handle_user_level(){
    recall_variable('user_level');
    recall_variable('authenticator');

    global $user_level, $authenticator;         // user interface/display level

    // Previous setting via cookie?

    if ( isset($_COOKIE['user_level']) ) {
        $user_level =  intval($_COOKIE['user_level']);
    }

    // Any change via user input?

    if ( isset($_POST['user_level']) ) {
        $x = $_POST['user_level'];
        if( is_numeric($x) ) {
            $user_level=$x;
            set_user_level($x);
        }
    }

    // If still not set, then set it to 'beginnner' for this session

    if( !isset($user_level) || $user_level <= 0  || $user_level > 5) {
        $user_level = 1;
        set_user_level($user_level,0);
    }


    // Access restrictions for now on level 5

    if( $user_level > 4 ) {

        debug_msg(1,"Whoa, you need to present a Grid Certificate first.", 
                  MSG_ERROR);
        $ttl=7;     // you have but little time, Mr. Bond.
        add_message("A valid Grid user certificate is required to access the
        analysis tool at the Super Expert level.        <br>
        You can look around here, but you cannot do anything, 
        and the page will reset shortly.<P>   ", MSG_WARNING);

        // When we come back require_auth() will lower the level
        header("Refresh: ".$ttl."; URL=".$self);
        // and continue with the check below, for now...
    }
}



/***
 * Set the user level, both in the session and as remembered for later
 * via cookies. The optional $how_long sets how long the cookie lives. 
 * Set it to -1 to clear the cookie.  Set it to 0 to make the cookie last
 * for the lifetime of the browser session.  If omitted, the default cookie
 * lifetime is 30 days;
 */

function set_user_level($n,$how_long=-47){
    remember_variable('user_level');
    global $user_level;

    $user_level = $n;
    $_COOKIE['user_level'] = $user_level;

    if($how_long==0) {
        $expires=0;
    }
    if($how_long==-47) $how_long=3600*24*30;
    if($how_long > 0){
        $expires=time()+$how_long;
    }
    setcookie('user_level', $user_level, $expires); 
}




/**
 * Display the User Level indicator/control:
 */

function user_level_control(){
    global $user_level, $auto_update;
  
    // This is redundant, but we'll keep it for now because it triggers
    // the right behaviour if user tries to become a Super Expert (level 5)
    // handle_user_level();

    $level[1] = 'Beginner';
    $level[2] = 'Intermediate';
    $level[3] = 'Advanced';
    if($user_level>=3) {// only Advanced users can even know about Expert mode
        $level[4] = 'Expert';
    }
    if($user_level>=4) {// only Experts know they can do even better ;-)
        $level[5] = 'Super Expert';
    }

    echo "\n<!-- User Level Control -->\n";

    // Show the level image
	echo "<div id=\"header-logbook\">";
    $image="img/level_" .$user_level. ".gif";
    echo "<img src='" .$image. "' valign='bottom' border=0
               alt='User Level: " .$level[$user_level]. "'
               title='User Level: " .$level[$user_level]. "'>";

    // Selector:

    echo  auto_select_from_array('user_level', $level, array("selection" => $user_level, 
    	"changeHandler" => "javascript:this.form.submit();") );
    echo "<noscript><input type=\"submit\" value=\"Set\"></input></noscript>\n";
    echo "</div>\n";
}


?>
