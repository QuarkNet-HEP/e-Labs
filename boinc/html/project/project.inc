<?php
/***********************************************************************\
 *  project.inc - project specific preferences and settings
 * 
 * This file contains configuration settings for the project.
 * See also extras.php, which contains extra function definitions
 * above and beyond what is customizable within BOINC.
 *
 *
 * @(#) Last changed: -EAM 19Oct2006
\**********************************************************************/

require_once("../project/extras.php");

// Primary configuration settings:
//
define("PROJECT", "I2U2");
define("MASTER_URL", "http://www13.i2u2.org/");
define("URL_BASE", "http://www13.i2u2.org/");

define("IMAGE_PATH", "../user_profile/images/");
define("IMAGE_URL", "user_profile/images/");
define("PROFILE_PATH", "../user_profile/");
define("PROFILE_URL", "/user_profile/");
define("LANGUAGE_FILE", "languages.txt");
define("STYLESHEET", "i2u2.css");
define("COPYRIGHT_HOLDER", "Eric Myers, for the I2U2 Confederation");
define("SYS_ADMIN_EMAIL", "i2u2-admin@i2u2.spy-hill.net");
define("EMAIL_FROM",    "I2U2 forums <i2u2-admin@i2u2.spy-hill.net>");
define("POST_REPORT_EMAILS", "myers@spy-hill.net");

define("NO_COMPUTE",1);  // Defined for projects just using forums
 

// limit the age of helpdesk postings (as opposed to discussion forums) 
//
define("HELP_DESK_AGE", 90);


// For the home page:
//
define("OVERVIEW", "../project/overview.html");
define("STATUS_TEXT", "../project/status.html");

// News:
//
$news_file="../project/project_news.inc";
$newsbox_file="../user_profile/news_frontpage.html";

define("CURRENT_NEWS_ITEMS", 5);         // how many items to display



// Where to send abuse reports, etc..
//
$forum_post_reporting_admin->email_addr="i2u2-admin@i2u2.spy-hill.net"; 


/**
 * If ACCESS_CODE_REGEXP is defined then account creation is restricted
 * to the web pages only, and only to those who can enter a valid 
 * invitation code.  This is compared against user input as a regular 
 * expression so that you can use multiple invitation codes.  Comment out
 * this line to leave this undefined and there are no restrictions. */


// TODO: make InvitationCodes[] an array of possible codes for
//  different classes of users...

//define("INVITE_CODES", "/3Dspecs|aardwulf/");  // off 21Sep2006 -EAM
// @(#) Last changed: -EAM 23August2007

$FellowsInvite='HelloFellow';

define("INVITE_CODES", "/ndqc|inquiry|sjhsrc|parabola|ubiquitous|curious|"
	."spud-gun|".$FellowInvite."|s2s3data/");


// Keywords for forum classification
//
$post_keywords=array_of_values(
   array(" ", "The Basics", "A-1: Describe  ", "A-2: Investigate ", 
              "A-3: Proposal ", "B: Figure it Out ", "C: Tell Others",
         "Analysis Tool", "Data Acquisition", "Data Monitor",
         "calibration", "commissioning", "maintenance", "debugging", 
         "feature request", "complaint" ));


// We will need to know the current `hostname` in several places
// It may not be the same as the SERVER_NAME.  
//
$hostname=trim(exec('hostname -s'));
$local_server = $_SERVER['SERVER_NAME'];
$hostname=trim($local_server);



// project_banner() is displayed at the top of every page 
//
function project_banner($title) {
    echo "\n<link rel='shortcut icon' type='image/x-icon' href='/favicon.ico'/>\n";
    echo "<link rel=stylesheet type='text/css' href=" .STYLESHEET. ">";

    project_masthead();   

    echo "
     <TABLE WIDTH=100% class='noborder' ><TR>
       <TD ALIGN=LEFT><font size=-1>
          &nbsp;
            </TD>
           <TD ALIGN=RIGHT VALIGN=TOP>
        \n";

    // If the page is cached, show cache info (someday an image?)
    // otherwise show login info or not, as appropriate 

    global $cached_max_age; // set by start_cache() -EAM 22Nov2004
    if( isset($cached_max_age) ) {
        $ttl = $cached_max_age/60;
        // soemday put a treasure chest image here :-)
        echo "<font size=1 face=Helvetica color=bbbbbb>CACHED &nbsp;"
            . date("g:i A T") ." on ".   date("j M Y ") . "
          (updated every ". $ttl. " minutes)
           </font>
        ";
    }
    echo "</TD></TR></TABLE>";

    if($title) {
        echo "<H1> $title</H1> \n";
    }

    echo "<P>";
}



// The masthead is displayed at the top of EVERY page (provided you
// invoke it so in project_banner() from project.inc)
//
function project_masthead(){
    global $hide_user;
    global $hostname;


    echo "
     <TABLE WIDTH='100%'  class='noborder' bgcolor='white'><TR>
       <TD   style='border: 1px;'>
       <TABLE width='100%'  class='noborder bgcolor='white'><TR>

        <TD width=10% ALIGN=LEFT  class='noborder'>
          <a href='/'>
          <img src='/images/UUEOb.gif' height='125' align='top'
               alt=''
               title='go to the main page...'
    	       border='0'></a>
        </TD>

        <TD VALIGN='TOP' ALIGN=LEFT  class='noborder'>
               <h1><font size='5' ><b><i>
            Interactions in <br>
            Understanding the Universe
            </i></b></font></h1>
            <hr width='100%'>
            <h2><font size='3' color='darkblue' ><i>
      Real science education with real data and real experience
            </i></font>
        </h2>

        </TD>

       <TD width='25%' valign='TOP' align='RIGHT'>\n";
    if( isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
        echo "&nbsp;";
    }
    else {      
        // need to see if the person is authenticated, cookie or not
        $authenticator = init_session();
        echo "<font size='1'>";
        $logged_in_user = get_logged_in_user(false);
        show_login_name($logged_in_user);
        echo "</font>\n";
    }
    echo "\n</TD>
        </TR></TABLE>
        </TD></TR>
     </TABLE>       ";
    project_menu_bar();
 }



function project_menu_bar(){
    echo "
      <TABLE WIDTH=100% class='noborder' BGCOLOR='#888888'>
        <TR>
    <TD class='masthead'><a class='masthead' href='/'>"
        .tr(PIRATES_MENU_HOME). "</a></TD>
        ";

    $user = get_logged_in_user(false);
    if(!is_Administrator($user)) {
        echo "
    <TD class='masthead'><a class='masthead' href='/Help.php'>"
            .tr(PIRATES_MENU_HELP). "</a></TD>";
    }
    else {
        echo "
    <TD class='masthead'><a class='masthead' href='/ops'>"
            .tr(PIRATES_CONTROLS). "</a></TD>";
    }


    echo "
    <TD class='masthead'><a class='masthead' href='/forum_help_desk.php'>"
        .tr(PIRATES_MENU_QA). "</a></TD>
	";

    echo "
    <TD class='masthead'><a class='masthead' href='/library'>"
        ."Library". "</a></TD>
	";

    echo "
    <TD class='masthead'><a class='masthead' href='/forum_index.php'>"
        . tr(PIRATES_MENU_FORUMS). "</a></TD>
    <TD class='masthead'><a class='masthead' href='/home.php'>"
        .tr(PIRATES_MENU_ACCOUNT). "</a></TD>
        </TR>
       </TABLE>\n    ";
}


function prev_project_menu_bar(){
    echo "
      <TABLE WIDTH=100% BORDER=0 BGCOLOR=#888888>
        <TR>
    <TD class=masthead><a class=masthead href='/'>Main Page</a></TD>
    <TD class=masthead ><a class=masthead href='/forum_help_desk.php'>Help Desk</a></TD>
    <TD class=masthead ><a class=masthead href='/library'>Library</a></TD>
    <TD class=masthead><a class=masthead href='/forum_index.php'>Meeting/Discussion Rooms</a></TD>
    <TD class=masthead><a class=masthead href='/home.php'>Your Account</a></TD>
        </TR>
       </TABLE>
    ";
}



function home_page_header() {
    global $styleSheet, $rssname, $rsslink, $rsstype;

    if(empty($styleSheet)) $styleSheet = URL_BASE . STYLESHEET;
    if(empty($rssname)) $rssname = PROJECT . " News ";
    if(empty($rsslink)) $rsslink = URL_BASE . "rss_main.php";
    if(empty($rsstype)) $rsstype = 'application/rss+xml';

    echo "<html><head><title>".strip_tags(PROJECT)."</title>
        <link rel=stylesheet type=text/css href=\"$styleSheet\">
        <link rel='alternate' type='$rsstype'
              href='$rsslink' title='$rssname' />
        </head>";
    echo "<body bgcolor=ffffff>";

    project_masthead();
}


function page_head($title, $java_onload=null, $title_plain=null, $prefix="") {
    global $caching;
    global $styleSheet, $rssname, $rsslink, $rsstype;

    if( empty($styleSheet) ) $styleSheet = URL_BASE . STYLESHEET;
    if( empty($rssname) )    $rssname = PROJECT . " RSS 2.0";
    if( empty($rsslink) )    $rsslink = URL_BASE . "rss_main.php";
    if( empty($rsstype) )    $rsstype = "application/rss+xml";

    if (defined("CHARSET")) {
        header("Content-type: text/html; charset=".tr(CHARSET));
    }

    if (!$caching) {
        header ("Expires: Mon, 26 Jul 1997 05:00:00 UTC");    // Date in the past
        header ("Last-Modified: " . gmdate("D, d M Y H:i:s") . " UTC"); // always modified
        header ("Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0");  // HTTP/1.1
        header ("Pragma: no-cache");                          // HTTP/1.0
    }
    
    echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd\">\n";

    if (!$title_plain) {
        echo "<HTML>\n<HEAD><title>".strip_tags($title)."</title>";
    } else {
        echo "<HTML>\n<HEAD><title>".strip_tags($title_plain)."</title>";
    }
    echo "
        <link rel=stylesheet type=text/css href=\"$styleSheet\">
        <link rel='stylesheet' type='text/css' href='" . URL_BASE . "new_forum.css'>
        <link rel='alternate' type='$rsstype' title='$rssname' href='$rsslink' />
        </HEAD>\n";

    if ($java_onload){
        echo "<body bgcolor=ffffff onload=\"".$java_onload."\">"; }
    else {
        echo "<body bgcolor=ffffff>";
    }
    display_cvs_versions();
    project_banner($title, $prefix);
}






/* project_footer() is displayed at the bottom of every page */

function project_footer($show_return, $show_date) {
    global $gWikiTitle;           // titles of any transcluded pages
    global $Path_to_wiki;         // top level path to the wiki

    echo "\n<!-- Footer -->\n";
    if ($show_return) {
        echo "<P><div class='footer right more'>
        <a href='".URL_BASE."'>Return to ".PROJECT." main page &gt;&gt</a>
        </div><br clear='right'>\n\n";
    }

    project_menu_bar();

    echo "\n<hr noshade size=1>\n";

    if ( !empty($gWikiTitle) ){
      $wiki_url ="http://" . $_SERVER['SERVER_NAME'] . $Path_to_wiki . "/";
      echo "<div class='edit_link'>";
      foreach ($gWikiTitle as $title ){
        $edit_url = $wiki_url . "index.php/$title";
        echo "<a href='$edit_url'>$title</a> ";
      }
      echo "</div>\n";
    }

    echo " <center> Copyright &copy; " .date("Y ") .COPYRIGHT_HOLDER.
       "</center>\n\n";

    if ($show_date) {
        echo "<div class='footer left'>
                Generated " .time_str(time()). "</div>\n\n";
    }

    // If the page is cached, show cache info (someday an image?)
    // otherwise show login info or not, as appropriate

    global $cached_max_age; // set by start_cache() -EAM 22Nov2004
    if( isset($cached_max_age) ) {
        $ttl = $cached_max_age/60;
        echo "<p align='right'>

                <font size='1' color='grey' face='Helvetica' >cached
                &nbsp;"
            . date("g:i A T") ." on ".   date("j M Y ") . "
          (updated every ". time_diff($ttl*60). " ) </font></p>
        ";
    }
    display_cvs_versions();  // CVS tags, hidden in comments.

}


/**
 * Profile headings 
 */

function show_profile_heading1() {
    return "General background.";
}

function show_profile_question1() {
    return "
        Tell us about yourself.   What should other participants in " 
        .PROJECT. " know about you?   
    <br/>
    You can put anything here which you think might be relevant.  
    Some possibilities are:
    <OL>
       <LI> Your schoool or institutional affiliation.
       <LI> Relevant professional background.
       <LI> Personal information that will tell other participants
            more about you as an individual, such as your home town,
           your hobbies, or other background or interests.
      </OL>
    ";
}

function show_profile_heading2() {
    return "Role in " . PROJECT;
}

function show_profile_question2() {
    return "
        Tell us more about your personal role in " .PROJECT. ".
    <br/>
    Some possibilities are:
    <OL>
    <LI>    What part of the project are you working on?
        <LI>    What aspects of the project do you think are important
        or most interesting?  
    </OL>
    ";
}


function project_research_url() {
    return "/research.php";
}


function project_community() {
    echo "
    <h3>Other BOINC Projects</h3>
    <p>
    <UL>
    <LI><a href=http://einstein.phys.uwm.edu>Einstein@Home</a>
    - gravity waves

    <LI> <a href=http://setiweb.ssl.berkeley.edu>SETI@home</a>
    - search for ET
    <LI> <a href=http://predictor.scripps.edu>Predictor@home</a>
    - protein folding

    <LI> <a href=http://www.climateprediction.net/>ClimatePrediction.net</a> 
    - climate modeling 
    <LI><a href=http://athome.web.cern.ch/athome/>LHC@home</a> 
     - the Large Hadron Collider 

  </UL>
  <blockquote>
  A more complete (and growing) list may be found on the main BOINC website. 
  </blockquote>

    </UL>
";


    echo "<P><i>
    Don't forget International Talk Like a Pirate Day,
    September&nbsp;19th!
    </i></P>
    ";

}


/*****************************************************************/


function project_workunit($wu){
    echo "This is displayed on the workunit page";
}

function project_user_summary($user){
    // echo "Text here will go to the user summary page";
    echo " ";
}

function project_user_page_private($user){
    //    echo "Whatever is here is added to the private account page";
    echo " ";
}

function project_user_credit($user){
    if ($user->seti_nresults) {
        row2(
             "SETI@home classic workunits
            <br><font size=-2>as of 14 May 2004</font>",
             number_format($user->seti_nresults)
             );
    }
    if ($user->seti_total_cpu) {
        $x = number_format($user->seti_total_cpu/3600)." hours";
        row2(
             "SETI@home classic CPU time
            <br><font size=-2>as of 14 May 2004</font>",
             $x
             );
    }
}

?>
