<?php
/***********************************************************************\
 * include/util.php - general utilities, separate from BOINC html/inc/util.php 
 *
 * @(#) $Id: util.php,v 1.4 2007/11/26 19:34:53 myers Exp $
\***********************************************************************/


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
