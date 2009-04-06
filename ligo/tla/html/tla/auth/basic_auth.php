<?php
/***********************************************************************\
 * auth/index.php - trigger HTTP Basic authentication for the 
 *
 * We want our users to be able to use the Analysis Tool either via
 * the BOINC authentication mechanism for individual user accounts,
 * OR via a guest login based on HTTP Basic Authentication.  Allowing
 * both is tricky, so here is the trick:   If you want to login as a guest 
 * you are redirected to this subdirectory (tla/auth), which is protected by 
 * a .htaccess file and thus triggers authentication via your browser.
 * Assuming that works, we save the username/password/type in $_SESSION
 * so that they are available as one possible proof of authentication
 * for the rest of the site.  If you know a better way to do this easily,
 * I'd love to hear about it.
 *
 * Eric Myers <myers@spy-hill.net  - 9 February 2007
 * @(#) $Id: basic_auth.php,v 1.5 2008/03/20 20:39:18 myers Exp $
\***********************************************************************/

chdir("../");  // since we were down in a subdirectory
require_once("macros.php");


/***********************************************************************\
 * Action:
\***********************************************************************/

$next_url = $_GET['next_url'];

if( isset($_POST['next_url']) ) {
  $next_url = $_POST['next_url'];
}

if( !isset($next_url) ) {
  $next_url="$this_dir/index.php";
}

if( basic_HTTP_auth() ){
   header("Location: ".$next_url);
   exit(0);
 }



/***********************************************************************\
 * Display Page:
\***********************************************************************/

html_begin("Authentication Failed");


echo "<center><h2>Something broke!</h2></center>

You should not be able to see this page, it should have just
redirected you to the right page once you gave the correct password.
And if you didn't give the correct password then you should not be 
able to read this.  Pretty strange, eh?

";


echo "<P>

You can try to get back to what you were doing by choosing:
<UL>
<LI> <a href='/'>The Main Page</a>
<LI> <a href='$next_url'>$next_url</a> (where you were headed for)
</UL> 

You should be able to log in using a personal user account.
Only access through the guest accounts is broken 
(at least we hope that is all that is broken).
";


echo "<P>
If you don't mind, could you please report this to the developers
or site managers so that they know something is wrong? 
Please print this page and give it to them, along with anything
about what you were doing which might seem relevant.
";

echo "</blockquote>

Sorry for the inconvenience!
\n";


if($debug_level>1){
    echo "<blockquote><pre>
        Type: ". $_SERVER['AUTH_TYPE'] ."
        User: ". $_SERVER['PHP_AUTH_USER'] ."
        Pass: ". $_SERVER['PHP_AUTH_PW'] ."
	URI:  ". $_SERVER['REQUEST_URI'] ."
        </pre></blockquote>\n";
 }

html_end();

?>
