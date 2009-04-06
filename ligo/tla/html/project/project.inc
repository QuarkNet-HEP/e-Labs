<?php
/***********************************************************************\
 * project.inc - project specific preferences and settings
 * 
 * This file contains settings for decorations and other presentation
 * elements.  
 *
 * It's a STRIPPED DOWN version of BOINC html/project/project.inc
 *
 *
 * @(#) Last changed: -EAM 27Sep2007
\**********************************************************************/

// Extra macros we find useful.
// These should migrate to ../include/util.php
//
require_once("../project/extras.php");


// Primary configuration settings:
//
define("PROJECT", "I2U2");
define("MASTER_URL", "http://tekoa.ligo-wa.caltech.edu/");
define("URL_BASE", "http://tekoa.ligo-wa.caltech.edu/");

define("IMAGE_PATH", "../user_profile/images/");
define("IMAGE_URL", "user_profile/images/");
define("LANGUAGE_FILE", "languages.txt");
define("STYLESHEET", "/i2u2.css");
define("COPYRIGHT_HOLDER", "Eric Myers, for the I2U2 Confederation");
define("SYS_ADMIN_EMAIL", "i2u2-admin@i2u2.spy-hill.net");
define("EMAIL_FROM",    "I2U2 forums <i2u2-admins@i2u2.spy-hill.net>");
define("POST_REPORT_EMAILS", "myers@spy-hill.net");



// project_banner() is displayed at the top of every page 
//
function project_banner($title) {
    echo "\n<link rel='shortcut icon' type='image/x-icon' href='/favicon.ico'/>\n";
    echo "<link rel=stylesheet type='text/css' href=" .STYLESHEET. ">";

    project_masthead();   

    echo "
     <TABLE WIDTH=100% ><TR>
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

    echo "
     <TABLE WIDTH='100%'  border='1' bgcolor='white'><TR>
       <TD   style='border: 1'>
       <TABLE width='100%'  border='1' bgcolor='white'><TR>

        <TD width=10% ALIGN=LEFT  style='border: 1'>
          <a href='/'>
          <img src='/images/UUEOb.gif' height='175' border=0></a>
        </TD>

        <TD VALIGN='TOP' ALIGN=LEFT  style='border: 1'>
               <h1><font size='6' ><b>
            Interactions in <br>
            Understanding the Universe
            </b></font></h1>
            <hr width='100%'>
            <h2><font color='darkblue' ><i>
            Project Mock-up
            </i></font> </h2>

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
      <TABLE WIDTH=100% BORDER=0 BGCOLOR='#888888'>
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
    <TD class='masthead'><a class='masthead' href='/glossary'>"
        .tr(GLOSSARY). "</a></TD>
	";

    echo "
    <TD class='masthead'><a class='masthead' href='/forum_index.php'>"
        . tr(PIRATES_MENU_FORUMS). "</a></TD>
    <TD class='masthead'><a class='masthead' href='/home.php'>"
        .tr(PIRATES_MENU_ACCOUNT). "</a></TD>
        </TR>
       </TABLE>\n    ";
}




// project_footer() is displayed at the bottom of every page 
//
function project_footer($show_return, $show_date) {
    echo "\n<!-- Footer -->\n<P>\n"; 
    project_menu_bar();

    // End of page: secret link to Operations page
    //echo "<p align=right> <a href='/session.php'>&#960</a>\n   ";


    echo "<br><hr noshade size=1><center>";
    if ($show_return) {
        echo "<a href=".URL_BASE.">Return to ".PROJECT." main page</a><br>\n";
    }
    echo "<br><br>Copyright &copy; ".date("Y ").COPYRIGHT_HOLDER."</center>\n";
    if ($show_date) {
        echo "<font size=-2 color=bbbbbb>Generated ",time_str(time()),"</font>\n";
    }
}

?>
