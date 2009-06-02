<?php
/***********************************************************************\
 * login.php - authenticate a user to the LIGO Analysis Tool
 *
 * The authentication system used here (now, at least) is based on the
 * same mechanism used by BOINC for the discussion forums.
 * So we just emulate that login.
 * 
 * See also auth/ and auth/basic_auth.php for an alternate mechanism
 * which also works.
 *
 * Eric Myers <myers@spy-hill.net  - 12 December 2006
 * @(#) $Id: login.php,v 1.12 2009/04/29 20:43:24 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general TLA utilities

require_once("$BOINC_html/inc/db.inc");          // BOINC database access
require_once("$BOINC_html/inc/util.inc");        // BOINC utilities

handle_debug_level(); 
handle_user_level();
handle_auto_update();
handle_reset();


db_init();  

/***********************************************************************\
 * Action:
\***********************************************************************/

$next_url = get_destination();
$next_url = fill_in_url($next_url);


if( !isset($next_url) || empty($next_url) ) {
    $next_url = fill_in_url($this_dir."/index.php");
    debug_msg(2,"Destination URL: $next_url");
 }


/* Handle info posted to the form */

if( isset($_POST['posted']) ){
    $email_addr = strtolower(process_user_text(post_str("email_addr", true)));
    $passwd = stripslashes(post_str("passwd", true));
    $user = lookup_user_email_addr($email_addr);
    if ( !$user ) {
        $authenticated=FALSE;
        add_message("No account found with email address '$email_addr'",
                    MSG_ERROR);
    }
    else { 
        $passwd_hash = md5($passwd.$email_addr);
        if( $passwd_hash != $user->passwd_hash ) {
            $authenticated=FALSE;
            add_message("No account found with email address '$email_addr'",
                        MSG_ERROR);  // same message either way, for security
            add_message(" If you've forgotten your password then follow
                the 'Forgot Password?' link to change your password");
        }
        else {
            $authenticated=TRUE;
            $authenticator = $user->authenticator;
            $_SESSION["authenticator"] = $authenticator;
            $_SESSION["i2u2_auth"] = $authenticator;   // I2U2 co-existence mod -EAM 21Jun2006
            $_SESSION["boinc_auth"] = $authenticator;   // I2U2 co-existence mod -EAM 21Jun2006
            if ($_POST['send_cookie']) {
                setcookie('auth', $authenticator, time()+3600*24*365, "/");
                setcookie('i2u2_auth', $authenticator, time()+3600*24*365, "/"); // I2U2 mod -EAM 21Jun2006
            }

        }
    }
 }

if( $authenticated ) {
    Header("Location: relay.php?next_url=$next_url");
    exit(0);
 }


// Set up form:

$came_from = basename($_SERVER['HTTP_REFERER']);

if($came_from == "auth_required.php" || $came_from == "index.php"
                                   || $came_from == "login.php" ){
    $came_from="";
 }

if( empty($came_from) ){
    add_message("Please log in with your personal account and password");
 }

if( !empty($came_from) ){
    add_message("Refered here by:  $came_from ");
 }

if( !empty($next_url) && !empty($came_from) ){
    add_message("The functionality you have requested requires that you
        log in.");
 }


/***********************************************************************\
 * Display Page:
\***********************************************************************/

$title="Login";
html_begin($title);
title_bar($title);
controls_begin();

start_table();
////row1("Log in with email/password");////
row2("Email address:", "<input name=email_addr size=40>");
//TODO: prefix the URL for get_passwd.php as appropriate
row2("Password:<br>
     <font size=-2><a href='/get_passwd.php'>Forgot password?</a></font>",
     "<input type='password' name='passwd' size='40'>"
     );
row2("Stay logged in on this computer",
     "<input type='checkbox' name='send_cookie' checked>"
     );

if( $debug_level>1 && !empty($came_from) ){
    row2("Refered by", $came_from);
 }
if( $debug_level>1 && !empty($next_url) ){
    row2("Next destination", $next_url);
 }


row2("", "<input type=submit name=mode value='Log in'>");

$user=$logged_in_user;
if ($user) {
    row1("Log out");
    row2("You are logged in as $user->name",
         "<a href='logout.php'>Log out</a>" );
 }
end_table();
echo "
        <input type='hidden' name='next_url' value='$next_url'>
        <input type='hidden' name='posted' value='posted'>
        ";

// if JavaScript is enabled then jump to e-mail address field
echo "
        <script> document.login.email_addr.focus(); </script>
    ";

controls_end();

/*******************************
 * DONE:
 */


tool_footer();
html_end();
?>
