<?php
/***********************************************************************\
 * BOINCAuthPlugin.php             Version 1.1
 *
 * This is a MediaWiki extension for automatic authentication to a 
 * MediaWiki site based on prior authentication to a co-existing BOINC project.
 *
 * Installation:
 *    1) Move this file to the 'extensions' subdirectory of the wiki, 
 *    2) Optionally, edit the parameters and settings in the file.
 *    3) In the directory above extensions edit LocalSettings.php and 
 *         add these lines:
 *
 *           require_once("extensions/BOINCAuthPlugin.php");
 *           $BOINC_html='../..';
 *
 *        where the path in $BOINC_html points to the html subdirectory of
 *        your BOINC project (relative to the top of the wiki). 
 *
 * If a file named BOINCAuthPolicy.php exists in $BOINC_html/project and
 * contains a function of the same name, BOINCAuthPolicy($boinc_user,$user), 
 * then this will be invoked to allow implementation of a customized user
 * access policy without the need of editing the extension itself.
 * 
 *    Tested  recently with MediaWiki 1.10.1 and BOINC 5.9.3.
 *    Tested previously with MediaWiki 1.8.2 and BOINC 5.7.5.
 *
 * To get automatic redirection of the login form (not link) to the BOINC login
 * form you need to also insert a hook into SpecialUserlogin.php, at least until
 * we find a better way to do this.  See the documentation for the extension
 * in the MediaWiki manual for details.  
 *
 * There are three main sections of this file:
 *   I) minimal set of BOINC functions, primarily to access the user database
 *  II) authentication class to extend AuthPlugin
 * III) code to take care of the "automagic" transparent login
 *
 *
 * Written by Eric Myers <myers@spy-hill.net>  - 12 Oct 2006 / 14 Jan 2007
 * @(#) $Id: BOINCAuthPlugin.php,v 1.4 2007/09/07 19:55:14 myers Exp $
\***********************************************************************/

/***********
 * Configuration settings:
 */

/*  Where is the BOINC project's html subdirectory located?
 *  This could be absolute, or relative to the wiki top level. 
 *  It's used to find the access policy in html/project/BOINCAuthPolicy.php 
 *  Set this here, or in LocalSettings.php after you've loaded this extension.
 */

if( empty($BOINC_html) ) $BOINC_html = "../";

/* Prefix added to URL's which point to the BOINC project 
 * This is used for constructing the login/logout links.
 */

if( empty($BOINC_prefix) ) $BOINC_prefix = "";


/* Where is the BOINC config.xml file?
 * This is used to get the user/password for the BOINC database, to look up 
 * the BOINC user.  If it's not set then it is assumed to be the directory 
 * above $BOINC_html.  So set this explicitly if config.xml is elsewhere.  */

if( empty($BOINC_config_xml) ) $BOINC_config_xml="$BOINC_html/../config.xml"; 


/* Re-check interval: how often should we re-check user's BOINC status,
 * even if there is no direct indication that it has changed? */

define("RECHECK_INTERVAL", 3600);


/***********
 * Access settings:  these are just for the example access policy
 * shown below.  
 * 
/* Name of your project (same as in project.inc).
 * Used below just for access policy examples, otherwise not needed. */

define('PROJECT',"Pirates@Home");

/* Credit Thresholds: users must have at least this much recent average 
 * credit (RAC) in order to edit existing pages or add new pages, at least 
 * by the default policy included here as an example. */

define('RAC_TO_EDIT', 0.01);
define('RAC_TO_ADD',  1.00);



/***********
 * Extension information (shown by Special:Version)
 */

$wgExtensionFunctions[] = 'SetupBOINCAuth';   // run automatically
$wgExtensionCredits['other'][] =
    array(
          'name' => 'BOINCAuthPlugin',
          'version' => '1.0.beta6',
          'author' => 'Eric Myers',
          'description' => 'Authentication to the wiki based on authentication '.
                           'to a co-located BOINC project', 
          'date' => '13 September 2007', 
          'url' => 'http://pirates.spy-hill.net/glossary/index.php/BOINC_Authentication'
          );


/* Debuging -- will be disabled or removed once this is all working. 
 * Turn it back on if you find you need it. */

##function debug_msg($level, $message){}; // use this to disable easily

$BOINC_html="/home/myers/i2u2/boinc/html";
require_once( $BOINC_html."/include/debug.php" ); 
set_debug_level(0);

debug_msg(2,"BOINCAuthPlugin.php loading....");


/***********************************************************************\

 * Minimal set of stuff we need from BOINC to be able to access BOINC's
 * xml configuration file and database.   In BOINC the user's 'id' and 
 * 'authenticator' are unique and invariant, but the username and e-mail
 * address can be changed.  (On the wiki the username is unique and
 * invariant.)  
 *
 * Some of this has been modified to work with MediaWiki, it's not just
 * a verbatim copy from BOINC.  File provenances are indicated.
 * 
 * Just as $wgName is a global variable for the wiki, $bgName is a global
 * variable for or related to the BOINC code.
 \***********************************************************************/

// From inc/forum_user.inc, to determine special users for access policies.
// You may need your own if you've modified these.

define('S_MODERATOR', 0); $special_user_bitfield[S_MODERATOR]="Forum moderator";
define('S_ADMIN', 1); $special_user_bitfield[S_ADMIN]="Project administrator";
define('S_DEV', 2); $special_user_bitfield[S_DEV]="Project developer";
define('S_TESTER', 3); $special_user_bitfield[S_TESTER]="Project tester";
define('S_VOLUNTEER', 4); $special_user_bitfield[S_VOLUNTEER]="Volunteer developer";
define('S_VOLUNTEER_TESTER', 5); $special_user_bitfield[S_VOLUNTEER_TESTER]="Volunteer tester";
define('S_SCIENTIST', 6); $special_user_bitfield[S_SCIENTIST]="Project scientist";


//**  From inc/util.inc, to parse BOINC's config.xml settings
//
function get_config() {
    global $bgConfig;
    global $BOINC_html;
    global $BOINC_config_xml;

    if ( !$bgConfig ) { // not already loaded?

        if( !isset($BOINC_config_xml) || empty($BOINC_config_xml) ){
            $BOINC_config_xml = dirname(realpath($BOINC_html))."/config.xml";
        }
        if( file_exists($BOINC_config_xml) ){
            $bgConfig = file_get_contents( $BOINC_config_xml );
        }
        else {
            error_log("BOINCAuthPlugin.php cannot find config.xml file"
                      . " ($BOINC_config_xml) ");
        }
    }
    return $bgConfig;
}

// Look for a particular element in the ../../config.xml file
//
function parse_config($config, $tag) {
    $element = parse_element($config, $tag);
    return $element;
}


// Look for an element in a line of XML text
// If it's a single-tag element, and it's present, just return the tag
//
function parse_element($xml, $tag) {
    $element = null;
    $closetag = "</" . substr($tag,1);
    $x = strstr($xml, $tag);
    if ($x) {
        if (strstr($tag, "/>")) return $tag;
        $y = substr($x, strlen($tag));
        $n = strpos($y, $closetag);
        if ($n) {
            $element = substr($y, 0, $n);
        }
    }
    return trim($element);
}

//**  From inc/db.inc

/*  Keep in mind that the wiki has it's own persistent database connection,
 *  so we need here to keep a handle on (or literally for) the BOINC database. 
 *  The BOINC database handle is the global $bgDB  (false if connection fails)
 */

function db_init_aux() {
    global $bgConfig;   // contents of BOINC xml configuration file 
    global $bgDB;       // persistent connection to BOINC database

    $bgConfig = get_config();
    if( !$bgConfig ) debug_msg(1,"Cannot access config.xml ");
    $user = parse_config($bgConfig, "<db_user>");
    $pass = parse_config($bgConfig, "<db_passwd>");
    $host = parse_config($bgConfig, "<db_host>");
    if ($host == null) {
        $host = "localhost";
    }

    // Create persistent connection to BOINC database server
    $bgDB = mysql_pconnect($host, $user, $pass);
    if( !$bgDB ) return 1;

    // Select the BOINC database
    $db_name = parse_config($bgConfig, "<db_name>");
    if( !mysql_select_db( $db_name, $bgDB ) ) return 2;

    return 0;
}

// return a BOINC user object based on authenticator 
//
function lookup_user_auth($auth) {
    global $bgDB;
    if( !$bgDB || !$auth ) return NULL;

    $q = "SELECT * FROM user WHERE authenticator='$auth'";
    $result = mysql_query( $q, $bgDB );
    if ($result) {
        $user = mysql_fetch_object($result);
        mysql_free_result($result);
        return $user;
    }
    return NULL;
}

// Return a specific user preferences dbobj for the user with the given ID. 
//
function getUserPrefs($user_id){
    global $bgDB;
    if( !is_numeric($user_id) ) return NULL;

    $q= "SELECT * FROM forum_preferences where userid=$user_id";
    $result = mysql_query( $q, $bgDB );
    if ($result) {
        $prefs = mysql_fetch_object($result);
        mysql_free_result($result);
        return $prefs;
    }
    return NULL;
}

// Not in BOINC, but maybe it should be? 
//
function valid_authenticator($auth){
    $t = preg_replace("/[^0-9A-Fa-f]/", "", $auth);
    if(strlen($t)==32) return true;
    debug_msg(1,"Authenticator fails: $t has length ". strlen($t));
    return false;
}

//
/***********************************************************************\
 * This part of this file is the standard MediaWiki authentication 
 * plugin interface from AuthPlugin.php.  We instantiate a customized
 * subclass of AuthPlugin and set $wgAuth to it.  That, in turn, is used
 * here and in User.php, SpecialUserlogin.php, and SpecialPreferences.php.
 \***********************************************************************/

require_once('AuthPlugin.php');

class BOINCAuthPlugin extends AuthPlugin {
    /**
     * Check whether there exists a user account with the given name.
     * @param string $username
     * @return bool
     * @access public
     */
    function userExists( $username ) {
        return true;   
    }

    /**
     * Check if a username+password pair is a valid login.
     * The name will be normalized to MediaWiki's requirements, so
     * you might need to mung it (for instance, for lowercase initial
     * letters).
     *
     * NOTE: this is not going to be used.  If you have to authenticate
     * then you'll authenticate to the BOINC project, not MediaWiki.
     *
     * @param string $username
     * @param string $password
     * @return bool
     * @access public
     */
    function authenticate( $username, $password ) {
        debug_msg(2,"BOINCAuthPlugin->authenticate($username,$password)....");
        // Always return false, we don't use this
        return false;
    }

    /**
     * Modify options in the login template.
     *
     * The template is the presentation code for the login form,
     * created by 'execute()' method.  So this might be a way to  
     * implement a redirect to the BOINC login page, or at least 
     * warn the user that logins won't really work.  Check it...
     *
     * @param UserLoginTemplate $template
     * @access public
     */
    function modifyUITemplate( &$template ) {
        $template->set( 'usedomain', false );
    }

    /**
     * Set the domain this plugin is supposed to use when authenticating.
     *
     * @param string $domain
     * @access public
     */
    function setDomain( $domain ) {
        $this->domain = $domain;
    }

    /**
     * Check to see if the specific domain is a valid domain.
     *
     * @param string $domain
     * @return bool
     * @access public
     */
    function validDomain( $domain ) {
        return true;
    }

    /**
     * When a user logs in, fill in preferences and such.
     * For instance, you might pull the email address or real name from the
     * external user database.
     *
     * The User object is passed by reference so it can be modified
     *
     * For BOINC we always use the BOINC user name as the Real Name,
     * and the BOINC e-mail address as the e-mail address.
     * (TODO: add a comment to Special:Preferences pointing this out) 
     *
     * For BOINC we also use this to implement access policies based on 
     * BOINC user information (such as credit or special user bits).
     * We do this by adding or removing group membership for the user.
     * Remember that this is only done once at login.  If a user expects
     * a change in access policy (eg. they have been made a BOINC moderator,
     * or RAC has risen above a threshold) then they need to logout and 
     * log back in for the change to take effect.  At least for now.
     *
     * @param User $user
     * @access public
     */
    function updateUser( &$user ) {
        global $bgAuthenticator;
        global $BOINC_html, $BOINC_prefix;
        global $wgClockSkewFudge;

        debug_msg(2,"BOINCAuthPlugin->updateUser()....");

        if( !$bgAuthenticator || !valid_authenticator($bgAuthenticator) ) return;

        db_init_aux();         // connect to BOINC user database 
        $boinc_user = lookup_user_auth($bgAuthenticator);

        /* transcribe user info from BOINC to wiki */

        if($boinc_user->name != null) {
            $user->setRealName($boinc_user->name);
        }
        if( !empty($boinc_user->email_addr) ) {
            $user->setEmail($boinc_user->email_addr);
        }
        if( $boinc_user->cross_project_id != null ) {
            $user->mNewPassword = $boinc_user->cross_project_id; 
        }

        /* e-mail verification.  MediaWiki stores the date the e-mail 
         * address was verified.  BOINC just stores a yes/no flag, and
         * even that has recently been removed.  I hope we can get 
         * verification back into BOINC, with a timestamp, but until then
         * we set the wiki timestamp the first time we see the BOINC 
         * verification flag is set.  */

        $email_verified = $boinc_user->email_validated;
        if( !$user->mEmailAuthenticated ){
            //TODO: when BOINC has a validation *timestamp* then use it here  
            //$user->mEmailAuthenticated = wfTimestampOrNull(TS_MW, $email_verified);
            if( $email_verified ){
                $user->mEmailAuthenticated =
                    wfTimestamp( TS_MW, time() + $wgClockSkewFudge );
            }
        }

        /* Access policy: set user's wiki group memberships based on BOINC
         * attributes.  
         *
         * If the file BOINCAuthPolicy.php exists in the BOINC project directory 
         * and it contains a function BOINCAuthPolicy($boinc_user,$wiki_user)
         * then call that to apply the policy.  Otherwise, use the code below,
         * which is just an example you can modify for your own project.
         */

        if( !isset($BOINC_html) ) { // default if not set
            $BOINC_html = "../";
        }
        if( is_dir($BOINC_html) ){
            $policy_file = realpath($BOINC_html) . "/project/BOINCAuthPolicy.php";
            if( file_exists($policy_file) ) {
                require_once($policy_file);
                if( function_exists('BOINCAuthPolicy') ){
                    BOINCAuthPolicy($boinc_user,$user);
                    $user->mTouched =  wfTimestamp( TS_MW, time() + $wgClockSkewFudge );
                    $_SESSION['user_last_checked'] = $user->mTouched;
                    return; 
                }
            }
        }

        /* What follows is just an illustrative example, so it's disabled 
         * by default for all but our test project */

        if( PROJECT != "Pirates@Home" ) return;

        /* Automatic group assignment based on recent average credit (RAC) */

        if( $boinc_user-> expavg_credit < RAC_TO_EDIT ) {
            $user->removeGroup('seaman');      
            $user->removeGroup('able_seaman'); 
        }
        else {
            if( $boinc_user-> expavg_credit < RAC_TO_ADD ) {
                $user->addGroup('seaman');         
                $user->removeGroup('able_seaman'); 
            }
            else {
                $user->addGroup('able_seaman');    
                $user->removeGroup('seaman');      
            }
        }

        /* Group assignment based on forum "special user" bits
         * (promotions are automatic, demotions must be done by hand) */ 

        $forum_preferences =  getUserPrefs($boinc_user->id);
        if($forum_preferences){
            // BOINC admins are "officers"
            if( substr($forum_preferences->special_user, S_ADMIN, 1) ){
                $user->addGroup('officer');        
                debug_msg(1,"Welcome aboard, Sir!");
            }
            // BOINC moderators are "chiefs"
            elseif( substr($forum_preferences->special_user, S_MODERATOR, 1) ){
                $user->addGroup('chief');        
                debug_msg(1,"Welcome aboard, Chief.");
            }

            /* BOINC users who are 'banished' from the discussion forums
             * are "in the brig" here, until their sentence runs out */

            $t = $forum_preferences->banished_until ;
            if( $t ){
                if( $t > time() ) {
                    debug_msg(1,"This user is in the brig!");
                    $user->addGroup('brig');        
                    $user->removeGroup('seaman');      
                    $user->removeGroup('able_seaman'); 
                    $user->removeGroup('chief');      
                }
                else {
                    $user->removeGroup('brig'); 
                }
            }
        }// forum_preferences

        // set time we last checked status
        $user->mTouched =  wfTimestamp( TS_MW, time() + $wgClockSkewFudge );
        $_SESSION['user_last_checked'] = $user->mTouched;
        debug_msg(2,"Session timestamp: ".$user->mTouched);
        return; 
    }// updateUser()

    /**
     * Return true if the wiki should create a new local account automatically
     * when asked to login a user who doesn't exist in the wiki but does
     * exist on the BOINC project.  That's how it works here.
     *
     * @return bool
     * @access public
     */
    function autoCreate() {
        return true;
    }

    /**
     * Can users change their passwords?  Not via the wiki!
     *
     * @return bool
     */
    function allowPasswordChange() {
        return false;
    }

    /**
     * Set the given password in the external authentication database.
     * Return true if successful.   We don't allow that for BOINC.
     *
     * @param string $password
     * @return bool
     * @access public
     */
    function setPassword( $password ) {
        return false;  // no, you can't do that from the wiki
    }

    /**
     * Update user information in the external authentication database.
     * Return true if successful.   We don't allow that for BOINC.
     *
     * For BOINC we don't allow it, so always false.
     *
     * @param User $user
     * @return bool
     * @access public
     */
    function updateExternalDB( $user ) {
        return false;   // no, we didn't
    }

    /**
     * Check to see if external accounts can be created.
     * Return true if external accounts can be created.
     *
     * For BOINC we don't allow it, so always false.
     *
     * @return bool
     * @access public
     */
    function canCreateAccounts() {
        return false;   // the wiki cannot create new BOINC accounts
    }

    /**
     * Add a user to the external authentication database.
     * Return true if successful.   
     *
     * For BOINC we don't allow it, so always false.
     *
     * @param User $user
     * @param string $password
     * @return bool
     * @access public
     */
    function addUser( $user, $password ) {
        return false;
    }

    /**
     * Return true to prevent logins that don't authenticate here from being
     * checked against the local database's password fields.
     *
     * This is just a question, and shouldn't perform any actions.
     *
     * As an example, if you set this true, and have a WikiSysop account
     * for the wiki which does not have a corresponding account on the
     * BOINC project then WikiSysop will not be able to login.   That's
     * okay if a BOINC user has those permissions, otherwise it's bad.
     * Start with false for testing, but eventually set this to true.
     *
     * @return bool
     * @access public
     */
    function strict() {
        return true;   // false for now, but ultimately true
    }

    /**
     * When creating a user account, fill in preferences and such.
     * For instance, you might pull the email address or real name from the
     * external user database.
     *
     * The User object is passed by reference so it can be modified.
     *
     * For BOINC we store the unique authenticator in the wiki user's
     * password field, and that is how we identify the user on subsequent
     * logins.
     *
     * @param User $user
     * @access public
     */
    function initUser( &$user ) {
        global $bgAuthenticator;

        $this->updateUser($user);             // update BOINC user info
        $user->mPassword = $bgAuthenticator;  // not encrypted, not a password
    }

    /**
     * If you want to mung the case of an account name before the final
     * check, now is your chance.
     *
     * Strip out characters not in the 'legal' list.
     *
     * MediaWiki may alter the username, but we use the BOINC username
     * unaltered as the wiki Real Name (as if it matters).  
     */
    function getCanonicalName( $username ) {
        global $wgLegalTitleChars;

        $trim_pattern="/[^$wgLegalTitleChars]/";
        $trimmed_name=preg_replace( $trim_pattern, '', $username );    
        return $trimmed_name;
    }
}

/*
 * End of AuthPlugin Code.
 */

//
/***********************************************************************\
 * The rest of the file takes care of "automagic" login using the 
 * "AutoAuthenticate" hook, so that the user need not enter username
 * and password if they are already authenticated to the BOINC project.
 \************************************************************************/

/* We first look for evidence of an authenticated BOINC session by
 * looking for $boinc_auth or $authenticator in $_SESSION, or if
 * those are not there (sharing a session is not required) then 
 * the BOINC authentication cookies.
 * If these don't exist then don't bother putting the AutoAuth in place.
 */

function SetupBOINCAuth(){
    global $wgHooks;
    global $wgAuth;
    global $wgEnableEmail;
    global $bgAuthenticator;
    global $BOINC_prefix;

    debug_msg(1,"SetupBOINCAuth(): started.");
    debug_msg(1,"scroll..<pre>\n\n\n\n\n\n\n</pre>" ); // past the logo

    debug_msg(4," PHP session_id(): ". session_id() );
    if( !isset($_SESSION) ) return;

    /* Hooks to intercept wiki login/logout - use BOINC instead */

    $wgHooks['UserLogin'][] = 'use_BOINC_login'; 
    $wgHooks['UserLogout'][] = 'use_BOINC_logout';  

    /* first look for existing authenticator in this session */

    if ( !$bgAuthenticator ) {
        if (array_key_exists('boinc_auth', $_SESSION)) { 
            $bgAuthenticator = $_SESSION['boinc_auth'];
            debug_msg(3," boinc_auth was in _SESSION: $bgAuthenticator");
        }
        elseif (array_key_exists('authenticator', $_SESSION)) {
            $bgAuthenticator = $_SESSION['authenticator'];
            debug_msg(3," authenticator set in session: $bgAuthenticator");
        }
    }

    /* if not found in session, check for BOINC authentication cookies */

    if ( !$bgAuthenticator ) {
        if( isset($_COOKIE['auth'])) {
            debug_msg(1," authenticator from auth cookie: ". $_COOKIE['auth'] );
            $bgAuthenticator = $_COOKIE['auth'];
        }
        // This is more BOINC specific, so I hope we can convince DA to switch to this
        if( isset($_COOKIE['boinc_auth']) ) {
            debug_msg(1," authenticator from boinc_auth cookie: ". $_COOKIE['boinc_auth'] );
            $bgAuthenticator = $_COOKIE['boinc_auth'];
        }
    }

    /* if any of those succeeded then setup the AutoAuth hooks and looks */

    if( $bgAuthenticator ) { /* user is _possibly_ authenticated to BOINC */
        debug_msg(1,"SetupBOINCAuth(): setting up AutoAuthenticate...");
        $wgHooks['AutoAuthenticate'][] = 'BOINCAutoAuth'; 
        $wgHooks['PersonalUrls'][] = 'LogoutLinks'; 
        $wgAuth = new BOINCAuthPlugin();
    }
    else { /* nobody is authenticated to BOINC, so just show the login link */
        debug_msg(2,"SetupBOINCAuth(): no BOINC user session found.");
        // make sure nobody (else?) is logged in to the wiki

        /************ MW 1.8 to 1.10 compatibility: *********
         * User::loadFromSession() was made private; now use User::newFromSession(),
         * but only if older is no longer available.  */

        $use_loadFromSession = in_array( 'loadFromSession', get_class_methods('User') );
        
        if( $use_loadFromSession ){             // MW 1.8
            $tmpuser = User::loadFromSession();
            debug_msg(2, "MW 1.8 - User::loadFromSession()");
        }
        else {                                  // MW 1.10
            $tmpuser = User::newFromSession();
            debug_msg(2, "MW 1.10 - User::newFromSession()");
        }
        /************* end compatibility block *****************/

        if( $tmpuser->isLoggedIn() ){
            debug_msg(1,"BOINCAutoAuth(): somebody (else?) is already logged in: "
                      . $tmpuser->mName);
            $tmpuser->logout();
        }
        $wgHooks['PersonalUrls'][] = 'LoginLinks'; 
    }
}

/****
 * Disable anonymous user page links, point login to BOINC project login form .
 */

function LoginLinks(&$personal_urls , $title){
    global $BOINC_prefix;

    debug_msg(1,"LoginLinks() ...");
    unset($personal_urls['anontalk']);
    unset($personal_urls['anonlogin']);
    unset($personal_urls['anonuserpage']);

   // Login link now brings you back to this page.
    $personal_urls['login'] =
        array( 'text' => 'Login',
               'href' => $BOINC_prefix.'/login_form.php?next_url='.
               wfUrlencode($title->getFullURL())
               );

    debug_msg(3, "personal_urls contains: <pre>"
              .print_r($personal_urls,true)."</pre>");
    debug_msg(3, "title contains: <pre>" .print_r($title,true)."</pre>");
}

/****
 * This function is to be called by the hook 'UserLogin' in SpecialUserlogin.php
 * which is set above, except that there is no such hook (yet?) in MediaWiki.
 * You will therefore need to add the following line to that function
 *
 *       if( !wfRunHooks('UserLogin', array(&$form)) ) return;
 *
 * right after the login $form is created but before it is exectued.
 * Maybe someday there is a better way to do this?
 */

function use_BOINC_login(&$form=NULL){  // $form is the just-created login form
    global $personal_urls;
    global $wgOut;   
    global $BOINC_prefix;


    $login_url = $personal_urls['login']['href'];
    if( !$login_url ) {
       $login_url = $BOINC_prefix. "/login_form.php?next_url=".
	 wfUrlencode($title->getFullURL());
    }
    $wgOut->redirect( $login_url );
    return false;   // short circuits hook call
}


/****
 * Add link to logout from BOINC project, disable anonymous page/talk links
 */

function LogoutLinks(&$personal_urls, $title){
    global $wgHooks;
    global $BOINC_prefix;

    unset($personal_urls['anonuserpage']);
    unset($personal_urls['anontalk']);
    unset($personal_urls['anonlogin']);

    $personal_urls['logout'] =
        array( 'text' => 'Logout',
               'href' => $BOINC_prefix.'/logout.php');
    /************
     * If you want to come right back use this version (but is that right?)
     *        'href' => $BOINC_prefix.'/logout.php?next_url='.
     *          wfUrlencode($title->getFullURL())
     *            );
     *************/

    debug_msg(6, "personal_urls contains: <pre>" .print_r($personal_urls,true)."</pre>");
}


/****
 * So that Special:Userlogout redirects to BOINC logout page 
 */

function use_BOINC_logout(&$user){// redirect to the BOINC logout page
    global $wgOut, $wgClockSkewFudge;
    global $personal_urls;
    global $BOINC_prefix;

    /* touch the user, so any future access is checked carefully */
    $user->mTouched =  wfTimestamp( TS_MW, time() + $wgClockSkewFudge );

    $logout_url = $personal_urls['logout']['href'];
    // TODO: make this logout.php?returnto= here
    if( !$logout_url ) $logout_url=$BOINC_prefix."/logout.php";
    $wgOut->redirect($logout_url);
    return false;   // short circuits calling function
}


/****
 *  Automagic authentication (no need to stop and log-in) based on
 *  already authenticating to the BOINC project.
 */

function BOINCAutoAuth($user){
    global $wgUser;
    global $wgContLang;  
    global $wgAuth;
    global $bgAuthenticator;
    global $wgLegalTitleChars;

    debug_msg(3,"BOINCAutoAuth(): entered.");

    if( !$bgAuthenticator || !valid_authenticator($bgAuthenticator) ){
        return;         // not authenticated to BOINC, so bail 
    }

    debug_msg(4,"User last touched: ".  $user->mTouched);

    $tmpuser =&$user;
    if( $tmpuser != null && $tmpuser->isLoggedIn() ){
        debug_msg(2,"BOINCAutoAuth():  user ".$tmpuser->mName." is ALREADY logged in.");
        debug_msg(3,"  authenticator: $bgAuthenticator");

        if( $tmpuser->mPassword == $bgAuthenticator ) {// and these match? We're in!

            /*  When the user's status changes the timestamp in $user->mTouched is
             *  updated.  If that is later than the session timestamp (or if there 
             *  is no session timestamp) then we need to review credentials and status */

            if( !array_key_exists('user_last_checked', $_SESSION) ){
                $_SESSION['user_last_checked'] = -1;
            }
            $user_last_checked = $_SESSION['user_last_checked'];
            debug_msg(2,"  user_last_checked: $user_last_checked");
            $user_touched = $user->mTouched; 
            debug_msg(2,"  user last touched: $user_touched");
            $recheck_time = wfTimestamp( TS_MW, time() - RECHECK_INTERVAL);
            debug_msg(2,"  Recheck user settings if auth before: $recheck_time");
            if( $user_last_checked < $user_touched ||
                $user_last_checked < $recheck_time ){ 
                debug_msg(1," Time to UPDATE USER!");
                $wgAuth->updateUser( $tmpuser );   // this also resets both timestamps
            }
            return;  // we are now logged in, so we are done here
        }
    }

    debug_msg(1,"BOINCAutoAuth(): user is NOT already logged in.");

    /* Is the BOINC user already in the MW database?  The password field
     * holds the BOINC authenticator, so look up user with that. */

    $dbr =& wfGetDB( DB_SLAVE );
    $name = $dbr->selectField( 'user', 'user_name',
                               array('user_password' => $bgAuthenticator));
    if( is_string( $name ) ) { /* found something */
        $tmpuser= User::newFromName( $name, true );  // with name validation
        if( $tmpuser != null && $tmpuser->getID() != 0 ){

            $tmpuser->loadFromDatabase();      // fill in wiki info
                                               // (to be private some day?)
            $wgAuth->updateUser( $tmpuser );  // update with BOINC info
            $wgUser = &$tmpuser;       
            $wgUser->setCookies();
            $wgUser->setupSession();
            global $wgClockSkewFudge;
            $_SESSION['user_last_checked'] = wfTimestamp( TS_MW, time() + $wgClockSkewFudge );
            debug_msg(2,"BOINCAutoAuth():  user ".$tmpuser->mName." logged in.");
            return;
        }
    }

    debug_msg(1,"BOINCAutoAuth(): user is NOT in MW database. Create one.");

    /* Did not find a user (with valid user name) in the database, so 
     * create a NEW wiki user, based on BOINC user information     */

    db_init_aux();    
    $boinc_user = lookup_user_auth($bgAuthenticator);
    debug_msg(1,"BOINC user: ". $boinc_user->name);
    debug_msg(1,"BOINC id: ". $boinc_user->id);
    debug_msg(2,"BOINC email_addr: ". $boinc_user->email_addr);

    /* Find a wiki user name based on the BOINC user name which is
     *    a) legal in the wiki, and b) not already in use   */

    $username=$boinc_user->name;
    $trim_pattern="/[^$wgLegalTitleChars]/";
    $trimmed_name=preg_replace( $trim_pattern, '', $username );    
    $generic_name= "User_" . $boinc_user->id; 
    $possible_names = array($username, $trimmed_name, $generic_name);

    foreach( $possible_names as $name ){
        debug_msg(2,"Let's try the name $name...");
        $tmpuser = User::newFromName( $name, true ); // validates the name
        if( $tmpuser ) debug_msg(2,"Got wiki name ".$tmpuser->mName);
        if( $tmpuser != null && User::idFromName($tmpuser->mName) == 0 ) break;
    }
    if($tmpuser == null ) return;  // none of those worked.  Bummer.

    /* Add this new user to the database and log them in  */

    debug_msg(1,"Adding the new user to the database...");
    $wgAuth->initUser( $tmpuser );   // sets mPassword <- bgAuthenticator
    $tmpuser->addToDatabase();
    $wgUser = &$tmpuser;
    $wgUser->setCookies();
    $wgUser->setupSession();
}

debug_msg(2,"BOINCAuthPlugin.php loaded.");

?>
