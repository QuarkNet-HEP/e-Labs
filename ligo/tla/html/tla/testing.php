<?php
/***********************************************************************\
 * Test display page
 *
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: testing.php,v 1.14 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general utilities

check_authentication();
handle_reset();
handle_user_level();
handle_debug_level();
handle_auto_update();

$this_step = update_step('main_steps');


/***********************************************************************\
 * Action: (no output allowed until we begin page, below)
\***********************************************************************/

$Nsteps = sizeof($main_steps);

$self = $_SERVER['PHP_SELF'];

if( $new = get_posted('new_step') ) {
  $this_step=$new;
  remember_variable('this_step');  
}

if( $x = get_posted('reset_steps') ){
    add_message("reset_steps was pushed");
    unset($main_steps);
    main_steps_init();
 }




/**********
add_message("<b> MESSAGE BOX</b><P>
         Somewhere on <em>every</em> page we need a
        'message box' like this to display      
        status messages and feedback to the user.  It should be
        more visible than just the bottom of the DTT window.
        It may be empty, but for beginners at least it should
        be more verbose and helpful.  The background color
        or text color canchange to indicate status.
        ");
*******/



/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="TLA Testing Page";
html_begin($title);
title_bar($title);

//show_message_area();

echo "<H2> Manual Controls </h2>\n      ";
 

// Current step

echo "Current Step: " .$this_step. " - Change it: 
        ";

for($i=1; $i<=$Nsteps; $i++){
  $opt_ray[$i] = "$i) ".$main_steps[$i]->label;
}
echo auto_select_from_array('new_step', $opt_ray, $this_step);


// Debug level:

echo select_debug_level();
echo "($debug_level) \n ";
echo is_test_client() ? "&pi;" : "";


// Auto update

recall_variable('auto_update');

echo "<P> Auto-update: ";
echo ( $auto_update=='on') ? " ON " : " OFF ";
echo " ( $auto_update ) \n";
auto_update_control();
echo "&gt;" . get_posted("auto_update_posted") ."&lt; <P>";


/***
 * Message Area
 */

show_message_area();

/**
 *  POST multiple names test
 */ 

echo "
        <input type='hidden' name='metadata' value='var1 str test string 1'>
        <input type='hidden' name='metadata' value='var2 str test string 2'>
         <input type='hidden' name='metadata' value='var3 str test string 3'>
";


/**
 * LIST OF STEPS
 */

echo "<P><hr>\n\n";

echo "<h2>List The Steps</h2>
        There are $Nsteps steps.  We are on step $this_step.
        ";

echo "<input type='submit' name='reset_steps' value='Reset Steps'>\n";

echo "\n<P>\n\n";


for( $i=1; $i <= $Nsteps ; $i++){
  $s = $main_steps[$i];
  if($i == $this_step) echo "<font color='ORANGE'>\n";
  echo "<br>Step $i) $s->label \n";

  switch($s->status){
  case STEP_NEW:
    echo "[NEW]";
    break;
  case STEP_DONE:
    echo "[DONE]";
    break;
  case STEP_FAIL:
    echo "[FAILED]";
    break;
  }

echo " Go: <a href='$s->url'>$s->url</a>
        <br>&nbsp;&nbsp;  $s->description
          ";

  if($i == $this_step) echo "</font>\n";
 }

echo "<hr>\n\n";


/** 
 * testing mod_unique_id.so
 */

$uniq = getenv('UNIQUE_ID');
if( empty($uniq) ) {
    echo "Unique ID not available.";
 }
 else {
     echo "Unique request ID: $uniq";
 }


/**
 * Show the contents of one of the global arrays 
 */

function show_global_array($name){
  if (isset($name)){
     echo "\n<pre>\n";
     foreach($name as $key=>$value){
       echo "$key => ". print_r($value,true). "<br>\n";
     }
     echo "\n</pre>\n";

   }
   else {
     echo "<p>No " .$$name. " variables</p>\n";
   }

}


/**
 * TESTING: show HTTP authentication
 */

echo "<h2>HTTP Authentication</h2>
        <blockquote><tt>
 User: ".$_SERVER['PHP_AUTH_USER']." / ".$_SESSION['PHP_AUTH_USER']."<br/>
 Type: ".$_SERVER['AUTH_TYPE']." / ".$_SESSION['AUTH_TYPE']." <br/>
 Pass: ".$_SERVER['PHP_AUTH_PW']." / ".$_SESSION['PHP_AUTH_PW']." <br/>
       </tt></blockquote>
        ";


/**
 * TESTING: show _POST variables
 */

echo "<h2>_POST</h2>
        These values were passed to this script as input 
        from a form (probably from ". $_SERVER['HTTP_REFERER']. ")
        <P>\n";
show_global_array($_POST);


echo "<h2>HTTP_RAW_POST_DATA</h2>
        The _HTTP_RAW_POST_DATA array contains the raw post data
        <P>\n";
echo "<pre>" . print_r($HTTP_RAW_POST_DATA,true) . "</pre>\n";



echo "<h2>php://input</h2>
        The php://input array contains the raw post data
        <P>\n";
echo "<tt><pre>" . readfile("php://input") . "</pre></tt>\n";


/**
 *  TESTING: show _REQUEST
 */

echo "<h2>_REQUEST</h2>
        The _REQUEST array contains _POST, _GET, and cookies
        <P>\n";
show_global_array($_REQUEST);




/****************
echo "<h2>Headers</h2>
        The current request included the following headers:
        <P><code><pre>\n";
$list= http_get_request_headers();
foreach( $list as $line ){
    echo "$line\n";
}
echo "\n</code></pre>\n";
******************/


/**
 *   Cookies
 */

echo "<h2>_COOKIE</h2>
        These are cookies available in         the user's session.
        <P>\n";
show_global_array($_COOKIE);


/**
 * TESTING: show _SESSION variables
 */

echo "<h2>_SESSION</h2>
        These values are persistent throughout the life of 
        the user's session.
        <P>\n";
show_global_array($_SESSION);


/**
 * RESET button:
 */

echo "<h2>RESET SESSION</h2>
       <input type='submit' name='reset_session' value='Start Over'>
        ";

/**
 * TESTING: show GLOBALS variables
 */

if($debug_level > 5){

  echo "<h2>GLOBALS</h2>
          These values are common to all PHP components during
          this single exchange:
          <P>\n";
  show_global_array($GLOBALS);

 }

remember_variable('debug_level');

tool_footer();
html_end();

?>
