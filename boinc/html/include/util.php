<?php
/***********************************************************************\
 * include/util.php - general utilities, separate from BOINC html/inc/util.php 
 *
 * @(#) $Id: util.php,v 1.5 2009/05/29 13:14:37 myers Exp $
\***********************************************************************/


/* Is there a final destintation URL we should know about? 
 * Use several different mechanism to find out. Last one wins.
 * 
 * @uses $self
 * @uses $SESSION
 */

function get_destination(){
  global $self; 
  global $SESSION;

  $next_url="";

  // Moodle uses $SESSION->wantsurl and now we do too.
  //
  if( isset($SESSION->wantsurl) ){
    $next_url=$SESSION->wantsurl;
    debug_msg(2,"Found SESSION->wantsurl set to $next_url ");
  }

  // eLab JSP uses 'prevPage'
  //
  if( isset($_GET['prevPage']) ){
    $next_url = $_GET['prevPage'];
  }
  if( isset($_POST['prevPage']) ){
    $next_url = $_POST['prevPage'];
  }

  // BOINC uses 'next_url'
  //
  if( isset($_GET['next_url']) ){
    $next_url = $_GET['next_url'];
  }
  if( isset($_POST['next_url']) ){
    $next_url = $_POST['next_url'];
   }


  // If we came here from any .jsp page then we want to go back
  //
  $referer = $_SESSION['HTTP_REFERER'];
  $p = pathinfo($referer);
  if( $p['extension']=='jsp' ) $next_url = $referer;

  debug_msg(1,"get_destination(): $next_url");


  // If we are already there, then we are already there. 
  //
  if( $next_url && $self == $next_url ){
    $next_url="";
    debug_msg(1, "We are already there: $self ");
    if( $SESSION->wantsurl ) unset($_SESSION["SESSION"]->wantsurl);
  }
  return $next_url;
}




/* Set our desired final destination, even as we wander around
 * our little web...
 *
 * @uses $SESSION
 * @uses $self
 */

function set_destination($next_url){
  global $self; 
  global $SESSION;

  debug_msg(3,"set_destination($next_url)");

  if( !$next_url) return FALSE; 

  // If we are already there, then we are already there. 
  //
  if( $next_url === $self ){
    $next_url="";
    if( $SESSION->wantsurl ) unset($SESSION->wantsurl);
    debug_msg(1, "We are already there: $self ");
  }
  else {
    $SESSION->wantsurl = $next_url;
  }
  remember_variable('SESSION');	// be sure it's saved
}



/* Fill in host and path parts of URL 
 * (BUG! ignores query part)
 */

function fill_in_url($url){
    if( empty($url) ) return "";

    debug_msg(1,"fill_in_url($url)...");

    $dest_parts = parse_url($url);
    $host = $dest_parts['host'];
    $host = empty($host) ? $_SERVER['SERVER_NAME'] : $host;

    $path = $dest_parts['path'];
    $path = empty($path) ? dirname($_SERVER['REQUEST_URI']) : $path;
    if( strpos($path,'/') !==0 ) $path = '/'.$path;

    $url = 'http://'.$host.$path;

    $query = $dest_parts['query'];  
    if($query) $url .= "?$query";

    debug_msg(1,"filled-in URL: $url");
    return  $url;
}







/**
 * Add to a list of error messages which will show when a 
 * an error_page() is rendered.
 */

function error_msg($text){
    global $error_message_list;
    $error_message_list[] = $text;
}


function show_error_messages(){
    global $error_message_list;
    if( empty($error_message_list) ) return; 

    echo "<p class='err_msg'><font color='RED'><pre>\n" ;

    foreach($error_message_list as $key => $line){
        echo "$line\n";
        unset($error_message_list[$key]);
    }
    echo "</pre></font></p>\n";   
}


function clear_error_messages(){
    global $error_message_list;
    $error_message_list=array();
}

clear_error_messages();



/**
 * Generate a "select" element from an array of values 
 * which automaticically submits itself if scripting is enabled.
 * Optional 4th argument is the label for a submit button which is shown if
 * scripting is turned off, as long as it is defined.
 */

if( !function_exists('auto_select_from_array') ) {// in case another

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
 else {
     debug_msg(6,"auto_select_from_array() already defined.");
 }






/**
 * return an array where the values are the keys, for use in a selector
 */


if( !function_exists('array_of_values') ) {// in case another

    function array_of_values($a) {
        $r=array();
        foreach($a as $value){
            $r[$value]=$value;
        }
        return $r;
    }
 }
 else {
     debug_msg(6,"array_of_values() already defined.");
 }

?>
