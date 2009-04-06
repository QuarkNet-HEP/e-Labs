<?php
/***********************************************************************\
 * Authentication is Required - user chooses which option
 *
 * We give the user a choice of a guest login (on tekoa) or a user 
 * login (on discussion site).
 * We pass on final destination as next_url=...
 *
 *
 * Eric Myers <myers@spy-hill.net  - 9 February 2007
 * @(#) $Id: auth_required.php,v 1.23 2008/03/20 20:39:17 myers Exp $
\***********************************************************************/

require_once("macros.php"); 


/***********************************************************************\
 * Action: (no output allowed until we begin page, below)
\***********************************************************************/

/* We pass on just path part of destination */

$next_url = get_destination();

if( $hostname != "tekoa" ) {
  $dest_parts = parse_url($next_url);
  $next_url  = $dest_parts['path'];
 }



if( !isset($next_url) || empty($next_url) ) {
    $next_url = "$this_dir/index.php";
    debug_msg(2,"Destination URL: $next_url");
 }


/*  Check but do not require authentication here (that's the point of being 
 *  here) or any other handling of settings.  They have to login first. 
 *  But if they are in fact already authenticated, then pass them along...
 */

$authenticated = check_authentication();
if( $authenticated ){
    header("Location: relay.php?next_url=$next_url ");
    exit(0);
 }


/* Construct links for user and guest login */

$guest_url  = dirname($self)."/auth/basic_auth.php";
$guest_url .= "?next_url=$next_url";

$login_url  = dirname($self)."/login.php";
$login_url .= "?next_url=$next_url";



/***********************************************************************\
 * Display Page:
\***********************************************************************/

html_begin("Authentication Required");

echo "<P>
        You must login to use the LIGO Analysis Tool.
        <P/>\n";

echo "<center>
        <h2>
      You can access the LIGO Analysis Tool in two different ways:
        </h2>
    <TABLE width=75% border='11' cellpadding='17' bgcolor='lightgreen'><TR>\n";

echo "<TD width='47%'>
<h3>Use an Individual Account</h3>

  <a href='$login_url'>
  <img src='img/Shadow_user.gif'
       align='center'  alt=''  title='user account'></a><br/>

   <p>
  If you have a <b>personal I2U2 account</b> then you can login with
  that, and use the logbook/discussion site as well as the Analysis Tool. 

  <P align='RIGHT'>
  <a href='$login_url'>User Login</a>

</TD>\n";


echo "\n\n<TD></TD>\n\n";


echo "<TD width='47%'>
<h3>Use a Guest Account</h3>

  <a href='".$guest_url."'>
  <img src='img/Shadow_guest.gif'
       align='center'  alt='' title='guest account'></a><br/>
  <p>
  If you know the proper password, you can log-in with a <b>guest
  account</b> to use just the Analysis Tool.

  <P align='RIGHT'>
  <a href='".$guest_url."'>Guest Login</a>

</TD>
</TR></TABLE>
</center>\n";


echo "<P>
  Using your personal account is prefered, if you have one,
  because then you will also be able to use other
  features of the site, such as the logbook and glossary.
  But using your personal account is not required to use the Analisys Tool.
  ";


// testing....

echo "<hr><font color='grey'>
  After you log in you will be sent to 
  <blockquote>$next_url</blockquote>
 </font>\n";


tool_footer();
html_end();

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: auth_required.php,v 1.23 2008/03/20 20:39:17 myers Exp $";
?>
