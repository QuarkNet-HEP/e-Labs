<?php
/***********************************************************************\
 *  project/home_page.php - main page for the I2U2 Discussions project.
 *  
 *  @(#) $id: index.php,v 1.1 2004/06/10 12:04:02 myers exp myers $
\***********************************************************************/

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/news.inc");
require_once("../inc/cache.inc");
require_once("../inc/uotd.inc");
require_once("../inc/sanitize_html.inc");

require_once("../project/project.inc");


// Uncomment this and at the bottom if page needs to be cached for performance
//start_cache(index_page_ttl);

// project configuration (to test for disabled accounts...)
$config = get_config();

// first see if the database is up.  Later use $dbrc below to prevent
// some things from showing if it is down, but the page then still works.


$dbrc =  db_init_aux();

$authenticator = init_session();
$logged_in_user = get_logged_in_user(false);
$logged_in_user = getForumPreferences($logged_in_user);
if( $logged_in_user ) $username = $logged_in_user->name;


/**************************
 * Begin:
 */

home_page_header();


// E-Lab selector IS DISABLED 

if ( 0 ) { 

// Quick Links to the e-Labs

echo "<TABLE width='98%' border='0' align='CENTER' ><tr><td>\n";

if ( !empty($username) ) echo "Hello, $username! &nbsp;&nbsp; ";

echo "Please select your e-Lab:
<TABLE align='center' class='e-labs_main' width='85%'  >
   <tr>
      <TD ALIGN=CENTER valign='TOP'>
         <a href='elab/cosmic/'>
	     <img src='/images/Cosmics.gif' border=0 height='64'
              title='QuarkNet Cosmic Ray detector array e-Lab'  
              alt='[Cosmic Rays e-lab]'></a>
        <br/> Cosmic Rays
        </TD>

      <TD ALIGN=CENTER valign='TOP'>
         <a href='elab/cms/'>
	     <img src='images/USCMS_logo.jpg'  border=0 height='64'
              title='Compact Muon Solenoid experiment at the LHC at CERN'
              alt='[CMS e-Lab]'></a>
        <br/> CMS
        </TD>
      <TD ALIGN=CENTER valign='TOP'>
         <a href='/elab/ligo/'>
  	     <img src='images/LIGOlogo.gif' border=0 height='64'
              title='Laser Interferometer Gravitational-wave Observatory'
              alt='[LIGO e-lab]'></a>
        <br/> LIGO
        </TD>
 
      <TD ALIGN=CENTER valign='TOP'>
         <a href='/elab/atlas/'>
	   <img src='images/ATLAS_logo.jpg' border=0 height='64'
            title='ATLAS experiment at the LHC at CERN'
            alt='[ATLAS e-lab]'></a>
        <br/>
        ATLAS
        </TD>

	<!--
      <TD ALIGN=CENTER valign='TOP'>
         <a href='/elab/star/'>
	   <img src='images/starimage.gif' border=0 height='64'
            title='STAR experiment at the RHIC at Brookhaven'  
            alt='[STAR e-lab]'></a>
        <br/>
        STAR
        </TD>
	-->

	<!--
      <TD ALIGN=CENTER valign='TOP'>
         <a href='/ilab/adler/'>
	   <img src='images/adlerlogo-bw.gif'  border=0 height='64'
            title='Adler Planetarium interactive lab'  
            alt='[Adler i-lab]'></a>
        <br/>
        Adler
        </TD>
	-->

   </TR>
  </TABLE>
  ";
  echo "</TD></TR></TABLE>\n\n";
}// e-lab selector



// Begin double columns:

echo "
      <TABLE CELLPADDING=8 BORDER=3 WIDTH=100% ALIGN=CENTER>
      <TR>
      <TD width='42%' valign='TOP'>
        <TABLE CELLPADDING=8 CELLSPACING=5 BORDER=1>\n";


if ( 0 && !$dbrc ) {
    $profile = get_current_uotd();
    if($profile ) {
        echo "<tr>
            <td valign=top bgcolor='#F4EEFF'>
            <h3>User of the day</h3>
        ";
        $user = lookup_user_id($profile->userid);
        echo uotd_thumbnail($profile, $user);
        echo user_links($user)."<br>";
        echo sub_sentence(strip_tags($profile->response1), ' ', 150, true);
        echo "</td></tr>\n";

    }
 }




/********************
 * STATUS AND  NEWS: 
 *    A status box is shown over the News if needed.  It can contain
 * automated messages (like "you need to verify your e-mail address")
 * and it can also show the contents of a file, if it exists, or
 * transclude from a wiki page.  
 */

$status_txt="";

if( 0 && file_exists( STATUS_TEXT ) ){
  $status_txt = file_get_contents( STATUS_TEXT );
}
else {// Try to get the page contents from a wiki article:
  // TODO: strip HTML comments
  $status_txt = trim(get_wiki_article("I2U2:Site Status"));
}


/* Status of server components: database, feeder, scheduler
 */

$errors=0;

 if ( $dbrc ) {
    $errors++;
    $status_txt .= "<LI><font color=RED>
      <b>The ".PROJECT." database server is currently shut down.  
        (Status: $dbrc)
    You can browse our web site but you cannot 
        manage your account, view statistics, or use the message
    forums. 
    Please come back later.  Thanks.
      </b></font><P>\n  ";
 }

if (  file_exists("../../stop_sched") ) {
    $errors++;
    $status_txt .= "<LI><font color=RED>
        <b>The ".PROJECT." scheduler is currently shut down.
    No work is being assigned.
    </b></font><P>\n     ";
 }

if (  file_exists("../../stop_web") ) {
    $errors++;
    $status_txt .= "<LI><font color='RED'>
      <b>The ".PROJECT." web site is now turned off,
        most likely for maintenance or testing.
        Please come back later.
      </b></font><P>\n       ";
 }

if (  file_exists("../../cgi-bin/.htaccess") ) {
    $status_txt .= "<LI><font color='ORANGE'>
        <b>Access to the ".PROJECT." scheduler is 
          restricted to our local domain for testing.
        </b></font><P>\n     ";
 }


/* User status
 */
if($user && $user->email_validated == 0) {
    $status_txt .= "<LI><font color='GREEN'>
        <b>Your e-mail address needs to be verified.</b>
        </font><P>\n        ";
 }


if( $status_txt ){
  echo "<tr>
     <TD class='frontpage_status'>
       <b>Status</b>
	<P>
	$status_txt
     </TD></tr>\n";
}




/*******************************
 * News:
 */

echo "<TR>\n";


if( file_exists("../user_profile/news_frontpage.html") ){
    include("../user_profile/news_frontpage.html");
 }
 else if( file_exists("../user/news_frontpage.php") ){
    include("../user/news_frontpage.php");
 }
 else {
     error_log("! ERROR: cannot create front page news box."); 
     echo "<tr><TD class='frontpage_news'>
           <h3>"  .tr(NEWS). "</h3>
           The news is currently unavailable
           </td></tr>\n";
 }




// Next column of double coumns

echo " 
     </TABLE>
     </TD>
     <TD class='frontpage' valign=top  bgcolor=ffffff>\n";


//  Overview: description of project is read from a file

$overview_text="";

if ( 0 && file_exists( OVERVIEW )) {
  $overview_text=  file_get_contents( OVERVIEW );
}
else {// Try to get the box contents from a wiki article:
  $overview_text = trim(get_wiki_article("I2U2:Site Overview"));
}



if( $overview_text ){
    echo "
     <TABLE class='overview' align='center' >
      <TR><TD>\n";
    echo  $overview_text;
    echo "</TD></TR>
       </TABLE>\n";
  }


// GENERERAL INFO & NEW USERS:

if( empty($username) ){

echo "
    <h3><font color='GREEN'>What is I2U2?  What are e-Labs?</font></h3>
    <UL>
    <li><a href='project_overview.php'>About I2U2 and its research goals</a>

    <LI><a target='_blank'
           href='http://ed.fnal.gov/e-labs/'>What is an 'e-Lab'?</a>
           <img src='/images/external.png'>

    <LI>Interested?  Contact us at
	<a href='mailto:e-labs@fnal.gov'>e-labs@fnal.gov</a>


	<P>
     <LI> Visit the <a href='/elab/cosmic'>Cosmic Rays e-Lab</a>
     <LI> Visit the <a href='/elab/cms'>CMS e-Lab</a>
     <LI> Visit the <a href='/elab/ligo'>LIGO e-Lab</a>


    </UL>      
        \n";



echo "
    <h3><font color='RED'>How to get started:</font></h3>
    <OL>
    <li><a href='create_account_form.php'>Create an account</a>
        ";

//TODO:  mention invitation code if they are required

 if( defined("INVITE_CODES") ) {
     echo "(Invitation code required)";
 }

 echo "
    <LI><a href='home.php'>Fill in your profile</a>
    <LI><a href='edit_forum_preferences_form.php'>Add your picture (avatar)</a>
    <LI><a href='forum_index.php'>Join the discussion...</a>
                (or come back here and select your e-Lab)
    </OL>
     ";
 }



// USER FUNCTIONS: 

if (!$dbrc ) {

    echo "
	<h3>Participants</h3>
	<ul>
	    ";

    $username = get_login_name();
    if( empty($username) ) {
      echo "
	<LI><a href='login_form.php'>Login to your account</a>
      ";
    } else {

    echo "
	<li><a href='home.php'>Your account</a> 
		- modify preferences or profile
	";
    }


   // GENERERAL INFO & NEW USERS:


    if( empty($username) ) {// not logged in?
        if( !$dbrc && !parse_bool($config, "disable_account_creation")) {
            echo " 
       <li><a href='create_account_form.php'>Create an account</a>
       ";
        }
        else {
            echo " 
       <li> (Account creation is disabled for now)
       ";
        }

    }
    else { // logged in.
        echo "
        <li><a href='logout.php'>Logout from your account</a>
        <li><a href='team.php'>School </a>
                - set your school affiliation\n";
	}


    // Admins get the control panel link here too.


    if( user_has_permission('admin') ){ //BROKEN?
        echo "<LI><a href='ops/'>Control Panel</a>
                - manage users, news,  and the site in general\n";
    }

    echo "</ul>\n\n";
 }



//  HELP DESK, MESSAGE FORUMS, PARTICIPANT PROFILES:

if (!$dbrc) {
  echo "

    <h3>Community</h3>
	";


  if(0) { // UOTD in left column (OFF)

    $profile = get_current_uotd();
    if ($profile) {
      echo "<TABLE ALIGN=CENTER WIDTH=90% BORDER=1 CELLSPACING=3><TR><TD>
	    <TABLE ALIGN=CENTER WIDTH=100% BGCOLOR=FFDDFF BORDER=0>
		<TR><TD ALIGN=CENTER><b> User of the day</b></TD></TR>
		<TR><TD ALIGN=CENTER>\n";

      $user = lookup_user_id($profile->userid);
      echo uotd_thumbnail($profile, $user);
      echo user_links($user)."<br>";
      echo " </TD></TR></TABLE>\n</TD></TR></TABLE>\n";
    }        
  }

  echo "
    <ul>
    <li><a href='forum_index.php'>Meeting and Discussion Rooms </a>
    <li><a href='forum_help_desk.php'>User Help Desk: Questions and Answers</a>
    <li><a href='profile_menu.php'>Participant Profiles</a>
    <LI><a href='Calendar.php'>I2U2 Calendar</a>
    </ul>
    ";
}




// Other on-site links

echo "
    <h3> General Resources </h3>
    <UL>
      <LI><a href='library/' >Library</a> 
      <LI><a href='cosmic/library/'>QuarkNet Fellows Library</a>
      <LI><a href='Help.php'>Help! </a>
      <LI><a href='HelpDeskRequest.php'>Submit a bug report or Help Desk request</a>
";

if( $logged_in_user && is_Developer($logged_in_user) ) {
    echo "
        <LI><a href='http://bugzilla.mcs.anl.gov/i2u2/'
                target='_blank'>Bugzilla</a> - trouble and task ticket system
        ";
 }

echo "
     </UL>
        ";

echo "
    <h3> LIGO Resources </h3>
    <UL>
";



/**
 * Different links to the Analysis Tool for different types of users
 */


if( $logged_in_user && is_Developer($logged_in_user) ) {
    echo "
      <LI>Bluestone, the LIGO Analysis Tool (TLA):
        <UL>
        <LI><a href='http://tekoa.ligo-wa.caltech.edu/tla' >Production</a>
                [stable]
        <LI><a href='http://i2u2.spy-hill.net/tla_test/'>Testing</a>@Spy Hill
                [beta testing, semi-stable]
        <LI><a href='http://tekoa.ligo-wa.caltech.edu/tla_test/'>Testing</a>@Hanford
                [beta testing, semi-stable]
        <LI><a href='http://tekoa.ligo-wa.caltech.edu/tla_dev/' >Development</a>@Hanford
                [alpha testing, possibly unstable]
        <LI><a href='http://i2u2.spy-hill.net/tla_dev/' >Development</a>@Spy Hill
                [alpha testing, possibly unstable]
     </UL>
        ";
 }
elseif( $logged_in_user &&
        (user_has_permission('teacher') || user_has_permission('admin') )){
    echo "
      <LI>Bluestone, the LIGO Analysis tool (TLA):
        <UL>
        <LI><a href='http://tekoa.ligo-wa.caltech.edu/tla' >Production</a>
                [stable]
        <LI><a href='tla_test/'>Testing</a>
                [semi-stable]
        </UL>
     </UL>
        ";
        }
 else {
        echo "
        <LI><a href='http://tekoa.ligo-wa.caltech.edu/tla' >Bluestone,
                the LIGO Analysis tool (TLA):</a> \n";
 }


echo "
      <LI><a href='http://www.ligo-wa.caltech.edu'>LIGO Hanford Observatory (LHO)</a>
      <LI><a href='http://ilog.ligo-wa.caltech.edu/ilog'>LIGO Hanford iLogs</a>
      <LI><a href='elab/ligo/'/>LIGO e-Lab<a> (under construction)


     </UL>

	";


/* Off-site links (these open a new window) */

echo "
    <h3>I2U2 Links </h3>
    <p>
    <UL STYLE='list-style-image: url(/images/fnal-ed.jpg)'>
    <LI><a href='http://www.i2u2.org' target='_blank'>I2U2 Home</a>
    <LI><a href='http://quarknet.fnal.gov/' target='_blank'	>QuarkNet</a>
    <LI><a href='http://www-ed.fnal.gov/uueo/i2u2.html' target='_blank'>About I2U2</a>
        - from the FNAL Education Office
    <LI><a href='http://www-ed.fnal.gov/' target='_blank'>FNAL
                Education Office</a>
     ";

//if( $logged_in_user && is_Developer($logged_in_user) ) {
    echo "
    <LI><a href='http://www.ci.uchicago.edu/wiki/bin/view/I2U2/'
           target='_uchicago'>I2U2 Developer's Notebook</a> (wiki at U. Chicago CI)
        ";
// }
echo "
    </UL>
";

echo "
    </UL>
";


//project_community();

echo"
<pre>


</pre>
    <p align='right'>
    <!-- Powered  by&nbsp; --><a href='http://boinc.berkeley.edu'
         ><img align='middle' border=0
           alt='Powered by BOINC'
           title='Forum software from the Berkeley Open Infrastructure for Network Computing (BOINC)'
		   src='/images/pb_boinc.gif'></a><br/>
        BOINC&nbsp;Forums

    </p>
    ";


// End of double columns

echo "\n   </tr></table>\n";




// SPONSOR LIST

if(file_exists('../project/sponsors.html')){
  include '../project/sponsors.html';
}


page_tail_main(false);

//end_cache(INDEX_PAGE_TTL);

?>
