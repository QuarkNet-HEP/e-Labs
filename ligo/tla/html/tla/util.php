<?php 
/***********************************************************************\
 * General PHP Utilities for the LIGO analysis tool (TLA)
 * 
 * Anything that gets too specialilzed should be moved to a separate file.
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: util.php,v 1.62 2009/04/08 19:25:49 myers Exp $
\***********************************************************************/

require_once("debug.php");         
require_once("messages.php");      


/**
 * General utiltities
 */

function memory_format($n){
    if( !is_numeric($n) ) return "???";
    $x = intval($n);
    if( $x < 1024 ) return number_format($x,2)." b";
    $x /= 1024;
    if( $x < 1024 ) return number_format($x,2)." Kb";
    $x /= 1024;
    if( $x < 1024 ) return number_format($x,2)." Mb";
    $x /= 1024;
    if( $x < 1024 ) return number_format($x,2)." Gb";
    $x /= 1024;
    if( $x < 1024 ) return number_format($x,2)." Tb";
    $x /= 1024;
    return  number_format($x,2)." Pb";
}


 
/* Is there a final destintation URL we should know about? 
 * Check several different mechanism, last one wins. 
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

  debug_msg(1,"get_destination(): $next_url");


  // If we are already there, then we are already there. 
  //
  if( $self == $next_url ){
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


// Return an array of keys to the original $array
// (Useful for selectors)
//
function array_of_keys($array){
    if( !is_array($array) ) return NULL;
    $keys = array_keys($array);
    $x = array();
    foreach($keys as $k) {
        $x[$k] = $k;
    }
    return $x;
}



/***********************************************************************\
 * Log files
\***********************************************************************/

function clear_log_files($Nplot='*'){
    $file_type=array('.log', '_err.log', '.done');
    clear_these_files($file_type,$Nplot);
}


function show_log_files($Nplot=''){
    //  $id = uniq_id($Nplot);// Ignore this to show all log entries!
    $id = uniq_id();
    $logfile = $id .".log";
    $errfile = $id ."_err.log";

    // Find slot (only if not there already)
    $slot="";
    if( basename(dirname(realpath(getcwd()))) != "slot" )
        $slot=slot_dir()."/";

    // Output Log:

    echo "<div class=\"control\">\n";
    $fn =  $slot.$logfile;
    if( file_exists($fn) ) {
        echo "<b>LOG FILE OUTPUT:</b><br>
          <TABLE width='100%' class=\"textarea\" border=\"0\">
           <TR><TD>";

        echo "<pre>\n";
        system(" /usr/bin/fold -s -w 99  $fn");
        echo "</pre>\n";

        echo "</TD></TR>\n</TABLE>\n";
    }


    // Error Log:

    $fn =  $slot. $errfile;
    if (file_exists($fn)) {
        echo "<b><font color='RED'>ERROR LOG OUTPUT:</font></b><br>
          <TABLE width='100%' class=\"textarea\" border=\"0\">
           <TR><TD>";
        echo "<pre>\n";
        system("/usr/bin/fold  -s -w 99 $fn");
        echo "</pre>\n";
        echo "</TD></TR>\n</TABLE>\n";
    }
	echo "</div>\n";
}

// TODO? handle_view_logs button?  Can you do that with headers() 
//       AND pop a new browser window, without JavaScript?


/***********************************************************************\
 * User Forms Input
\***********************************************************************/


/**
 *  get_from_array(var,array) returns the value of array['var'] 
 *  if it exists, and an empty string if it doesn't, 
 *  avoiding errors about undefined index 
 */
function get_from_array($key, $array) { 
    if( array_key_exists($key, $array) ) return $array[$key];
    return '';
}


/**
 *  get_posted(var) returns a variable from the _POST array (if it exists) 
 *  (do we need better input conditioning for security?)
 */
function get_posted($key){ 
    if( array_key_exists($key , $_POST) ) {
        //if( isset($_POST[$key]) ) 
        return $_POST[$key];
    }
    return '';
}

/**
 *  Our forms post to themselves, then possibly redirect to another page.
 *  This allows for processing only the first time.
 */

function posted_to_self(){
    $ref = get_from_array('HTTP_REFERER', $_SERVER);
    $self = "http://" . strtolower($_SERVER['SERVER_NAME']) . $_SERVER['PHP_SELF']; 
    debug_msg(8,"self: $self =?= ref: $ref");
    return ($self == $ref);
}


function default_value(&$a, $k, $v) {
	if (!array_key_exists($k, $a)) {
		$a[$k] = $v;
	}
}

/**
 * Generate a "select" element from an array of values which automaticically
 * submits itself if scripting is enabled.  Optional 4th argument is the label
 * for the submit button used if scripting is not enabled.
 * Note: result passed as returned value, so you probably want to echo it.
 */

function auto_select_from_array($name, $array, $options = NULL) {
    // 'same' means take value from variable named $name
    
	if (!is_array($options)) {
		$options = array("selection" => $options);
	}
	if (empty($array)) {
		default_value($options, "selection", "same");
	}
	else {
		default_value($options, "selection", $array[0]);
	}
	default_value($options, "inhibitEmpty", false);
	default_value($options, "changeHandler", "");
  
    if ($options["selection"] == "same") { 
        global $$name;
        if( isset($$name) ) {
            $options["selection"]=$$name;
            debug_msg(8,$name." defaults to previous value ".$$name); 
        }
    }
    debug_msg(9,$name." has ".$options["selection"]." selected.");
	
    if (empty($array) && $options["inhibitEmpty"] == true) {
    	return;
    }
    
    if ($options["changeHandler"] != "") {
    	if(strpos($options["changeHandler"], "javascript:") === false) {
    		$options["changeHandler"] = " onChange=\"".$options["changeHandler"]."('".$name."')\"";
    	}
    	else {
    		$options["changeHandler"] = " onChange=\"".$options["changeHandler"]."\"";
    	}
    }
    $out = "
      <select id=\"$name\" name=\"$name\"".$options["changeHandler"].">\n";

    if(!is_array($array) ){
        debug_msg(1, "selector $name not given an array of values.");
    }

    foreach ($array as $key => $value) {
        $out .= "        <option value='". $key. "' ";
        if ($options["selection"] == $key) {
        	$out .= " SELECTED "; 
       	}
        $out .=">". $value. "</option>\n";
    }
    $out .= "      </select>\n";
    // uncomment if you need this, but we now  have at least one submit button per form
    // $out .= "      <noscript><input type='SUBMIT' value='$button' ></noscript>\n";
    return $out;
}


function custom_controls() {
	global $custom_controls;
	
	$out = "";
	if (!$custom_controls || empty($custom_controls)) {
	    $out .= <<<END
	    	<script language="JavaScript">
	    		
	    		function radioImg(on) {
	    			if (on) {
	    				return "img/radio-on.gif";
	    			}
	    			else {
	    				return "img/radio-off.gif";
	    			}
	    		}
	    		
	    		function checkboxImg(on) {
	    			if (on) {
	    				return "img/checkbox-on.gif";
	    			}
	    			else {
	    				return "img/checkbox-off.gif";
	    			}
	    		}
	    		
	    		function radioChecked(id, index, value) {
	    			for (var i = 1; i < 10; i++) {
	    				var rimg = document.getElementById(id + i);
	    				if (rimg != null) {
	    					rimg.src = radioImg(index == i);
	    				}
	    			}
	    			var input = document.getElementById(id + "-input");
	    			if (input != null) {
	    				input.value = value;
	    			}
	    		} 
	
	    		function genRadio(name, index, on, key, value) {
	    			document.write('<a class="radio" href="javascript:radioChecked(\'' + name + 
	    				'\', ' + index + ', \'' + key + '\')"><img alt="()" id="' + name + index + 
	    				'" src="' + radioImg(on) + '"></img>' + value + '</a>\\n');
	    		}
	    		
	    		function genCheckbox(name, on, value) {
	    			//maybe I'm doing something wrong (like not using a tested lib for this)
	    			//and maybe IE is indeed silly
	    			if (navigator.appName == "Microsoft Internet Explorer" && (navigator.appVersion.indexOf("MSIE 8") != -1)) {
	    				document.write('<a href="#"></a>');
	    			}
	    			if (navigator.appName == "Opera") {
	    				document.write('<input type="checkbox" name="' + name + '" ' + (on ? 'checked="true" ' : '') + ' />' + value); 
	    			}
	    			else {
	    				var href = "javascript:checkboxClicked('" + name + "')";
	    				document.write('<a class="checkbox" href="' + href + '"><img alt="[]" id="' + 
	    					name + '" src="' + checkboxImg(on) + '"></img>' + value + '</a>\\n');
	    			}
	    		}
	    		
	    		function checkboxClicked(id) {
	    			var input = document.getElementById(id + "-input");
	    			if (input == null) {
	    				return;
	    			}
	    			var img = document.getElementById(id);
	    			if (img == null) {
	    				return;
	    			}
	    			input.checked = !input.checked;
	    			img.src = checkboxImg(input.checked);
	    		}
    	</script>
END;
		$custom_controls = true;
	}
	return $out;
}

/**
 * Generate a set of radio buttons to select one of several choices from an array 
 * of values, which automaticicallysubmits itself if scripting is enabled.
 * Note: result passed as returned value, so you probably want to echo it.
 */

function auto_buttons_from_array($name, $array, $selection='same', $vertical = false) {
    // 'same' means take value from variable named $name
  
    if( $selection=='same' ){ 
        global $$name;
        if( isset($$name) ) {
            $selection=$$name;
            debug_msg(8,$name." defaults to previous value ".$$name); 
        }
    }
    debug_msg(9,$name." has ".$selection." selected.");
    $divclass = $vertical ? "buttons-v" : "buttons";
    $sep = $vertical ? "<br />" : "&nbsp;&nbsp;";
	
    // radio buttons and CSS don't mix much
    $out = custom_controls();
	$out .= <<<END
		<script language="JavaScript">
    		document.write('<input type="hidden" id="$name-input" name="$name" value="$selection" />');
    		document.write('<div class="$divclass">');
    		
END;
	$index = 1;
    foreach ($array as $key => $value) {
    	$value = str_replace("\n", "\\n", $value);
    	$on = ($key == $selection) ? "true" : "false";
    	$out .= "genRadio(\"$name\", $index, $on, \"$key\", \"$value\");\n";
    	$out .= "document.write('$sep');\n";
    	$index++;
    }
	$out .= <<<END
			document.write('</div>');
    	</script> 
		<noscript>
			<div class="$divclass">
			
END;
    foreach ($array as $key => $value) {
    	$checked = ($key == $selection) ? "checked=\"true\"" : "";
    	$out .= <<< END
        <input class="radio" type="radio" name="$name" value="$key" $checked>$value</input>$sep\n
        	
END;
    }
    $out .= "</div></noscript>\n";
    // uncomment if you need this, but we now  have at least one submit button per form
    //  $out .= "      <noscript><input type='SUBMIT' value='$button' ></noscript>\n";
    return $out;
}

function checkbox($name, $checked, $label) {
	$chk = $checked ? "checked=\"true\"" : "";
	$on = $checked ? "true" : "false";
    $out = custom_controls();
	$out .= <<<END
		<script language="JavaScript">
    		document.write('<input type="checkbox" style="position: absolute;left: -9000px;" id="$name-input" name="$name" $chk" />');
    		genCheckbox("$name", $on, "$label");
    	</script>
    	<noscript>
    		<input class="checkbox" type="checkbox" name="$name" $chk>$value</input>
    	</noscript>
END;
	return $out;
}


/**
 * Generic routine to clear out any number of files 
 */
function clear_these_files($file_type, $Nplot='*'){
    $id0 = uniq_id();
    if($Nplot=='*')  $pat0=slot_dir()."/".$id0.$Nplot;
    else             $pat0=slot_dir()."/".$id0."_".$Nplot;
    debug_msg(5,"clear_these_files(): $pat0... ");

    foreach($file_type as $pfx){
        $pattern = $pat0.$pfx;
        $file_list=glob($pattern);
        if( !empty($file_list) ) {
            foreach($file_list as $filename){
                debug_msg(5,"clear_these_files(): unlink($filename)");
                unlink($filename);
            }
        }
    }
}

/* Specific case to clear plot files */

function clear_plot_files($Nplot='*'){
    $file_type=array('.jpg', '.png', '.svg', '.C', '.eps');
    clear_these_files($file_type,$Nplot);
}


/***********************************
 * Return a unique ID  to use for job & plot identification.
 * Each call should return a truly uniq ID which can be used to
 * distinguish a plot or data file, so that we don't have to worry
 * about browser or proxy cache settings.   
 *
 *  // THIS IS STILL WORK IN PROGRESS.  THE WAY THIS IS USED MUST CHANGE
 *  //  TO KEEP TRACK OF THE PLOT FILE CREATED WITH THIS ID //
 *  // COULD USE Apache mod_unique_id FOR THIS?
 *  // REALLY NEED TWO FUNCTIONS/ID's, one to identify user/session and the
 *         other to identify objects within those sessions.
 *
 * Ignore optional argument, it should go away!  Previous usage was that 
 * this was tacked on to the session/user ID to label the plot, but that
 * still lead to non-unique names and 
 *
 */

function uniq_id($n=''){
    global $logged_in_user;
    global $task_id;

    if( session_id()=="" ) session_start();

    if( !empty($task_id) ){// Already got one?  Use it.  NO NO NO
        $id = $task_id;
    }
    elseif( !empty($logged_in_user->id) ){ 
          $id = "U" . $logged_in_user->id;
    }
    elseif( !empty($_SESSION['PHP_AUTH_USER']) ){ // basic auth 
          $id=$_SESSION['PHP_AUTH_USER']; 
    }
    else {
        $id = 'plot';
    }

    // Tack on a digit at the end for plot_id
    //
    if( !empty($n) ) $id .= "_" . $n;
    return $id;
}



/* Return name of the 'slot' directory, which is a private workspace
 * for this PHP session.   It is created if it does not exist.
 * The top level should be group 'apache' and chmod g+rwxs to allow httpd
 * to use it. File mode 0770 allows another process in 'apache' 
 * group to clean up.  
 * 
 * The POST variable 'slot_dir' can be used to override the default slot
 * directory, but only for one which already exists and is readable.
 */

 function session_dir(){ // Old name
    debug_msg(1,"session_dir() is deprecated.  Please use slot_dir() instead.");
    return slot_dir();
}

function slot_dir(){
    global $TLA_SLOTS_DIR;

    // Start at the directory above individual slots

    $d = $TLA_SLOTS_DIR;
    if( empty($d) || !file_exists($d) || !is_dir($d)
                  || !is_readable($d) || !is_writeable($d) ){
        debug_msg(1,"Cannot find or use slots directory $d!");
        $d = __FILE__ . "/slot";   // punt relative to this file
    }

    // Allow to specify slot as part of POST.
    // (Do not allow via GET, it is a greater security risk.)
    // This one must already exist.
    //
    $s = basename(get_posted('slot_dir'));  

    if( !empty($s) ){
        $s = "$d/".$s;
        if( file_exists($s) && is_dir($s)
                            && is_readable($s) && is_writeable($s) ){
            $d=$s;
        }
    }
    else {
        $d = "$d/".session_id();  // default slot 
    }

	// The user under which the elab runs on needs to
	// be able to write to this dir. Typically, this
	// won't work with 0770.
    if( file_exists($d) && is_dir($d) ) {
        chmod($d, 0777);
        return $d;
    }
    debug_msg(1,"$d is not an existing directory");

    if( mkdir($d,0777) ) {
        chmod($d, 0777);  // seemed to be needed
        return $d;
    }
    debug_msg(1,"Could not mkdir($d,0777)");

    /* maybe we try to create it in /tmp rather than ./sess/ ? */

    $d = "/tmp/".$d;
    if( mkdir($d,0777,true) ) {
        chmod($d, 0777);  // seemed to be needed
        debug_msg(0,"Warning: Had to create slot under /tmp");
        return $d;
    }

    debug_msg(0,"Warning: Had to use /tmp as slot.");
    return "/tmp";     // punt formation!
}




/***********************************************************************\
 * Session persistence:  use these functions to save variables
 * during a session between visits to particular pages.
 */

// Make a value saved in SESSION a global variable
//
function recall_variable($name) {
    if( session_id()=="" ) session_start();

    if( isset($_SESSION[$name]) ){
        $GLOBALS[$name] = $_SESSION[$name];
        debug_msg(5, "Recalled $name from session.");
        return true;       
    }
    debug_msg(5, "Cannot recall $name from _SESSION .");
    return false;
}


// Save the value of a global variable in the SESSION
//
function remember_variable($name) {
    if( session_id()=="" ) session_start();

    //    global $$name;    
    if( isset($GLOBALS[$name]) ) {
        $_SESSION[$name] = $GLOBALS[$name];
        return true;
    }
    return false;
}



/**
 * CVS tag version.  Returns CVS Name: tag keyword, parsed into version string
 */


function cvs_tag_name(){
    return cvs_version(1);
}


function cvs_version($with_name=0){ // with or without name part?
    $tag_name = $tag_major = $tag_minor = $tag_extra = '';
    $full_tag = CVS_TAG;

    // Extract just CVS part (remove Name: and trailing $)

    $cvs_tag_pat="/Name:\s+(.*)\$/";
    $n=preg_match($cvs_tag_pat, $full_tag, $matches);
    if( $n>0 ) {
        list($all, $full_tag) = $matches;
    }

    // Parse name_MM.mm.extra
    $cvs_vers_pat="/(.+)(\d+).(\d\d)([^\$]*)/";
    $n=preg_match($cvs_vers_pat, $full_tag,$matches);
    if( $n>0){
        list($all, $tag_name, $tag_major, $tag_minor, $tag_extra) = $matches;
    }

    // Parse name_MM_mm
    $cvs_vers_pat="/(.+)_(\d+)_(\d\d)([^\$]*)/";
    $n=preg_match($cvs_vers_pat, $full_tag,$matches);
    if( $n>0 ) {
        list($all, $tag_name, $tag_major, $tag_minor, $tag_extra) = $matches;

    }

    $x = "$tag_major.$tag_minor";
    if( !empty($tag_extra) ) $x .= "$tag_extra";
    if( $with_name && !empty($tag_name) ) $x = $tag_name ." $x";
    return trim($x);
}


$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: util.php,v 1.62 2009/04/08 19:25:49 myers Exp $";
?>
