<?php 
/***********************************************************************\
 * e-Lab interface
 *
 * The origional e-Lab system is written in JSP and runs on a Tomcat 
 * server.  Bluestone is written in PHP, and runs on an Apache server.
 * Rather than requiring a complete re-write of one or the other, we
 * have come up with an interface between the two, based on HTTP POST
 * using (on the PHP side) the PECL extension pecl_http.
 *
 * This file provides the interal workings for the interface with the 
 * e-Lab site (the JSP parts).  This is implementation code, not
 * presentation code.  This page is not shown to users.
 *
 * The PHP side uses some BOINC-based code to support single-sign-on, while
 * the JSP code will allow several students to log in to the same
 * "research group".   We (will) save the research group name and 
 * password in a databse so that we can use them on behalf of the 
 * user instead of asking them to log in. 
 *
 * Eric Myers <myers@spy-hill.net>  - 21 July 2008
 * @(#) $Id: elab_interface.php,v 1.19 2009/06/02 13:48:23 myers Exp $
\***********************************************************************/

require_once("debug.php");      
require_once("config.php");
require_once("http_util.php");   // general utilities for HTTP


/**
 *  e-Lab Login:
 * 
 * Use HTTP POST to "log in" to the JSP e-Lab site, where access is based
 * research group name (ie userid) and password.   Returns FALSE on failure.
 * On success it returs TRUE and sets $elab_cookies and $elab_group 
 *
 * @sets $elab,  $elab_cookies, $elab_group, $elab_timestamp
 */

function elab_login($user='guest', $passwd='guest'){
    global $elab,  $elab_cookies, $elab_group, $elab_timestamp;  // set on success

    // Can't do it if we don't have the right tools
    //
    if( !function_exists("http_get") ){
        add_message("elab_login(): cannot authenticate to e-Lab site"
                    , MSG_WARNING);
        add_message("Bluestone server requires http_pecl extension for that."
                    , MSG_WARNING);
        return FALSE;
    }

    // TODO: urlencode password to escape "&" and "?" 

    // Connect to the JSP e-lab login page with given username and password
    //
    $url= ELAB_URL ."/$elab/login/login.jsp";
    $url .= "?login=Login";
    $url .= "&project=$elab";
    $url .= "&user=$user";
    $url .= "&pass=$passwd";

    debug_msg(3,"Initial URL: <pre>$url</pre>");

    $response = http_get($url,array(), $info);

    $response_code = $info['response_code'];
    if( $response_code != 200 &&
        $response_code != 302 &&
        $response_code != 303 ) {
        add_message("Login attempt returned status $response_code."
                    , MSG_ERROR);
        return FALSE;
    }

    debug_msg(3, "Login GET resulted in response code $response_code");

    // Parse into headers and body
    //
    $response_code = parse_http_response($response,
                                         $response_headers,
                                         $response_body);

    if( empty($response_headers) ) {
        debug_msg(1, "elab_login(): no response headers.", MSG_ERROR);
        return FALSE;
    }
    $hdrs = http_parse_headers($response_headers);

    if( empty($hdrs) ) {
        debug_msg(1, "elab_login(): no headers parsed.", MSG_ERROR);
        return FALSE;
    }
    
    // Failure: look for 
    //      <span class="warning">Invalid username or password</span>
    //
    if( !empty($response_body) ){
        $x = strstr($response_body, "Invalid username or password");
        if( !empty($x) ){
            add_message("Invalid username or password", MSG_ERROR);
            return FALSE;
        }
    }

    // Look for the JSP session cookie for the now logged-in session
    //
    if( empty($hdrs['Set-Cookie']) ){
        debug_msg(1, "elab_login(): no cookies, so no session cookie.", MSG_ERROR);
        return FALSE;
    }
    
    // Parse the session cookie, which may come in several lines
    // TODO: parse ALL cookies, not just this one?
    //
    // TODO: or at least select the one with path=/elab/ligo
    $AuthCookie = array();

    foreach( $hdrs['Set-Cookie'] as $c){
        debug_msg(4,"Set-Cookie: $c");
        $pattern = "/^JSESSIONID=(\S+);(.*)/";
        $n = preg_match($pattern, $c, $matches);
        if($n>0) {
            list( $all, $value, $param ) = $matches;
            debug_msg(3, "elab_login(): $elab rcvd session cookie "
                      ."$value ; $param ");
            $AuthCookie['Name'] = 'JSESSIONID';
            $AuthCookie['Value'] = $value;
        }
    }

    $elab_cookies[$elab] = $AuthCookie;
    debug_msg(2, "$elab e-Lab session cookie: ".$AuthCookie['Value']);

    // That cookie should be enough to let us in to the e-Lab 
    // in subsequent requests.

    if( !empty( $elab_cookies[$elab]) ) {
        $elab_group = $user;
        debug_msg(1,"I think we are in!  $elab Group: $elab_group ");

        // If we are authenticated to BOINC then save group/passwd there
        elab_save_passwd($passwd);        

        //DEBUG//return TRUE;
    }

    /*************************************************************
    // What follows is just to verify that it worked, by following
    // the referers until we get a page body, and scrapping out the
    // group name to verify a match.  We can probably disable this
    // for prouduction (but maybe keep it for debugging?) */


    debug_msg(2, "Verifying authentication and group name...");


    // Follow any redirection(s)
    //
    if( !empty($hdrs['Location']) ){
        $location = $hdrs['Location'];
        $cookie_list = array( 'JSESSIONID' =>  
                              $elab_cookies[$elab]['Value'] );
        $opt = array( 'cookies' => $cookie_list );

        while( !empty($location) ){
            debug_msg(2,"elab_login(): Redirect! $location");

            $response = http_get($location, $opt, $info);
            $response_code = $info['response_code'];
            debug_msg(1, "Redirect resulted in response code $response_code");

            $response_code = parse_http_response($response,
                                                 $response_headers,
                                                 $response_body);
            $location = '';
            if($response_code == 200) continue;  // or just break?

            $hdrs = http_parse_headers($response_headers);
            if( !empty($hdrs['Location']) ){
                $location = $hdrs['Location'];
            }
        }
    }


    ////////////////////////////////////////////////

    // If we got this far we are at a page which is the end of all
    // the redirection, and there should be a non-zero body length.
    // $reponse_status is the last status
    // $response_headers and $response_body are the 


    debug_msg(2, "Response body length: ".strlen($response_body) );
    debug_msg(3, "    Compared to info: ".$info['content_length_download']);

    // Check for Success:
    //     <div id="header-current-user">
    //          E-Lab login group: 
    //                 <a href="../login/user-info.jsp">guest</a> 

    $x = strstr($response_body,  "header-current-user");
    if( empty($x) ) {
        debug_msg(1, "Cannot find header-current-user");
        debug_msg(2, "Page contained: <pre>$response_body</pre>");
        return FALSE;
    }
    $x = substr($x, 0, 150);  
    debug_msg(4, "Looking for login found:<hr>
                <blockquote style='border: 1px; '>$x</blockquote><hr><p>");


    if( preg_match("/<a .*>(\S+)<\/a>/", $x, $matches) > 0 ){
        debug_msg(2, "Returned page says research group name is '"
                  .$matches[1]."'");
        if( $matches[1] != $user ){
            debug_msg(0, "User names do not match!");
            return FALSE;
        }
    }
    else {
        add_message("Cannot get the research group name from page header.",
                    MSG_ERROR);
        return FALSE;
    }
    return TRUE;
}



/**
 * Logging us out of e-Lab just means forgetting the auth tokens
 */

function elab_logout(){
    global $elab, $elab_group, $elab_cookies;

    // clear any JSP session cookie
    $AuthCookie = $elab_cookies[$elab];
    setcookie( $AuthCookie['Name'], '', time()-86400, "/");
    unset($elab_cookies[$elab]);

    unset($elab_group);
    return;
}



/**
 * Check for e-Lab authentication.
 * (Does not tell us if session has timed out!) 
 */

function elab_is_logged_in(){
    global $elab, $elab_group, $elab_cookies;

    if( empty($elab) ) return FALSE;

    if( !empty($elab_cookies[$elab]) )
        debug_msg(4, "elab_is_logged_in(): elab_cookies is set");
    if( !empty($elab_group) )
        debug_msg(4, "elab_is_logged_in(): elab_group is set to $elab_group");


    if( empty($elab_cookies[$elab]) ) return FALSE;
    if( empty($elab_group) ) return FALSE;
    return TRUE;
}



/**
 * Get user's reserach group, if we know it.  
 */

function elab_get_group(){
    global $elab,  $elab_group, $elab_cookies;
    if( !elab_is_logged_in() ) return NULL;
    return $elab_group;
}




/**
 * e-Lab upload -  Upload plot file to elab/$elab/jsp/uploadImage.jsp
 *
 *   $file_path is full path to the file to upload 
 *   $file_name is the name to give it in the e-Lab
 *   $comments are optional user comments, added to e-Lab catalog
 *   $file-type is MIME type of the file (defaults to image/jpeg)
 *
 * On failure, returns empty string.
 * On success, returns URL to the image entry in the e-Lab catalog.
 */

function elab_upload($file_path, $file_name='', $comments='',
                     $file_type='image/jpeg'){
    global $elab, $elab_group, $elab_cookies;
    global $metadata;
    
    $url = '';

    // Can't do it if we don't have the right tools
    //
    if( !function_exists("http_post_fields") ){
        add_message("elab_login(): cannot upload file to e-Lab site"
                    , MSG_WARNING);
        add_message("Bluestone server requires http_pecl extension for that."
                    , MSG_WARNING);
        return FALSE;
    }

    // Can't upload a file we can't find
    //
    if( !file_exists($file_path) ){
      add_message("elab_upload(): Missing file: $file_path ", MSG_ERROR);
      return '';
    }

    if( empty($file_name) ){
        $file_name = basename($file_path);
	// is this actually an error? Probably not.
        debug_msg(2, "elab_upload(): empty file name. Using $file_name");
    }


    // Form for UPLOAD to JSP
    //
    $form_url=ELAB_URL."/$elab/jsp/uploadImage.jsp";
    $form_fields = array('name' => $file_name,
                         'comments' => $comments,
	                 'upload_type' => 'savedimage', 
                         'load' => 'Upload'  );

    // Add metadata array as individual items
    //
    if( !empty($metadata) ) {
        debug_msg(1,"Adding metadata to POST fields.");
	$i=0;
	foreach($metadata as $line){
	    $idx = "metadata".$i++;
	    $form_fields[$idx] = $line;
	}
    }

    $image_file = array('name' => 'image',      // $file_name,
                        'file' => $file_path, 
                        'type' => $file_type);

    debug_msg(2,"Saving file $file_path to the e-lab as '$file_name'...");
    $form_files = array($image_file);  // name='image'

    // Cookies include previously authenticated JSP session ID
    $cookie_list = array( 'JSESSIONID' =>  
                          $elab_cookies[$elab]['Value'] );
    $form_options = array( 'cookies' => $cookie_list );

    $response = http_post_fields($form_url, $form_fields, $form_files,
				 $form_options, $info ); 

    if( empty($response) ){
        debug_msg(1,"http_post_fields() failed! (empty response)");
        add_message("Failed to upload image file", MSG_ERROR);
    }

    $response_code = $info['response_code'];
    debug_msg(2,"Response code from upload was: $response_code");

    if( $response_code != 200 &&
        $response_code != 302 &&
        $response_code != 303 ) {
        debug_msg(1,"upload image attempt returned status $response_code.");
        add_message("Failed to upload image file", MSG_ERROR);
    }

    // Parse into headers and body
    //
    $response_code = parse_http_response($response,
                                         $response_headers,
                                         $response_body);

    $response_code = $info['response_code'];
    debug_msg(2,"Response code after parsing is: $response_code");

    if( empty($response_body) ){
        debug_msg(1, "No BODY!");
    }
    else {
        debug_msg(4,"Response body:<font size='-2'>"
                  ."<hr>$response_body<hr></font>");
    }


    // Check for clear failure:  alter response code to match
    //
    if( $response_body ) {
        $bad_msgs = array(
                          array( 'text' => "Invalid username or password",
                                 'rc' => 401),
                          array( 'text' => "Access to this page is restricted",
                                 'rc' => 401),
                          array( 'text' => "Invalid image type",
                                 'rc' => 415),
                          array( 'text' => "Error saving metadata",
                                 'rc' => 503),
                          );

        foreach( $bad_msgs as $msg ){
            $msg = $msg->txt;
            $x = strstr($response_body, $msg);
            if( !empty($x) ){
                add_message($msg, MSG_ERROR);
                $response_code = $msg->rc;
                if( $response_code == 401 ){
		  //elab_logout(); // clear bogus credentials
		  //TODO: re-login again first.
		}
	    }
	}
    }


    // Check for clear success, & try to grab the link
    //
    if( $response_body ) {
        $good_msgs = array("successfully uploaded",
                           "saved your plot permanently"
                           ); 
        foreach( $good_msgs as $msg ){
            $x = strstr($response_body, $msg);
            if( !empty($x) ){
                // add_message($msg);
                if( preg_match("/<a href=\"(\S+)\"/", $x, $matches) > 0 ){
                    debug_msg(2, "Link to image is '". $matches[1]."'");
                    $url = $matches[1];
                    $url = ELAB_URL."/$elab/plots/".$url;
                }
            }
        }
    }

    debug_msg(2,"Response code after body check is: $response_code");
 
    if( $response_code == 200 ){
        add_message("File saved as $file_name");
    }

    if( $response_code == 200  && empty($url) ){ // just in case...
        add_message("Uploaded file, but could not parse link to it",
                    MSG_WARNING);
        $url = ELAB_URL."/$elab/plots/";
    }
 
    if( $response_code == 500 ){
        add_message("There was an error on the e-Lab server.", MSG_ERROR);
    }

    return $url;

}// elab_upload()



/***********
 * Save group/passwd to BOINC
 */

function elab_save_passwd($password){
    global $elab, $elab_group, $elab_cookies;

    global $logged_in_user;
    global $authenticator;

    // Verify we have something to save
    //
    if( empty($password) ) return FALSE;
    debug_msg(2,"elab_save_passwd(): password to save: $password");
    if( !elab_is_logged_in() ) return FALSE;

    // Check for BOINC login and database access
    //
    debug_msg(2,"elab_save_passwd(): are we logged in to Forums? ");
    if( empty($authenticator) ) return FALSE;

    debug_msg(2,"elab_save_passwd(): get_logged_in_user()? ");
    if( !function_exists('get_logged_in_user') ) return FALSE;

    debug_msg(2,"elab_save_passwd(): initialize BOINC database? ");
    if( db_init_aux() != 0 ) return FALSE;

    $u = get_logged_in_user(false); // false means *try* to get BOINC user
    debug_msg(2,"elab_save_passwd(): logged in as ". $u->name);

    if( empty($u) ) return FALSE;

    $userid=$u->id;
    $elab_name=$elab;
    $group_name = $elab_group;
    debug_msg(2,"elab_save_passwd(): elab: $elab_name "
	       ."group: $group_name ");

        
    // Insert/Replace what we now know, with a timestamp
    //
    $q = "REPLACE INTO elab_group "
        ."(userid, elab_name, group_name, password, timestamp) "
        ."VALUES ($userid, \"$elab_name\", \"$group_name\", \"$password\", "
	. time()." ) ";
    debug_msg(2,"elab_save_passwd(): query: $q ");
    $result = mysql_query($q);
    $x = !empty($result);
    if( $x ) mysql_free_result($result);
    else  debug_msg(2,"  FAILED. ");
    return $x;
}



/**
 * Look up elab group name and password so we don't have to ask for it.
 * Returns an object with $r->group_name and $r->password members,
 * or NULL if nothing found.
 */

function elab_get_saved_info(){
    global $elab, $elab_group, $elab_cookies;
    global $logged_in_user;

    // Check for BOINC login and database access

    if( !$authenticator ) return NULL;
    if( !function_exists('get_logged_in_user') ) return NULL;
    if( db_init_aux() != 0 ) return NULL;

    $u = get_logged_in_user(false); // false means *try* to get BOINC user
    if( empty($u)) return NULL;

    $userid=$u->id;
    $elab_name=$elab;
        
    // look them up in the database
    //
    $q = "SELECT * FROM elab_group WHERE userid=$userid AND elab_name=$elab";
    $result = mysql_query($q);
    if( empty($result) ) return NULL;
    $r = mysql_fetch_object($result);
    mysql_free_result($result);
    return $r;
}




/***********
 * elab_ping() - establishes that we are logged in to the e-lab
 *              (or forces us to do so) and then keeps the session alive.
 *  Return values don't mean anything for now;  Don't test them.
 *
 *
 */

function elab_ping(){
    global $elab, $elab_group, $elab_cookies, $$auth_type;

    // Ignore for testing on Pirates@Home
    //
    if( isset($_COOKIE['pirates_auth']) ) return FALSE;

    // Only works for now if the session was authenticated via referer
    //
    //if( $auth_type != 'referer' ) return FALSE;

    debug_msg(3,"elab_ping(): keeping e-lab session alive...");

    // If not logged in to the elab then skip it.
    //
    //if( empty($elab_group) || empty($elab_cookies[$elab]) ) return FALSE;

    debug_msg(1,"elab_ping(): group $elab_group - keeping e-lab session alive...");

    $url= ELAB_URL ."/$elab/login/user-info.jsp";
    $x = elab_get($url);
    // DO we care if it worked or not?  Can we do anything about it?
    if( empty($x) ) {
      debug_msg(1,"elab_ping() failed.");
      return FALSE;
    }
    return TRUE;	
}




/***********
 * Get a page from the eLab.  Return the full response.
 * Skips through any intermediate redirections.
 * Assumes authentication cookie already set, but tries anyway if 
 * it's not there.  NOT COMPLETELY TESTED.
 */

function elab_get($url, $options=array() ){
    global $elab, $elab_group, $elab_cookies;

    debug_msg(1, "elab_get($url)...");
    if( empty($url) ) return NULL;


    // Can't do it if we don't have the right tools
    //
    if( !function_exists("http_get") ){
        add_message("elab_login(): cannot get page from e-Lab site"
                    , MSG_WARNING);
        add_message("Bluestone server requires http_pecl extension for that."
                    , MSG_WARNING);
        return FALSE;
    }
        
    if (!empty($_COOKIE["JSESSIONID"])) {
	// the jsp code sets this for us
	$jsessionid = $_COOKIE["JSESSIONID"];
    }
    else {
	$jsessionid = $elab_cookies[$elab]['Value'];
    }

    // TODO: _merge_ $options with $cookie_list 

    $cookie_list = array( 'JSESSIONID' => $jsessionid );
    $location = $url;

    while( !empty($location) ){
        $opt = array( 'cookies' => $cookie_list );

        $response = http_get($location, $opt, $info ); 
        $response_code = parse_http_response($response,
                                             $response_headers,
                                             $response_body);

        if( empty($response_headers) ) {
            debug_msg(1, "elab_login(): no response headers.", MSG_ERROR);
            return NULL;

        }
        $hdrs = http_parse_headers($response_headers);
        if( empty($hdrs) ) {
            debug_msg(1, "elab_login(): header parse error.", MSG_ERROR);
            return NULL;
        }
    
        // Or Did we get redirected?
        //
        $location = '';
        if( !empty($hdrs['Location']) ){
            $location = $hdrs['Location'];
            debug_msg(2,"elab_login(): Redirect! $location");
            continue;
        }
	
	$cookies = http_parse_cookie($hdrs["Set-Cookie"]);
	
	if (!empty($cookies->cookies) && $cookies->cookies["JSESSIONID"] == $jsessionid) {
	    //elab returned the same session id, so it's valid
	    $elab_cookies[$elab] = array("Name" => "JSESSIONID", "Value" => $jsessionid);
	    //try to figure out the group
	    if (preg_match("/.*Your username: ([^\s]*)\s.*/", $response_body, $matches)) {
		$elab_group = $matches[1];
		return true;
	    }
	    return NULL;
	}

        // Check for clear failure:
        //
        if( $response_body ) {
            $msg = "Invalid username or password";
            $x = strstr($response_body, $msg);
            if( !empty($x) ){
                add_message($msg, MSG_ERROR);
                elab_logout();  // clear bogus credentials
                return NULL;
            }
            $msg = "Access to this page is restricted to logged in users";
            $x = strstr($response_body, $msg);
            if( !empty($x) ){
                add_message($msg, MSG_ERROR);
                elab_logout();  // clear bogus credentials
                return NULL;
            }
        }


    }// end of redirections

    if( empty($response_body) ){
        debug_msg(3, "No BODY!");
    }
    else {
        debug_msg(4,"Response body:<font size='-2'>"
                  ."<hr>$response_body<hr></font>");
    }
    debug_msg(2,"elab_get(): RC $response_code");

    return $response;
}

?>
