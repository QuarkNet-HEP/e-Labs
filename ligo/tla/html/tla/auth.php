<?php 
/***********************************************************************\
 * User Authentication -  all things auth
 *
 * We require authentication to use the Analysis Tool, but we provide
 * for a variety of ways to satisfy the requirement:
 *
 *   + You might be logged in via BOINC's authentication method
 *   + You might have _just_ logged in via HTTP Basic authentication
 *   + You might have logged in _previously_ via HTTP Basic authentication
 *   + You might have a grid certificate (though this isn't working yet)
 *   + You might be logged in to the JSP part of the I2U2 site
 *   + Some other mechanism (Shibboleth?) for x-site auth
 *   + We might let beginners use it anonymously, just to try it out
 *
 * The idea is to put anything dealing with authentication in this one
 * place, and to make it both flexible and extensible.
 *
 * The primariy purpose of authentication is to know who is using the tool,
 * so that we can save info and results under their identity.
 * Authorization is not so important.
 *
 * This file is implementation code, not presentation code.
 * No direct user output should be generated, except that you can 
 * use add_message() to show something to the user.
 *
 * Eric Myers <myers@spy-hill.net>  - 20 June 2006
 * @(#) $Id: auth.php,v 1.47 2009/05/26 20:55:24 myers Exp $
\***********************************************************************/

require_once("debug.php");      
require_once("config.php");


/************************************************
 * Require user authentication.  If authentication fails then
 * issue a redirect to the login page, with a link back.
 * Only returns to the caller if the user is logged in.
 */ 

function require_authentication(){
    $self = $_SERVER['PHP_SELF'];
    $authenticated = check_authentication();
    if( $authenticated ) return TRUE;

    $url = fill_in_url($self);
    set_destination($url);
    header("Location: auth_required.php");
    exit(0);
}


/**
 * check_authentication() just checks to see if they are in fact 
 * somehow authenticated, and just returns true/false.
 */

function check_authentication(){
    global $user_level;
    global $logged_in_user, $elab_group;
    global $auth_type, $authenticator, $referer;
    global $BOINC_html;

    if ( session_id()=="" ) session_start(); // start/continue session
 
    debug_msg(4,"check_authentication()...");

    recall_variable('user_level');   // to be sure? someday won't need this...?

    $authenticated=FALSE;


    /**
     * First check for prior authentication via one of the simpler
     * methods below.
     */

    // HTTP Basic authentication?
    //
    if( !$authenticated ){
        $authenticated = prev_HTTP_auth();
    }

    /** 
     * Grid Certificate required?  Not yet, but maybe some day... 
     */
    if( $user_level > 4 ) {
        debug_msg(1,"Super-User level requires a Grid Certificate.", 
                  MSG_ERROR);
        ///////
        //TODO: check here for *VALID* SSL certificate
        //////
        set_user_level(3);
        $authenticated=FALSE;  
    }


    /**
     * Try BOINC authentication...
     *  Note: this seems to require a database connection to Spy Hill
     *        Need to get away from that.
     */
 
    debug_msg(5,"get_logged_in_user() exists?");

    if( !function_exists('get_logged_in_user') ) { 
	load_BOINC_util();
    }

    // Keep in mind that get_logged_in_user() returns a BOINC user _Object_  

    if( function_exists('get_logged_in_user') ) { // try again...
        debug_msg(5,"Checking that user is logged in...");
        db_init_aux();    
        $u = get_logged_in_user(false); // false means *try* to get BOINC user
        if( !empty($u) ) {
            $authenticated=TRUE;
            $auth_type='BOINC';
            $logged_in_user=$u;
            $authenticator=$u->authenticator;
            if( $_SESSION['authenticator'] != $authenticator) {
                debug_msg(2, "_SESSION['authenticator'] mismatch "
                          .$_SESSION['authenticator']."!= $authenticator ");
                debug_msg(2, "  Trying to correct.");
                $_SESSION['authenticator'] = $authenticator;
            }
            debug_msg(5,"   ... authenticated via BOINC.");
        }
    }
    else{
        debug_msg(1,"BOINC authentication is disabled or unavailable.");
    }


    // Prior auth via referer
    //
    if(!$authenticated ){ 
        $auth_type=$_SESSION['AUTH_TYPE'];
        $u = $_SESSION['PHP_AUTH_USER'];
        if( $auth_type=='referer' &&  !empty($u) ){
            //TODO: This should probably be Research Group, eh?
            $logged_in_user->name = $u;
            $authenticated=TRUE;
            debug_msg(2,"Authenticated based on previous referer.");
            return TRUE; 
        }                 
    }


    /**
     * Check for tickets indicating a forwarded connection from another site.
     */

    if( !$authenticated ) {
        debug_msg(4,"Checking for a valid ticket...");
        $ticket = get_ticket();
        if( check_ticket($ticket) ){
            $authenticated=TRUE;
            $auth_type='BOINC';
            if( !array_key_exists('authenticator', $_SESSION)){
                $_SESSION['authenticator']= $authenticator;
            }
            debug_msg(4,"  .. BINGO! the tickets matched");
            return TRUE;
        }
    }


    /**
     * Beta testing: check for Pirates@Home cookie
     */

    if( !$authenticated ){
        debug_msg(4,"checking Pirates@Home authentication...");
        if( isset($_COOKIE['pirates_auth']) ){
            $authenticator = $_COOKIE['pirates_auth'];
            debug_msg(4,"found pirates_auth cookie: $authenticator");

            $authenticator = process_user_text($authenticator);
            debug_msg(4,"authenticator: $authenticator");

            // Now look up user in Pirates@Home database

            if( file_exists("/usr02/pirates/config.xml")){
                debug_msg(4,"getting database config info...");

                $p_config = file_get_contents("/usr02/pirates/config.xml");
                $db_user = parse_config($p_config, "<db_user>");
                $db_pass = parse_config($p_config, "<db_passwd>");
                $host = parse_config($p_config, "<db_host>");
                if ($host == null) $host = "localhost";
                debug_msg(4,"connecting to Pirates@Home database...");
                debug_msg(5,"  (U: $db_user, H: $host, PW: $db_pass)");
                $ph = @mysql_pconnect($host, $db_user, $db_pass);

                if(!$ph) debug_msg(2," Failed to connect");
                if($ph){
                    $db_name = parse_config($p_config, "<db_name>");
                    if( mysql_select_db($db_name,$ph) ) {
                        $q="SELECT * FROM user WHERE authenticator='$authenticator'";
                        debug_msg(5,"mysql> $q");
                        $result = mysql_query($q, $ph);
                        if( $result ) {
                            $user = mysql_fetch_object($result);
                            mysql_free_result($result);
                            if( $user ) {
                                $authenticated=TRUE;
                                $auth_type='BOINC';
                                $logged_in_user=$user;
                                debug_msg(3,"User is ".$user->name);
                            }
                        }
                    }
                }
            }
        }
    }


    /**
     * e-Lab authentication.  If we are in the LIGO e-Lab we 
     * can use e-lab group info.  WORK IN PROGRESS - NOT DONE YET
     */

    $elab_group = elab_get_group();

    if( !$authenticated && !empty($elab_group) ) {
        $auth_type='elab_group';
        $authenticated=TRUE;
    }


    /**
     * Auth based on referer (weak, just for guests)
     * 
     */

    if( !$authenticated && !empty($referer)		
	&& (strpos($self,'tla_dev') === FALSE ) ){// disabled for tla_dev
        debug_msg(3,"Checking referer: $referer");
        $ref_url = parse_url($referer);
        if( $ref_url ){
            $host = $ref_url['host'];
            debug_msg(3,"Checking access based on host: $host");
            if( preg_match('/\.i2u2\.org$/', $host) ){
                $authenticated=TRUE;
                $logged_in_user->name = 'Guest';
                $auth_type='referer';
            }
            if( preg_match('/pirates\.spy-hill\.net$/', $host) ){
                $authenticated=TRUE;
                $logged_in_user->name = 'Pirate Guest';
                $auth_type='referer';
            }
            if($authenticated){ // save for later in the session 
                $_SESSION['AUTH_TYPE'] = $auth_type;
                $_SESSION['PHP_AUTH_USER'] = 'Guest';
                debug_msg(2,"Authenticated based on host domain: $host");
                return TRUE; 
            }
        }
    }


    /**
     * NEW: ANY GUEST: Open it up.  Basically after trying all those things,
     * if the user has not authenticated then we grant them access as just
     * a guest.   This short-circuits HTTP Basic Auth below;   
     * Disable this block to go back to using HTTP Basic Auth if needed.
     * This is disabled for tla_dev so we can work on other methods.
     */

    if( !$authenticated && (strpos($self,'tla_dev') === FALSE ) ){
        $logged_in_user->name = 'guest';
        $auth_type='default';
        $authenticated=TRUE;
    }

    /**
     * OLD: force HTTP Basic authentication to the web server
     *      if we got this far without being authenticated.
     */
    if( !$authenticated ){
        $authenticated = basic_HTTP_auth();
    }


    /* if any of the above worked then we are IN */

    if( $authenticated ) return TRUE;

    /* Or allow people to try the tool as beginners? */

    if(0){
        add_message("You may try this tool as a beginner, but you
        will need to log-in to use a higher user level.<br/>",
                    MSG_WARNING);
        $user_level=1;
        remember_variable('user_level');
        $_COOKIE['user_level'] = $user_level;
        setcookie('user_level', $user_level, 0); // until end of session
        if( $user_level < 2 ) return TRUE;
    }
    return FALSE;
}// check_authentication()


// Load the BOINC inc/util.inc file, or something that can take it's place. 
//

function load_BOINC_util(){
  global $BOINC_html;

  if( file_exists("../inc/util.inc") ) {  // from BOINC?
    debug_msg(6,"loading ../inc/util.inc");
    include_once("../inc/util.inc");
    debug_msg(6,"loaded ../inc/util.inc");
  }
  elseif( file_exists("../include/util.php") ) { // or from other?
    debug_msg(6,"loading ../include/util.php");
    include_once("../include/util.php");
  }

  // Eventually we'll just use this
  elseif( file_exists("$BOINC_html/include/util.php") ) {
    debug_msg(6,"loading $BOINC_html/include/util.php");
    include_once("$BOINC_html/include/util.php");
  }
  else {
    debug_msg(0,"Cannot find the BOINC utilities I need!!!");
    debug_msg(0,"(I even looked in $BOINC_html/include)" );
  }
}



/**
 * HTTP Basic authentication I: previous HTTP authentication? */

function prev_HTTP_auth(){
  global $logged_in_user;
  global $auth_type;

  debug_msg(3,"prev_HTTP_auth()...");

  $authenticated=FALSE;
  $auth_type=$_SESSION['AUTH_TYPE'];
  debug_msg(4,"AUTH_TYPE is $auth_type");
  $u = $_SESSION['PHP_AUTH_USER'];
  debug_msg(4,"PHP_AUTH_USER is $u");
  $p = $_SESSION['PHP_AUTH_PW'];
  debug_msg(5,"PHP_AUTH_PW is $p");
  if( $auth_type=='Basic' &&  !empty($u) && !empty($p) ) { 
    $logged_in_user->name = $u;
    $authenticated=TRUE;
    debug_msg(2,"  .. BINGO!");
  }    
  return  $authenticated;
}


/**
 * HTTP Basic authentication II: immediate HTTP authentication? */

function basic_HTTP_auth(){
  global $logged_in_user;
  global $auth_type;

  debug_msg(3,"basic_HTTP_auth()...");

  $authenticated=FALSE;
  $auth_type=$_SERVER['AUTH_TYPE'];
  debug_msg(4,"AUTH_TYPE is $auth_type");
  $u = $_SERVER['PHP_AUTH_USER'];
  debug_msg(4,"PHP_AUTH_USER is $u");
  $p = $_SERVER['PHP_AUTH_PW'];
  debug_msg(5,"PHP_AUTH_PW is $p");
  if( $auth_type=='Basic' &&  !empty($u) && !empty($p) ){
    $logged_in_user->name = $u;
    $authenticated=TRUE;
    // save, in case we walk out of subdirectory
    $_SESSION['AUTH_TYPE'] = $_SERVER['AUTH_TYPE'];
    $_SESSION['PHP_AUTH_USER'] = $_SERVER['PHP_AUTH_USER'];
    $_SESSION['PHP_AUTH_PW'] = $_SERVER['PHP_AUTH_PW'];
    debug_msg(2,"  .. BINGO!");
  }    
  return $authenticated;
}


/**
 * This shows who we are logged in as and the method, for use in
 * the page top banner.		*/

function show_user_login_name($username='') {
    global $logged_in_user, $auth_type;
    global $elab, $elab_group, $elab_cookies;

    // E-lab group authentication?

    if( elab_is_logged_in() ){
        echo "Research Group: $elab_group <br/>";
    }

    if( empty($username) ) $username=$logged_in_user->name;
    debug_msg(7,"Logged in user name is '$username' ");

    if ( empty($username) ) {// No username set, so we are not logged in.
        echo "Not logged in";
        { //if( $auth_type=='BOINC' ){ //TODO: go to login choice page?
            echo "&nbsp;&nbsp;<a href='auth_required.php'>[Login]</a>"; 
        }
    }
    else {
        if( $auth_type=='Basic' && $username != 'guest') {
            echo "Logged in as <tt>". $username. " </tt><br/>";
            echo "<font size='-2'>(via HTTP Basic auth)<br/></font>";
            echo "<font size='-1'>";
            echo "<a href='auth/htpasswd.php'>[change password]</a>";
            echo "</font>";
        }
        else {
           echo "Logged in as ". $username. " <br/>";
           global $debug_level;         
           if( $debug_level > 1 ){ 
               echo "<font size='-2'>(method: $auth_type)<br/></font>";
           }
        }

        if( ($auth_type != 'default') && ($auth_type != 'referer') ){
            echo "<font size='-1'>&nbsp;";
            echo "<a href='logout.php'>[Logout]</a></font>";
        }
    }
}


$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: auth.php,v 1.47 2009/05/26 20:55:24 myers Exp $";
?>
