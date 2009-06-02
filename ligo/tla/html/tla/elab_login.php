<?php
/***********************************************************************\
 * elab_login.php - authenticate to the e-Lab system
 *
 * Use this form to allow the user to authorize Bluestone to access
 * their e-Lab stuff.  It's like "logging in", but its' PHP that
 * actually does the logging in.
 *
 * Eric Myers <myers@spy-hill.net  - 21 July 2008
 * @(#) $Id: elab_login.php,v 1.16 2009/06/02 13:48:23 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general TLA utilities

handle_debug_level(); 
handle_user_level();
handle_auto_update();

recall_variable('elab_group');
recall_variable('elab_cookies');
recall_variable('SESSION');


/***********************************************************************\
 * Functions:
\***********************************************************************/


if( !function_exists('get_logged_in_user') ) {
    load_BOINC_util();
}

if( !function_exists('start_table') ) {

  // TODO: Things borrowed from BOINC can/should be factored in/out later.
  // Tables  (borrowed from BOINC):

  function start_table($extra="width=100%") {
    echo "<table border=1 cellpadding=5 $extra>";
  }

  function end_table() {
    echo "</table>\n";
  }

  function row1($x, $ncols=2, $class="heading") {
    echo "<tr><td class=$class colspan=$ncols>$x</td></tr>\n";
  }

  function row2($x, $y) {
    if ($x=="") $x="<br>";
    if ($y=="") $y="<br>";
    echo "<tr><td width=25% class='fieldname'>$x</td><td class='fieldvalue'>$y</td></tr>\n";
  }



  // Inputs:
  //
  function post_str($name, $optional=false) {
    if( !isset($_POST[$name]) ) return NULL;
    $x = $_POST[$name];
    if (!$x && !$optional) {
      error_page("missing or bad parameter: $name");
    }
    return $x;
  }


  // apply this to any user-supplied strings used in queries
  //
  function boinc_real_escape_string($x) {
    $x = str_replace("'", "\'", $x);
    $x = str_replace("\"", "\\\"", $x);
    //        $x = htmlentities($x);


    return $x;
  }

  // Process user-supplied text prior to using in query;
  // trims whitespace and escapes quotes.
  // Does NOT remove HTML tags.
  //
  function process_user_text($value) {
    $value = trim($value);
    if (get_magic_quotes_gpc()) {
      $value = stripslashes($value);
    }
    return boinc_real_escape_string($value);
  }
}


/***********************************************************************\
 * Action:
\***********************************************************************/

// From whence we came.  If it's one of the "login" pages then we
// don't need to remember it as a destination.
//
$came_from = basename($_SERVER['HTTP_REFERER']);

if( $came_from == "auth_required.php"  ||
    $came_from == "index.php"          ||
    $came_from == "elab_login.php"     ||
    $came_from == "login.php" ){		// THEN...
    $came_from="";
 }

if( !empty($came_from) ){
    debug_msg(2, "elab_login: Refered here by  $came_from ");
}

// Where do we go after the login?
//
$next_url = get_destination();
$next_url = fill_in_url($next_url);  


// If nothing specified, pick a reasonable default
//
if( !isset($next_url) || empty($next_url) ) {
    $next_url=fill_in_url($this_dir."/index.php");
    debug_msg(2,"Destination URL: $next_url");
 }

if( !empty($next_url) && !empty($came_from) ){
    add_message("The functionality that you have requested requires 
       that you authorize Bluestone to access your e-Lab group account.",
                MSG_ERROR);
 }


// Debugging: always logout and login again.

if( $debug_level > 1 ){
  debug_msg(3, "Logout first.");
  elab_logout();
}


/**
 * Handle info posted to the form
 */

if( isset($_POST['cancel']) ){
    header("Location: $next_url");
    exit(0);
 }


  // TODO: more careful input buffering required here.
$user = strtolower(process_user_text(post_str("user", true)));
$pass = trim(post_str("pass", true));


// Check for  [ Logout ] button
//
if( isset($_POST['logout']) ){
    elab_logout();
 }


// Check for  [ Login ]  button
//
if( isset($_POST['login']) ){

    $authenticated = FALSE;
    $authenticated = elab_login($user, $pass);

    if( !$authenticated ){
        add_message("Login failed.", MSG_ERROR);
    }
    else {
        add_message("Login successful.", MSG_GOOD);
        add_message("Research group: $elab_group" );
        remember_variable('elab_group');
        remember_variable('elab_cookies');

	// Setting e-Lab session cookie in user's broswer 
	// will let them in without further hindrance
	$AuthCookie = $elab_cookies[$elab];
	setcookie( $AuthCookie['Name'], $AuthCookie['Value'], 0 , "/");
    }
 }


// Check that we are already logged in
//
if( !empty($elab_cookies['ligo']) && !empty($elab_group) ){
    debug_msg(2, "Already logged in as $elab_group. Jumping onward...");
    Header("Location: $next_url");
}



/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="e-Lab Authentication";
html_begin($title);
title_bar($title);

debug_msg(5,"elab_cookies: <pre>". print_r($elab_cookies,true)."</pre>");

controls_begin();

start_table();

row1("<b>LIGO e-Lab authentication:</b><br>
       Please tell use the name of your e-Lab research group, and
	the group password.  Bluestone will use this to save files
	for your group.");
row2("Research Group Name:",
     "<input name='user' size='16' value='$user'> ");

row2("Group Password:  <!--<br>
      <font size=-2><a href='/get_passwd.php'>Forgot password?</a></font>-->",
     "<input type='password' name='pass' size='16' value='$pass'>");


if( $debug_level>1 && !empty($came_from) ){
    row2("Refered by", $came_from);
 }
if( $debug_level>1 && !empty($next_url) ){
    row2("Next destination", $next_url);
 }


$x  = "<input type='submit' name='login' value='Authorize'> ";
$x .= "<input type='submit' name='cancel' value='Cancel'> ";
if( $debug_level > 2){
    $x .= "<input type='submit' name='logout' value='De-authorize'>";
 }
row2("", $x);

end_table();

// Hidden variables to pass along
//
echo "
        <input type='hidden' name='project' value='ligo'>
        <input type='hidden' name='next_url' value='$next_url'>
        <input type='hidden' name='prevPage' value='../home/login-redir.jsp'>
        ";

// if JavaScript is enabled then jump to e-mail address field
echo "
        <script> document.login.email_addr.focus(); </script>
    ";

if( is_test_client() ){
    controls_end();
 }
 else {
     echo "</TD></TR></TABLE></div>\n"; // end of entire control box
 }


/*******************************
 * DONE:
 */

remember_variable('elab_group');
remember_variable('elab_cookies');

tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: elab_login.php,v 1.16 2009/06/02 13:48:23 myers Exp $";
?>
