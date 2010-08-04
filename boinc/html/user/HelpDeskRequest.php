<?php
/***********************************************************************\
 * Submit a Help Desk Request (perhaps to report a bug)
 *
 * Solicits information sufficient to describe a bug or other problem
 * Sends to both the HelpDesk forum and a mailing list.
 *
 * This is a self-submitting form, containing both the Display of the 
 * form (last) and the action to process the form inputs. 
 *
 * Certain parts of the form will only show for a particular e-lab.  This
 * is controlled by CSS class.  So for example, items of class 'cosmics_elab'
 * are only visible if the user has selected the "cosmic" e-lab.
 * The mechanism for this is quite general, so apply as needed.
 *
 * Eric Myers <myers@spy-hill.net> - 5 March 2008
 * @(#) $Id: HelpDeskRequest.php,v 1.28 2009/07/08 16:25:36 myers Exp $
\***********************************************************************/

// These things are borrowed from the BOINC forum code.
//
include_once("../inc/db.inc");          // database access, for user info
include_once("../inc/db_forum.inc");    // for posting to forums
include_once("../inc/email.inc");       // for sending e-mail
include_once("../inc/util.inc");        // general utility functions

// These things are add-ons beyond BOINC (and may be similar to Bluestone)
//
include_once("../include/util.php");      // general utility functions
include_once("../include/debug.php");     // debugging messages

include_once("../project/roles.php");     // for user permissions 


/*******************************
 * Configuration: adjust as needed
 */
set_debug_level(0);

// List of addresses to send to (comma separated):
//
$Email_List = "help@i2u2.org"; /*hategan@mcs.anl.gov, myers@fnal.gov"; */


// Return address for e-mail sent from this form:
//
$Email_From = "help@i2u2.org";

// BCC the following people 
//
$Email_BCC = "phongn@fnal.gov"; 

/********
 * Lists for input selectors:
 */

$elab_list=array('any' => 'Any/All',
		 'cosmic' => 'Cosmic Rays',
		 'cms' =>'CMS',
		 'ligo' => 'LIGO',
		 'adler' => 'Adler iLab');

// TODO: This will become a list of checkboxes, possibly each with
// it's own class, to allow us to control visibility.

$part_list = array('Unknown',   // remove this one?  add "all/several"?
                   'DAQ Hardware', 'Data Upload',   // mainly Cosmics
                   'Data Preparation',              // mainly LIGO    
                   'Network', 'Data Analysis Tool', 'Posters', 'Logbook',
                   'Web server', 'Documentation');

$severity_list = array( "Undetermined", "Trivial", "Minor", "Normal",
	       "Major", "Critical", "Enhancement", "Feedback" ); 

$platform_list = array('Windows', 'MacOS X', 'Linux', 'Solaris', 'HP',
                       'Other', 'All/Any', 'None');

$browser_list= array('Internet Explorer', 'Firefox', 'Safari', 
                     'Opera', 'Seamonkey', 'Other', 'All/Any', 'None');

// What choices does the user have to identify their position or role
//
$role_list=array('Student', 'Teacher', 'QuarkNet Fellow',
                 'QuarkNet Staff', 'Developer', 'Other', 'None');

// Where to post the report.  For each e-lab, by name, we associate a
// help desk forum, by numerical id.
//
$elab_forum_id= array('any' => 52,
                      'cosmic' => 57,
	              'cms' => 60,
                      'ligo' => 58);  

// For testing.  If the server name contains "spy-hill" 
// then only send to Eric.  Other variations are possible. 
//
if( strpos($_SERVER['SERVER_NAME'], "spy-hill" ) ){
  $Email_List = "myers@spy-hill.net";
  $Email_From = "i2u2@spy-hill.net";
 }

/* End of configuration. 
\***********************************************************************/


$self = $_SERVER['PHP_SELF'];                           // who we are (path only)
$my_url = "http://" . $_SERVER['SERVER_NAME'] . $self;  // this form (full URL)
$referer = $_SERVER['HTTP_REFERER'];                 // from whence we came (full URL)
$user_agent = $_SERVER['HTTP_USER_AGENT'];           // User's browser


$input_error=array();           // empty means no errors (yet)


/*********************************************
 * Tekoa proxy redirect.  OLD STUFF
 *  If the remote address of the visitor is the IP address of tekoa
 * then we are being accessed via a reverse proxy.   Instead of
 * another set of keys, we just send the user to i2u2.org
if( $_SERVER["REMOTE_ADDR"] == "198.129.208.188" ){
    header("Location: http://www.i2u2.org/".$self);
    exit;
 }
*************************************************/




//
/*******************************
 * reCAPTCHA: so we know it is humans.  
 * We only present a reCAPTCHA for users who are not already logged in.
 */

require_once("../include/recaptchalib.php");  


// The keys are kept in these separate files instead of
// in the source code because the source code may be publicly
// available via SVN or CVS.  Please keep it that way!
// These are (for now) the Spy Hill keys.
//
$pub_key_file = "../../keys/reCAPTCHA_public_key";
$priv_key_file = "../../keys/reCAPTCHA_private_key";


// If the server name contains i2u2.org then we need 
// to use the keys for i2u2.org, not spy-hill.net. 
//
if( strpos($_SERVER['SERVER_NAME'], "i2u2.org" ) ){
  $pub_key_file = "../../keys/www13.reCAPTCHA_public_key";
  $priv_key_file = "../../keys/www13.reCAPTCHA_private_key";
  $mailhide_pub_key_file  = "../../keys/reCAPTCHA_Mailhide_public_key";
  $mailhide_priv_key_file = "../../keys/reCAPTCHA_Mailhide_private_key"; 
}


// Verify the keys exist and are usable
//
if( !file_exists($pub_key_file) || !file_exists($priv_key_file) ||
    !file_exists($mailhide_priv_key_file) || !file_exists($mailhide_pub_key_file) ) {
    error_page("Server configuration error. Cannot access keys.   
        Please report this to the project administrators.");
 }

$public_key = file_get_contents($pub_key_file);
$private_key = file_get_contents($priv_key_file);
$mailhide_public_key = trim(file_get_contents($mailhide_pub_key_file));
$mailhide_private_key = trim(file_get_contents($mailhide_priv_key_file));

if( empty($public_key) || empty($private_key) ){
    error_page("Server configuration error. Empty key.
        Please report this to the project administrators.");
 }


//
/*******************************
 * Local functions:
 *   (some of these will move to ../include/util.php when finished)
 */

// Get a value for an input variable, via POST.
//
function grab_input($name){
    if( isset($_POST[$name]) ){
        global $$name;
        $$name = trim($_POST[$name]);
        //TODO: any further cleansing?
    }
}


// Display a checkbox item with given internal $name,
// labeled by $text.  Optional $desc is for mouseover or 
// is shown to 'beginners'.
//
function checkbox_item($name,$text,$desc='',$class=''){
    global $$name;
    $checked = ( $$name ) ? "CHECKED" : " ";  // already set
    $x = "<span title='$desc' class='$class' >";
    $x .= "<input type='checkbox' name='$name' value='x' 
           onChange='updateClassVisibility()' $checked >";
    $x .= "&nbsp;$text </span>&nbsp;&nbsp;\n";
    return $x;
}


// Handle the input from a checkbox, treated as Boolean
//
function handle_checkbox($name){
    global $$name;

    if( isset($_POST[$name]) ){
        $$name = TRUE;
    }
    else {
        $$name = FALSE;
    }
}


// Report Checkbox state, if set
// 
function report_checkbox_item($name,$text,$marker='x'){
    global $$name;
    $x="";
    if( $$name ) {
        $x = "   $text" .": ".$marker."\n";
    }
    return $x;
}
  


// Get a default value set in the URL (i.e. via GET)
// Here $tag is a shorthand name for variable $name.
// But you can also use the full name
//
function get_default($name, $tag=''){
    global $$name;

    if( !empty($tag) ){ // first try by short 'tag'
        if( isset($_GET[$tag]) ){
            $$name = trim($_GET[$tag]);
            debug_msg(3,"set $name to '".$$name."' from URL");
        }
    }
    if( isset($_GET[$name]) ){ // then try by full variable name
        $$name = trim($_GET[$name]);
        debug_msg(3,"set $name to '".$$name."' from URL");
    }
}


// Generate error text for a particular condition (the $name),
// for use in prompting users to correct the condition.
// But only if that error has been set in the $input_error array.
//
function error_text($name){
    global $input_error;

    // It's not an error if user has not yet pressed "Submit"
    //
    if( !isset($_POST['submit_report']) ) return '';

    // It's not an error if item doesn't exist in list
    //
    if( !array_key_exists($name, $input_error) ) return '';
    if( empty($input_error[$name]) ) return ''; 

    $text='';

    switch($name){
    case 'summary':
    case 'subject':
        $text="Please supply a subject (summary).";
        break; 
    case 'activity':
        $text="Please tell us what you were doing at the time.";
        break; 
    case 'problem':
        $text="Please describe how to reproduce the problem.";
        break; 
    case 'user_name':
        $text="Please supply your name.";
        break; 
    case 'user_role':
        $text="Please indicate your role in I2U2.  ";
        break; 
    case 'return_address':
        $text="Please supply an e-mail address, so that we can contact you
                if needed.";
        break; 
    case 'invalid_addr':
        $text="Please supply a VALID e-mail address.";
        break; 

    case 'recaptcha':
        $text="Incorrect answer.<br/>Please try again.";
        break; 
    case 'noverify':
        $text="Please enter an answer. ";
        break; 
    }

    // It's not an error if it wasn't found above
    //
    if( empty($text) ) return '';

    return "<br/><font color='RED'>$text</font>\n";
}


// If variable named by $name is empty then mark it in the error list.
//
function require_field($name){
    global $input_error;
    global $$name;
    if( empty($$name) ) $input_error[$name]++;
}

function req($text='*'){  // emit marker for required fields
    return;
    return "<font color='RED'>$text</font>";
}



// generate a "select" element from an array of values
// THIS SHOULD BE IN ../include/util.php  but maybe not?
//
if( !function_exists('selector_from_array') ) {// in case another

    function selector_from_array($name, $array, $selection, $onChange='') {
        $out = "\n<select name=\"$name\" ";
        if(!empty($onChange)) {
	  $out .= " onChange=\"$onChange\" ";
        }
        $out .= ">";

        foreach ($array as $key => $value) {
            $out.= "\n<option ";
            if ($key == $selection) {
                $out.= "selected ";
            }
            $out.= "value=\"". $key. "\">". $value. "</option>";
        }
        $out.= "\n</select>\n";
        return $out;
    }
 }


// Time buttons:  insert a time automatically into the date/time field
//     at the push of a button.  Requires JavaScript.

// Use setup_time_button() once on a page to define insertTime(dt).
//
function setup_time_button(){
    echo "\n\n<script type=\"text/javascript\">
    function insertTime(dt){
       d = new Date;
       d.setDate(d.getDate()+dt);
       document.bugrpt.date_time.value= d.toUTCString()
    }\n</script>\n\n";
}


// Use time_button() to create a button with lable $label
// to insert time now()-$dt into the form field.
//
function time_button($label,$days_past=0){
    return "<input name='now'  type='button' value='$label'
                onClick='insertTime($days_past)'>\n";
}


// Referer buttons:  insert the referer URL, if there is one,
//     at the push of a button.  Requires JavaScript.

// Use setup_referer_button() to create the button to do the insert
// If there are arguments in the URL (GET method) then immediately
// insert the referer
//
//
function setup_referer_button(){
    global $referer, $my_url;
    if( empty($referer) ) return;

    //TODO: fix this to strip out any _GET parameters
    if( $referer == $my_url ) return;
    debug_msg(1,"referer: $referer, while my_url is $my_url");

    echo "\n\n<script type=\"text/javascript\">
    function insertRefererURL(){
       document.bugrpt.url.value=\"$referer\";
    };\n</script>\n\n";
}


// Use referer() to create a button with lable $label
// to insert the referer URL, if there is one.
//
function use_referer_button($label){
    global $referer, $my_url;
    if( empty($referer) ) return;
    if( !empty($_GET) ) return;
    if( $referer == $my_url ) return;
    debug_msg(1,"referer: $referer, while my_url is $my_url");

    return "<input name='now'  type='button' value='$label'
                onClick='insertRefererURL()'>\n\n";
}


// Control the visibility of particular items, based on CSS class
//
// 
function setup_visibility(){
  echo "\n\n<script type=\"text/javascript\">
    function getElementsByClassName(class_name) {
        var classElements = new Array();
        var pattern = new RegExp(\"(^|\\s)\"+class_name+\"(\\b|$)\");
        var list = document.getElementsByTagName('*');
        for (var i = 0; i < list.length; i++) {
          var classes = list[i].className;
          if(pattern.test(classes))  classElements.push(list[i]);
        }
        return classElements;
    };

    function setClassVisibility(class_name,isOn){
        var items = getElementsByClassName(class_name); 
        for (var i=0; i<items.length; i++){
            if(isOn) {
            	items[i].style.visibility = \"visible\";
            	items[i].style.display = \"\"; 
            }
            else {
            	items[i].style.visibility = \"collapse\";
            	items[i].style.display = \"none\";
            }
        }    
    };

    function makeClassVisible(class_name){
        var items = getElementsByClassName(class_name); 
        for (var i=0; i<items.length; i++){
			items[i].style.visibility = \"visible\";
            items[i].style.display = \"\"; 
        }    
    };

    function makeClassInvisible(class_name){
        var items = getElementsByClassName(class_name); 
        for (var i=0; i<items.length; i++){
        	items[i].style.visibility = \"collapse\";
            items[i].style.display = \"none\";
        }    
    };

    function updateClassVisibility(){
          setClassVisibility(\"cosmics_elab\",  "
                ."(document.bugrpt.elab.value==\"cosmic\") );
          setClassVisibility(\"ligo_elab\",  "
                ."(document.bugrpt.elab.value==\"ligo\") );
          setClassVisibility(\"cms_elab\",  "
                ."(document.bugrpt.elab.value==\"cms\") );
    };
   \n</script>\n\n";
}


// Construct body of report, suitable for either email or forums
//
function fill_in_report($body=''){
    global $subject, $activity, $problem, $error_msg, $workaround;
    global $elab, $elab_list, $daq_card;
    global $component, $part_list, $version, $url, $severity; 
    global $platform_os, $browser, $os_version, $browser_version;
    global $user_name, $user_id, $user_role, $role_list, $return_address;
    global $school, $location, $date_time;

    $body .= "Summary: $subject\n\n";

    // Who made the report?  (See below where we mask this for posting)

    $body .= "Submitted by: $user_name ";
    if($return_address) $body .= "<$return_address> ";
    if($user_role) $body .= "\n   (Role: ".$user_role.") ";
    if($user_id) $body .= "User# $user_id ";
    $body .= "\n";

    if($school) $body .= "School: $school\n";
    if($location) $body .= "Location: $location\n";

    if($date_time) $body .= "Date/Time: $date_time \n";

    echo "\n";

    if($elab){
        $body .= "Elab: ".$elab."\n"; 
    }
    if($severity) $body .= "Severity: $severity\n";

    if($url) $body .= "URL: $url\n";
    if($component){
        $body .= "Component: ".$component."\n"; 
    }
    if($daq_card) $body .= "DAQ Card #: $daq_card\n";
    if($platform_os) $body .= "Platform OS: $platform_os $os_version \n";

    if($browser) $body .= "Browser: $browser $browser_version\n";

    $body .= "\nActivity:\n====================\n";
    $body .= wordwrap($activity)."\n\n";

    $body .= "\nProblem Description:\n====================\n";
    $body .= wordwrap($problem)."\n\n";


    if( $elab == "Cosmic Rays"){
        global $daq_other;
        $body .= "\nCRMD Hardware Component:\n====================\n"
            .report_checkbox_item('ck_daq_gps',"GPS")
            .report_checkbox_item('ck_daq_daq',"DAQ")
            .report_checkbox_item('ck_daq_pmt',"PMT")
            .report_checkbox_item('ck_daq_pmt',"PDU")
            .report_checkbox_item('ck_daq_count',"Counters")
            .report_checkbox_item('ck_daq_cable',"Cables")
            .report_checkbox_item('ck_daq_other',"Other: $daq_other ")
            ."\n";
    }

    if( $elab == "LIGO"){
        global $GPS_start_time, $GPS_end_time, $channel_list;

        if( $channel_list ){
            $body .= "Channels: $channel_list \n";
        }
        if( $GPS_start_time || $GPS_end_time ){
            $body .= "\nGPS time interval: $GPS_start_time to $GPS_end_time\n";
        }
    }


    $body .= "\nError Messages:\n===============\n";
    if($error_msg){
        $body .= wordwrap($error_msg)."\n\n";
    }
    else{
        $body .= "(No error output was included in the report)\n\n";
    }

    $body .= "\nWorkaround/Resolution:\n====================\n";
    if($workaround){
        $body .= wordwrap($workaround)."\n\n";
    }
    else{
        $body .= "(None offered)\n\n";
    }

    return $body;
}


function form_item($title, $description, $content, $class=''){
    if (empty($title)) $title="&nbsp;";
    if (empty($description)) $descriptoin="&nbsp;";
    if (empty($content)) $content="&nbsp;";
    if($class) echo "<tr class='$class'>";
    else echo "<tr>";
    echo "<td width='25%' class='fieldname'><b>$title</b><br/>
                <span class='description'>$description</span></td>
              <td class='fieldvalue'>$content</td></tr>\n";
    //
    //TODO: save it all up and return a value
    //return $x;
}


/***
 * Send the report via e-mail.
 * Send a copy to the return address, but only for a logged-in user.
 */

function send_report_via_email($thread_id=0){
    global $logged_in_user, $my_url;
    global $Email_List, $Email_From, $Email_BCC;
    global $subject, $problem, $error_msg;
    global $elab, $elab_list;
    global $user_name, $user_id, $user_role, $role_list, $return_address;
   
    $to_address = $Email_List;

    $self = $_SERVER['PHP_SELF'];

    $headers  = "From: $Email_From \n";
    $headers .= "Client-IP: " .$_SERVER['REMOTE_ADDR']."\n";
	$headers .= "BCC: " .$Email_BCC."\n";

    if( !empty($user_name) && $user_id > 0 ) {
        $body .= "User '$user_name' (id# $user_id)";
    }
    else {
        $body = "Somebody";
    }

    $body .= " used the form at \n  $my_url \n"
        . "to submit the Help Desk request reproduced below";

    if($thread_id > 0) {
      $thread_url="http://" . $_SERVER['SERVER_NAME'].
	"/forum_thread.php?id=". $thread_id;
      $body .=  ", which you can view at \n  $thread_url\n\n";
    }
    else {
      $body .= ":\n\n";
    }

    $body .= "================================================\n";


    $body .= fill_in_report();

    // return address info?
    //
    if( !empty($return_address) && is_valid_email_addr($return_address) ) {
        if( $logged_in_user ){  // only if this is a logged-in user
            $to_address .= ", $return_address\n";
        }
        $headers .= "Reply-to: $return_address\n";
        $body .= "====\nSubmitter's return address: $return_address\n"
            . "Replying to this message will send a response to that address.\n";
    }
    elseif( !empty($return_address) ){
        $body .= "====\nAn invalid return address was provided: $return_address\n";
        $body .= "Submitter's IP Address: ".$_SERVER['REMOTE_ADDR']."\n";
    }
    else {
        $body .= "====\nNo return address was provided.\n";    
        $body .= "Submitter's IP Address: ".$_SERVER['REMOTE_ADDR']."\n";
    }

    $x = mail($to_address,  "[bugrpt] ".$subject, $body, $headers);

    $body .= "\nReport mailed to e-mail list\n";
    return $x;
}



/***
 * Post the bug report to the HelpDesk forum 
 * Return value is the $thread_id of the posting, which can be used
 * to build a URL, or 0 on failure.
 */

  function post_report_to_helpdesk(){
    global $logged_in_user;
    global $subject, $problem, $error_msg;
    global $elab, $elab_list, $elab_forum_id, $forum_id;
    global $user_name, $user_role, $role_list, $return_address;
    global $mailhide_public_key, $mailhide_private_key;

    if( !array_key_exists($elab,$elab_forum_id) ) {
      debug_msg(1,"Cannot find forum_id for e-Lab $elab");
      return;
    }
    $forum_id = $elab_forum_id[$elab];   // and it's global, for later

    $form_url="http://" . $_SERVER['SERVER_NAME']. "/forum_post.php?id=".
      $forum_id;

    if( $logged_in_user ) {
      $auth = $logged_in_user->authenticator;
    }
    else {
      debug_msg(2,"User not logged in, so use guest auth..");

      if(0 && $user_role=="Student"){ // student TODO: REAL ONE
	$auth="f1b25af57a295dba967175626c6236d4";
      }
      if(0 && $user_role=="Teacher"){ // teacher TODO: REAL GUEST ACCT AUTH 
	$auth="f1b25af57a295dba967175626c6236d4";
      }
      else {   // Guest User (generic)
	$auth="bc347a3a65dce517cc98a3948d1bb44a";
      }

      // Pirates@Home exception - post there not here
      // (do this after the checks above to make it override).
      //
      if( isset($_COOKIE['pirates_auth']) ){
          $form_url="http://pirates.spy-hill.net/forum_post.php?id=23";
          $auth="f1b25af57a295dba967175626c6236d4";   //Code Dwarf's account 
      }
    }


    // Get body of report, remove info which shouldn't be posted.

    $body = fill_in_report();

    /*
    $hidden_name = $user_name;
    if( !$logged_in_user )  $hidden_name = "Name-On-File";
    if( user_has_role('student') ) $hidden_name = "Name Hidden";

    $hidden_addr = preg_replace("/(.*)\@(.*)/", "....@$2", $return_address);
    $body = preg_replace("/Submitted by: (.*) \<(.*\@.*)\>/",
			 "Submitted by: $hidden_name <$hidden_addr>", $body);
    */


    $hidden_addr_url = recaptcha_mailhide_url($mailhide_public_key, $mailhide_private_key, $return_address);

    $forum_body = "[pre]".preg_replace("/Submitted by: (.*) \<(.*\@.*)\>/", 
                         "[/pre]Submitted by: [url=".$hidden_addr_url."]$1[/url][pre]", $body)."[/pre]";

    $form_fields = array('title' => "[bugrpt] $subject", 
                         'content' => "$forum_body",
                         'add_signature' => 'add_it', 
                         'postit' => 'Post'  );
    $form_files=array();
    $form_options=array( 'cookies' => array( 'auth' => $auth ) );

    debug_msg(2,"Post URL: $form_url");
    debug_msg(3,"Post subject: $subject");
    debug_msg(4,"Post body: <pre>$body</pre>");
    debug_msg(5,"Form Fields:<pre>".print_r($form_fields,true)."</pre>");
    debug_msg(6,"Form Options:<pre>".print_r($form_options,true)."</pre>");

    $response = http_post_fields($form_url, $form_fields, $form_files,
                                 $form_options ); 

    if( $response === FALSE ){
        debug_msg(1,"http_post_fields() failed! (FALSE)");
        error_log("Failed to post to HelpDesk: $form_url");
        return 0;
    }

    if( empty($response) ) {
        debug_msg(2,"Response from http_post_fields() was empty!"
        ." (but not FALSE)");
         return 0;
    }
    debug_msg(3,"Post reponse:<pre>$response</pre>");

    debug_msg(2,"Check for 302 response...");
    if( preg_match("/HTTP\/\d.\d 302 Found/", $response, $matches) ){
      debug_msg(2,"Found 302.  Try to extract the thread ID...");
      $thread_id = -1;
      if( preg_match("/Location: .*thread\.php\?id=(\d+)/", $response, $matches) ){
	$thread_id = $matches[1];
	debug_msg(2,"  ... thread ID is $thread_id");
      }
      return $thread_id;
    }

    debug_msg(2,"Check for 200 response (and save it)...");
    if(preg_match("/HTTP\/\d.\d 200 /", $response, $matches) ){
      $fh = fopen("/tmp/bug_report.log", "a");
      fwrite($fh,"\n-------------------".date('c')."-------------------\n");
      fwrite($fh, $response);
      fwrite($fh,"\n\n");
      fclose($fh);
      return 0;
    }

    return 0;
}   


//
/***********************************************************************\
 * Action: process form input, and if valid then submit report
\***********************************************************************/

// Process URL defaults via GET
//
get_default('elab');
get_default('component', 'part');  


// Process form input via POST
//
grab_input('subject');
require_field('subject');

grab_input('elab');
grab_input('daq_card');

grab_input('activity');
require_field('activity');

grab_input('url');
grab_input('component');

$browser_info=get_browser(null, true);

grab_input('platform_os');
grab_input('os_version');

if( empty($platform_os) && strpos($user_agent, "Linux") ) $platform_os = "Linux";
if( empty($platform_os) && strpos($user_agent, "Mac OS") ) $platform_os = "MacOS X";
if( empty($platform_os) && strpos($user_agent, "Windows") ) $platform_os = "Windows";

if( empty($os_version) ) $os_version=$browser_info['platform'];

grab_input('browser');
grab_input('browser_version');

if( empty($browser) && strpos($user_agent, "Firefox") ) $browser="Firefox";
if( empty($browser) && strpos($user_agent, "Safari") ) $browser="Safari";

if( empty($browser_version) ) $browser_version=$browser_info['version'];


grab_input('problem');
require_field('problem');

grab_input('error_msg');
grab_input('workaround');


// Cosmics: Checkbox DAQ hardware
//
handle_checkbox('ck_daq_gps');
handle_checkbox('ck_daq_daq');
handle_checkbox('ck_daq_pmt');
handle_checkbox('ck_daq_pmt');
handle_checkbox('ck_daq_count');
handle_checkbox('ck_daq_cable');
handle_checkbox('ck_daq_other');    // check the "other" box 
grab_input('daq_other');            // the text the someone typed
if($daq_other) $ck_daq_other=TRUE;  // is enough for us


// LIGO: GPS times and channels
//
grab_input('channel_list');
grab_input('GPS_start_time');
grab_input('GPS_end_time');


// Try to get user's name for the message, but make sure that we can 
// continue even if we can't - eg. the database server is down, or
// the person is using the form anonymously. 
//
$dbrc = db_init_aux();    // Connect to database, if we can

if( !$dbrc ){
    $logged_in_user = get_logged_in_user(FALSE);   // authentication not required

    if( $logged_in_user ){
        $user_name = $logged_in_user->name;
        debug_msg(2,"Logged in user: $user_name");
        $user_id = $logged_in_user->id;
        $return_address = $logged_in_user->email_addr;

        $user_roles = list_user_roles($logged_in_user);
        debug_msg(4,"C) User has ". sizeof($user_roles). " roles"); 
        if($user_roles){
            $user_role = array_shift($user_roles);
            debug_msg(5,"D) Choosing ". $user_role);
        }

        // BOINC "team" is used for school

        $teamid = $logged_in_user->teamid;
        if( $teamid && is_numeric($teamid) ){
            $team = lookup_team($teamid);
            $school = $team->name; 
        }

        // BOINC "country" is the person's state
        //
        $state = $logged_in_user->country;
        if( $state ) {
            $location = $state;
        }
    }
 }

grab_input('user_name');
require_field('user_name');

grab_input('user_role');


// Check for member of Pirates@Home crew, and redirect as needed

if( isset($_COOKIE['pirates_auth']) ){
    array_unshift($role_list,"Pirates@Home Volunteer Tester");
    $Email_List = "myers@spy-hill.net";
 }


grab_input('return_address');
require_field('return_address');


// If they give a return address it should be a valid e-mail address
//
if( $return_address && !is_valid_email_addr($return_address) ){
    $input_error['invalid_addr']++;
 }

grab_input('school');
grab_input('location');
grab_input('date_time');


/*******************************
 * If 'Submit' and no errors then submit the report
 */

if( isset($_POST['submit_report']) && empty($input_error) ){

    // If the person is not logged in then we need to check the CAPTCHA
    //
    if( !$logged_in_user ){
        if( empty($_POST["recaptcha_response_field"]) ){
            $input_error['noverify']++;
        }
        else {
            $resp = recaptcha_check_answer ($private_key,
                                            $_SERVER["REMOTE_ADDR"],
                                            $_POST["recaptcha_challenge_field"],
                                            $_POST["recaptcha_response_field"]);

            if( !$resp->is_valid ) $input_error['recaptcha']++;
        }
    }


    // Sumbit via e-mail and forum post 
    //
    if( empty($input_error) ){

        page_head("Problem report submission");

        echo str_pad("<P>Processing...</P> \n", 4096);
        flush();

        $text = "";

        if( ($thread_id = post_report_to_helpdesk()) > 0 ){
            echo str_pad("<P>* Report posted to Help Desk forum.",4096);
            flush();
        }

	//DEBUG- TURN OFF EMAIL//
        if( $mailed = send_report_via_email($thread_id) ){
            echo str_pad("<P>* Report submitted via e-mail.", 4096);
            flush();
        }

        // Output status 

        if( !$mailed || $thread_id<1 ) {
            echo "<P>There was a problem submitting the report:";
            if( !$mailed ) echo "<br> * The report could not be mailed.";
            if( $thread_id<1 ) echo "<br> * The report could not be posted.";
        }

        if($mailed || $thread_id){
            echo "<p>The following report was submitted: 
                        <hr><blockquote><pre>\n";
            echo htmlspecialchars(fill_in_report());
            echo "</pre></blockquote><hr>\n\n";
        }

        if( $thread_id > 0 ) {// if posted, link to it 
            echo "<blockquote>* <a href='forum_thread.php?id=$thread_id'>
                Responses will be found in the ". $elab_list[$elab].
                " Help Desk forum...</a></blockquote>\n";          
        }

        echo "<blockquote>* <a href='".URL_BASE."'>Go to the ".PROJECT
            ." main page...</a></blockquote>\n";

        page_tail();
        exit;
    }
 }


//
/***********************************************************************\
 * Display the input form
\***********************************************************************/

// Input selectors work more easily if these arrays have the value as the index
//  (Function is from ../include/utils.php)
//
//$elab_list=array_of_values($elab_list);
$severity_list = array_of_values($severity_list);
$part_list=array_of_values($part_list);
$platform_list = array_of_values($platform_list);
$browser_list = array_of_values($browser_list);
$role_list = array_of_values($role_list);

page_head("Help Desk Request Form");

setup_time_button();
setup_referer_button();
setup_visibility();

echo " <form name='bugrpt' method='POST' action='$self'> \n";

echo "Use this form to submit a request to the Help Desk, either
        to report a problem (such as a software bug), or to 
        ask a question or to make a request. 
        <P>
        Please try to give us as much information as you can to help diagnose
        the problem or to make the nature of your request clear.
        Except for the few required fields,
        you can leave things blank if they do not apply.<P>\n";

 
if( isset($_POST['submit_report']) && !empty($input_error) ){
    echo "<font color='RED'>Please correct the problems noted below.
            <p>";

    if($debug_level > 2){
        foreach($input_error as $key=>$value){       
            echo "<tt>$key</tt>&nbsp;\n";
        }
    }
    echo "</font>\n";
 }


start_table();


row1("Please describe the problem:");

form_item("Short summary:",
          "Brief description, suitable for use as an e-mail subject line "
          .error_text('subject'),
          "<input type='text' name='subject' value='$subject'
                        size='60' maxlength='80' class='required'>");

form_item("Date/Time", 
        "When did this happen?  Being more specific can help us find
         evidence in the server logs.  Please include time zone!",
          "<input type='text' name='date_time' value='$date_time'
                                size='30' maxlength='40'>  &nbsp;"
          . time_button('Now')
          //. GPS_clock_box() . GMT_clock_box 
          );

form_item("Which e-Lab?",
          "Which at is the general area of the problem?  "
          .error_text('elab'), 
          selector_from_array('elab', $elab_list, $elab,
				"updateClassVisibility()" )
          );

form_item("Which part?",
          "What part of the e-Lab does this report apply to? "
          .error_text('component'),
          selector_from_array('component', $part_list, $component, 
				"updateClassVisibility()" )
          ."<span class='description'> 
                (This item will be changed soon to checkboxes)
           </span>"
          );

form_item("Severity",
          "How bad is this problem?  Or are you suggesting an improvment
          or giving feedback?",
          selector_from_array('severity', $severity_list, $severity)
          );

form_item("Activity:",
          "What were you doing, or trying to do, at the time of the error?  "
          .error_text('activity'),
          "<textarea name='activity' rows=10 cols=60 class='required'>$activity</textarea>"
          );


form_item("URL:", 
          "What web page address were you using when the problem occured?  ",
          "<input type='text' name='url' value='$url'
                        size='60' maxlength='255'><br/>"
          .use_referer_button('Use where I just came from')
          );

form_item("Platform:",
        "What computer operating system and browser were you using
                at the time the problem occured?",
          "Operating System: "
          .selector_from_array('platform_os', $platform_list, $platform_os)
        ." Version:"
        ."<input type='text' name='os_version' value='$os_version'
                        size='10' maxlength='15'>"
          ."<br/> Browser: &nbsp; "
          .selector_from_array('browser', $browser_list, $browser) 
        ." Version:"
          ."<input type='text' name='browser_version' value='$browser_version'
                        size='10' maxlength='15'>"
          //."<br>User_Agent:<tt> $user_agent</tt>"
          );

form_item("Problem Description:", 
        "Please describe the problem, giving enough information that we 
         can reproduce it ourselves, <br><b>or</b> state your question or request here. 
        <br>&nbsp;<br> 
         <span class='cosmics_elab'>(Example: for cosmic rays  DAQ problems
         include output from DG, DC, DT, V1 and V2 commands, 
         and short snips of raw data from ST and DS commands) </span> "
          .error_text('problem'),
       "<textarea name='problem' rows=10 cols=60 class='required'>$problem</textarea>");


// Cosmics-only items:

form_item("CRMD Hardware Component:",
          "Cosmic Rays e-Lab only.<br> If your problem is a hardware problem,
               which hardware elements are involved?",
          "<span class='description'> "
          .checkbox_item('ck_daq_gps',"GPS", "Global Positioning System")
          .checkbox_item('ck_daq_daq',"DAQ", "Data Acquisition Hardware")
          .checkbox_item('ck_daq_pmt',"PMT", "Photomultiplier")
          .checkbox_item('ck_daq_pmt',"PDU", "Power Distribution Unit")
          .checkbox_item('ck_daq_count',"Counters", "Counters")
          .checkbox_item('ck_daq_cable',"Cables", "Cabling")
          .checkbox_item('ck_daq_other',"Other:", "Please describe:")
          ."<input type='text' name='daq_other' value='$daq_other'
                        size='10' maxlength='20' >
         </span>",
        'cosmics_elab');

form_item("DAQ Card #:",
          "Cosmic Rays e-Lab only.<br> Serial number of cosmic ray data aquisition 
                (DAQ) card.  " ,
          "<input type='text' name='daq_card' value='$daq_card'
                        size='10' maxlength='15'>".
          "<span class='description'> You'll find this printed on the back
                side of the card, or run the 'H1' command.  </span>",
        'cosmics_elab');


form_item("Channel(s):",
          "LIGO e-Lab only.<br> What detector channel or channels were you using (or trying to use)?",
          "<textarea name='channel_list' rows=5 cols=60>$channel_list</textarea>",
        'ligo_elab');


form_item("Time interval:",
          "LIGO e-Lab only.<br> What time interval were you looking at?",
          "Start time:
          <input type='text' name='GPS_start_time' value='$GPS_start_time'
                        size='25'> 
          <br>
           End time:
           <input type='text' name='GPS_end_time' value='$GPS_end_time'
                        size='25'> ",
        'ligo_elab');

form_item("Network Component:",
          "For Networking problems: If your problem involves computer networking,
            please check the parts you think may be involved.",
          "<span class='description'> 
                        (checkboxes would go here)
         </span>",
        'networking_part');


// 

form_item("Error Output:",
          "Please cut-and-paste relevant error messages 
                which demonstrate the problem. ",
          "<textarea name='error_msg' rows=10 cols=60>$error_msg</textarea>");

form_item("Workaround/Resolution:", 
        "Have you found a way to work around the problem?
         Or do you have a suggestion or idea for how to solve the problem?"
          .error_text('workaround'),
          "<textarea name='workaround' rows='10' cols='60'>$workaround</textarea>");


// About submitter: only if not logged in.
//
if( !$logged_in_user ) {
    row1("Submitter information:");
    form_item("Your Name:",
              "We need to know who to contact if we need further information."
              .error_text('user_name'),
              "<input name='user_name' value='$user_name'
                        size='60' maxlength='60' class='required'>");

    form_item("E-mail address:",
              "Please give an e-mail address so that we can contact
                  you in the event we need further information."
              .error_text('return_address') 
              .error_text('invalid_addr'), 
              "<input name='return_address' value='$return_address',
                        size='30' maxlength='72' class='required'>");

    form_item("Your Role:",
              "What is your role in I2U2?"
              .error_text('user_role'),
              selector_from_array('user_role', $role_list, $user_role) );

    form_item("School:",
              "What school are you with?",
              "<input name='school' value='$school'
                        size='60' maxlength='80'>");

    form_item("Location",
              "Where are you located (city and state)?",
              "<input name='location' value='$location'
                        size='60' maxlength='255'>");

    form_item("Verification:",
              "Please enter the two words shown in the box, to prove
                that you are a human, not an automated web-bot."
              .error_text('noverify')
              .error_text('recaptcha'),
              recaptcha_get_html($public_key));
 }

form_item("Send the report:", "",
     "<input name='submit_report' type='SUBMIT' value='Submit'>");

end_table();
echo "</form>\n";


echo req("* indicates a required field");


echo "<P>
      If you would rather send an e-mail to the project administrators 
        the e-mail address is <i>  "
        .str_replace('@', "&#64;<!--,
                        -->", $Email_From ).
        "</i>.   
        Please be sure to include all of the information requested above,
        and please be aware that e-mail sent to that address may
        not immediately be added to our problem tracking system.
        </p>\n"; 


echo "\n<p style='color:grey; text-align: right;'>"
        . strtr('$Revision: 1.28 $','$',' ')      ."</p>\n\n";


// Form adjustments:  set initial visibility of sections, 
// Fill in some blanks with client-side scripting, if we can:
//
echo "\n
  <script type=\"text/javascript\">
   setClassVisibility(\"cosmics_elab\", ( \"$elab\"==\"Cosmic Rays\" ) );
   setClassVisibility(\"ligo_elab\", ( \"$elab\"==\"LIGO\" ) );
   setClassVisibility(\"cms_elab\", ( \"$elab\"==\"CMS\" ) );
   makeClassInvisible(\"networking_part\");
   updateClassVisibility();\n";

// If there are arguments in the URL (ie GET) then automatically insert 
// the refering URL
//
if( !empty($_GET) && !empty($referer) ){ 
    echo "insertRefererURL();\n";
}

echo "\n  </script>\n";

page_tail();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: HelpDeskRequest.php,v 1.28 2009/07/08 16:25:36 myers Exp $"; 
?>