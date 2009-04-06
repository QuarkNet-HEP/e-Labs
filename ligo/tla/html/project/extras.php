<?php 
/***********************************************************************\
 *  extras.inc -  extra functions for BOINC forums for I2U2 
 * 
 * This is mainly for stuff I work on, which should then move
 * out to another file when it's ready.
 *
 *
 * @(#) Last changed: -EAM 26Sep2007
\**********************************************************************/

if( !function_exists('debug_msg') ) {
    require_once("../include/debug.php");
 }


/***********
 * Input selector for choosing a team.  On a large project you probably
 * do NOT want to use this, but for a small project it might be okay.
 */

function get_team_list(){
    $result = mysql_query("SELECT * FROM team ORDER BY name");
    if( !$result ) return NULL;
    $team_list[0]="None";
    while( $team = mysql_fetch_object($result) ){
        $id=$team->id;
        $name=$team->name;
        $team_list[$id]=$name;
    }
    mysql_free_result($result);
    return $team_list;         
}

function team_select($default=NULL){
    $team_list = get_team_list();
    if( empty($team_list) ) return "Error: cannot get team list!";
    return select_from_array('teamid', $team_list, $default);
}
 

/**
 * Generate a "select" element from an array of values 
 * which automaticically submits itself if scripting is enabled.
 * Optional 4th argument is the label for a submit button which is shown if
 * scripting is turned off, as long as it is defined.
 */

if( !function_exists('auto_select_from_array') ) {

    function auto_select_from_array($name, $array, $selection, $button='') {
        $out = "
      <script language='JavaScript'> function submit_form(f){f.submit(); } </script>
      <select name='$name' onChange='submit_form(this.form)'>\n";

        foreach ($array as $key => $value) {
            $out .= "        <option ";
            $out .= "value='". $key. "' ";
            if ( $key == $selection ) {  $out .= " selected "; }
            $out .=">". $value. "</option>\n";
        }
        $out .= "      </select>\n";
        if( !empty($button) ) {
            $out .= "      <noscript><input type='SUBMIT' value='$button' ></noscript>\n";
        }
        return $out;
    }

 }



/**
 * return an array where the values are the keys, for use in a selector
 */

function array_of_values($a) {
    $r=array();
    foreach($a as $value){
        $r[$value]=$value;
    }
    return $r;
}



/* This is show_login() but modified for our project. 
 * Now with added avatar goodness! */

function show_login_name($user) {
    if( !empty($user) ) {
        $username=$user->name;
        echo tr(LOGGED_IN_AS) ." ". $username;
        $user = getForumPreferences($user);
        $avatar = $user->avatar;
        if( !empty($avatar) ){
          echo "<br><img src='$avatar' width='50' >\n";
      }
      echo "<br><a href='/logout.php'>";
      echo "["  .tr(LOG_OUT). "]</a>";
      //echo   "<img src='/images/Logout.png' alt='".tr(LOG_OUT)."'>";
      echo "</a>";
  }
  else {
      echo "Not logged in";
      echo "<br><a href='login_form.php'>";
      echo "[" .tr(LOG_IN). "]</a>"; 
      //echo "<img src='/images/Login.png' alt='".tr(LOG_IN)."' >";
      echo "</a>";
  }
}



// This is show_login() from ../inc/util.inc but modified for our project.

function old_show_login_name($username) {
    if ($username) {
        echo "Logged in as ", $username;
        // echo  "<a href='/logout.php'><img valign=TOP src='/images/Logout.gif' border=0 ></a>";
        echo "<br>&nbsp;&nbsp;<a href='/logout.php'>[Logout]</a>";
    }
    else {
        echo "Not logged in";
        //echo " <a href='/login_form.php'><img valign=TOP src=images/Login.gif border=0 ></a>";
        echo "<br>&nbsp;&nbsp;<a href='/login_form.php'>[Login]</a>"; 
    }
}



/************************************************
 * Get BOINC user's login name
 */ 

function get_login_name() {
    //    global $logged_in_user, $user;

    $logged_in_user=get_logged_in_user(false);
    // Most pages use $logged_in_user 
    if( $logged_in_user ) {
        return $logged_in_user->name;
    }

    // If neither is set, we may still be able to get the name

    if( isset($_SESSION) ){
        if (array_key_exists('authenticator', $_SESSION)) {
            $authenticator = $_SESSION["authenticator"];
        }
        if (array_key_exists('i2u2_auth', $_SESSION)) {
            $authenticator = $_SESSION['i2u2_auth'];
        }
    }

    if( !isset($authenticator) ) {
        if( isset($_COOKIE['auth']) ){
            $authenticator = $_COOKIE['auth'];
        }
        if( isset($_COOKIE['i2u2_auth']) ){
            $authenticator = $_COOKIE['i2u2_auth'];
        }
    }

    if( isset($authenticator) ) {
        $logged_in_user = get_user_from_auth($authenticator);        
        return $logged_in_user->name;
    }
    return NULL;  
}

?>
