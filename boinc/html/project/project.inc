<?php
/***********************************************************************\
 *  project.inc - project specific preferences and settings
 * 
 * This file contains configuration settings for the project,
 * and project customized functions (generally beginning with project_)
 * which are used in various places.  This file is read in by
 * every published page on the project.
 *
 * See also i2u2-stuff.php for more project-specific stuff, and
 * extras.php for more general additions beyond what BOINC provides.
 *
 * Last changed: -EAM 05May2009
 * @(#) $Id: project.inc,v 1.22 2009/06/24 17:44:31 myers Exp $
\**********************************************************************/

require_once("../project/roles.php");		// special_user stuff
require_once("../project/extras.php");		// Additions to BOINC
require_once("../project/i2u2-stuff.php");	// support for THIS project

require_once("../include/transclude.php");	// mashup support
if( !function_exists('debug_msg') ) {		// debugging support
    require_once("../include/debug.php");
}

require_once("../project/cosmic-stuff.php");	// support for THIS project
$elab = get_elab_from_URL();
if( !empty($elab) ) {
  require_once("../project/".$elab."-stuff.php");  // particular e-Lab
}


/************************************\
 * Primary configuration settings:
 */

define("PROJECT", "I2U2");
define("MASTER_URL", "http://".$_SERVER['SERVER_NAME']."/" );
define("URL_BASE",   "http://".$_SERVER['SERVER_NAME']."/" );

define("IMAGE_PATH", "../user_profile/images/");
define("IMAGE_URL", "user_profile/images/");
define("PROFILE_PATH", "../user_profile/");
define("PROFILE_URL", "/user_profile/");
define("LANGUAGE_FILE", "languages.txt");
define("STYLESHEET", "i2u2.css");
//define("COPYRIGHT_HOLDER", "Marge Bardeen, for the I2U2 Confederation");
define("COPYRIGHT_HOLDER", "");
define("SYS_ADMIN_EMAIL", "i2u2-admin@i2u2.spy-hill.net");
define("EMAIL_FROM",    "I2U2 forums <i2u2-admin@i2u2.spy-hill.net>");
define("POST_REPORT_EMAILS", "myers@spy-hill.net");

define("NO_COMPUTE",1);  // Defined for projects just using forums
 

// For the home page:
//
define("OVERVIEW", "../project/overview.html");
define("STATUS_TEXT", "../project/status.html");


// Forum settings, above and beyond BOINC
//
define('FORUM_KEYWORDS',1);
define('FORUM_ATTACHMENTS',1);
define('FORUM_MAX_AGE', 365);   // max age, in days


// limit the age of helpdesk postings (as opposed to discussion forums) 
//
define("HELP_DESK_AGE", 90);


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
//  different classes/roles of users...

//define("INVITE_CODES", "/3Dspecs|aardwulf/");  // off 21Sep2006 -EAM
// @(#) Last changed: -EAM 23August2007

$FellowsInvite='HelloFellow';

define("INVITE_CODES", "/ndqc|quarknet|inquiry|sjhsrc|parabola|ubiquitous|curious|"
	."spud-gun|".$FellowInvite."|s2s3data/");

// Keywords for forum classification
//
$post_keywords=array_of_values(
   array(" ", "The Basics", "A-1: Describe  ", "A-2: Investigate ", 
              "A-3: Proposal ", "B: Figure it Out ", "C: Tell Others",
	"Classroom Activity", 
         "Analysis Tool", "Data Acquisition", "Data Monitor",
         "calibration", "commissioning", "maintenance", "debugging", 
         "feature request", "complaint" ));


// We will need to know the current `hostname` in several places
// It may not be the same as the SERVER_NAME.  
//
$hostname=trim(exec('hostname -s'));
$local_server = $_SERVER['SERVER_NAME'];
$hostname=trim($local_server);

// This is used in wiki and forum extensions.  
// Base it on how we were called.

$BOINC_prefix = dirname($_SERVER['REQUEST_URI']);


/**************
 * page_head() begins a new page.  If not defined in project.inc then
 *             a generic default is used.
 */ 

function page_head($title, $java_onload=null, $title_plain=null, $prefix="") {
    global $caching;
    global $styleSheet, $rssname, $rsslink, $rsstype;
    global $gElab, $gStyleSheets;

    if (defined("CHARSET")) {
        header("Content-type: text/html; charset=".tr(CHARSET));
    }

    if( !$caching ) {
        header ("Expires: Mon, 26 Jul 1997 05:00:00 UTC");    // Date in the past
        header ("Last-Modified: " . gmdate("D, d M Y H:i:s") . " UTC"); // always modified
        header ("Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0");  // HTTP/1.1
        header ("Pragma: no-cache");                          // HTTP/1.0
    }
    
    echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd\">\n";

    if (!$title_plain) {
        echo "<HTML>\n<HEAD>\n<title>".strip_tags($title)."</title>\n";
    } else {
        echo "<HTML>\n<HEAD>\n<title>".strip_tags($title_plain)."</title>\n";
    }

    $elab = get_elab_from_URL();

    // Broswer icon
    //
    $favicon="/elab/$elab/teacher/library/blast_icon.gif";
    echo "     <link rel='shortcut icon' type='image/x-icon' href='$favicon' />\n";


    // RSS news link:
    //
    if( empty($rssname) )    $rssname = PROJECT . " RSS 2.0";
    if( empty($rsslink) )    $rsslink = URL_BASE . "rss_main.php";
    if( empty($rsstype) )    $rsstype = "application/rss+xml";
    if( $rsslink ) echo "
      <link rel='alternate' type='$rsstype' title='$rssname' href='$rsslink' />\n";

    // Style Sheets:
    //
    echo elab_stylesheets($elab,$styleSheet);

    echo "\n</HEAD>\n";

    // Additional JavaScript added to body...

    if ($java_onload){
        echo "<BODY onload=\"".$java_onload."\">"; }
    else {
        echo "<BODY>";
    }
    project_banner($title, $prefix);
    echo "\n\n<div id='maincontent'>\n";

}

function page_tail($show_date=false, $prefix="") {
    echo "\n</div id='maincontent'>\n";
    page_tail_aux(true, $show_date, $prefix);
}




/******************
 *  project_banner() is displayed at the top of every page. 
 */
function project_banner($title) {
  global $gElab;

    $elab = get_elab_from_URL();

    if( $elab=='cosmic') {
      require_once("../project/cosmic-stuff.php");
      cosmic_masthead($title);
      return;
    }
    if( $elab=='ligo') {
      require_once("../project/ligo-stuff.php");
      ligo_masthead($title);

      return;
    }
    if( $elab=='cms') {
      require_once("../project/cms-stuff.php");
      cms_masthead();
      return;
    }
    
    // General Page title (by default)

    i2u2_masthead();
    page_title($title);
}




function page_title($title){
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




/* project_footer() is displayed at the bottom of every page */

function project_footer($show_return, $show_date) {
    global $gWikiTitle;           // titles of any transcluded pages
    global $Path_to_wiki;         // top level path to the wiki
    global $gElab;		// set if we detected e-lab

    echo "\n<!-- Footer -->\n<P>\n";
    if ($show_return && empty($gElab) ) {
        echo "<P>\n<div class='footer right more'>
        <a href='".URL_BASE."'>Return to ".PROJECT." main page &gt;&gt</a>
        </div>\n<br clear='right'>\n\n";
    }

    $elab = get_elab_from_URL();

    if( $elab=='cosmic') echo cosmic_menu_bar();
    if( $elab=='ligo')   echo ligo_menu_bar();
    if( $elab=='cms')    echo cms_menu_bar();
    if( empty($elab) )   echo project_menu_bar();

    echo elab_help_link($elab);

    // editing links to transcluded content
    //
    if( user_has_role('admin') || user_has_role('dev') ){

      if ( !empty($gWikiTitle) ){
	$wiki_url ="http://" . $_SERVER['SERVER_NAME'] . $Path_to_wiki . "/";
	echo "<div class='edit_link'>\n";
	echo "  <ul>\n";
	foreach ($gWikiTitle as $title ){
	  $edit_url = $wiki_url . "index.php/$title";
	  echo "    <li><a href='$edit_url'>$title</a>&nbsp;\n";
	}
        echo "  </ul>\n";
	echo "</div>\n";
      }
    }

    echo " <center>\n   Copyright &copy; " .date("Y ") .COPYRIGHT_HOLDER.
       " \n</center>\n\n";

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
          (updated every ". time_diff($ttl*60). " ) </font></p>\n\n";
    }
    display_cvs_versions();  // CVS tags, hidden in comments.
}





/***********************************************************************\
 * User Profiles
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


/****************************************************************
 * BOINC project hooks  - this stuff is mainly unused for I2U2
 */


// Link to a page describing the BOINC project
//
function project_research_url() {
    return "/research.php";
}



// This is/was invoked on the home page of BOINC projects
//
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
