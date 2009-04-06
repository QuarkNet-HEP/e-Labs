<?php

require_once("../inc/db_ops.inc");
require_once("../inc/util.inc");
require_once("../inc/uotd.inc");
require_once("../project/project.inc");

define("EMAIL_EXISTS", -1);
define("EMAIL_UPDATED", 1);
define("EMAIL_FAIL", -2);

define("LG_FONT", "<font size=\"+1\">");
define("SM_FONT", "<font size=\"-1\">");

define("TD", "<td bgcolor=\"#708090\">");
define("TD2", "<td colspan=\"2\" bgcolor=\"#708090\">");
define("TD3", "<td colspan=\"3\" bgcolor=\"#708090\">");

define("TABLE", "<table cellpadding=\"8\" border=\"1\" width=\"100%\">");
define("TABLE2", "<table width=\"580\">");

define("TITLE_COLOR", " bgcolor=\"000000\" ");
define("TITLE_FONT", " <font color=\"ffffff\"> ");
define("BODY_COLOR", " bgcolor=\"ffffff\" ");
define("NOLOGIN", "Not logged in. Click <a href=\"login.php\">here</a> to login.\n");


function admin_page_head($title) {
    $styleSheet = URL_BASE . STYLESHEET;
    //TODO: Add DOCTYPE description here when ready for HTML 4.01
    echo "<html><head><title>$title</title></head>\n";
    echo " <link rel=stylesheet type=text/css href='$styleSheet'>\n";
    echo "<body " . BODY_COLOR . ">\n";
    echo TABLE . "<tr " . TITLE_COLOR . "><td>" . TITLE_FONT . "<font size='5'><b><a href=\"index.php\">".PROJECT.":</a></font>
                $title</b></font></td></tr></table>\n";
    if(function_exists('project_menu_bar')) project_menu_bar();
}


function admin_page_tail() {
    echo "<br><hr noshade size=1><center>";
    echo "<a href=\"index.php\"> Back to Main admin page </a></center>\n";
    echo "</body>\n</html>";
}

function print_checkbox($text,$name,$checked) {
    echo "<input type=\"checkbox\" name=\"$name\""
        . (strlen($checked) ? " checked=\"checked\"" : "") . ">"
        . "$text\n"
        . "<p>\n";
}

function print_radio_button($text,$name,$value,$checked) {
    echo "<input type=\"radio\" name=\"$name\" value=\"$value\""
        . (strlen($checked) ? " checked=\"checked\"" : "") . ">"
        . "$text\n"
        . "<br>\n";
}

function print_text_field($text,$name,$value) {
    echo "$text <input type=\"text\" size=\"10\" name=\"$name\" value=\"$value\">\n"
         . "<p>\n";
}

function row($x, $y) {
    echo "<tr><td valign=\"top\" align=\"right\">$x</td>\n<td>$y</td>\n</tr>\n";
}

function c_row2($color, $x, $y) {
    echo "<tr bgcolor=\"$color\"><td align=\"right\">$x</td><td>$y</td></tr>\n";
}


// These two submitted to Rytis on 31Oct2006 -EAM
// They should go in ../inc/util_ops.php

/**
 * Check that the html/ops directory is secured against outside
 * visitors by a .htaccess file (or you could check for other)
 */

function check_ops_secured(){
    if( !file_exists("../ops/.htaccess") ) {
        echo "<P><font color='RED'>The Project Management directory is not
    protected from public access by a .htaccess file. 
    That's not good!
    </font></P>\n   ";
    }
}

/** 
 * Report if account creation is somehow restricted.
 */

function check_account_creation(){
    $config = get_config();
    if( parse_bool($config, "disable_account_creation") ) {
        echo "<P><font color='ORANGE'>* Account creation is disabled.
    </font></P>\n   ";
    }
 
    if( defined('INVITE_CODES') ) {
        echo "<P><font color='ORANGE'>* Account creation is restricted
        by the use of invitation codes. 
    </font></P>\n   ";
    }
}


/**
 * Display number of candidates for UOTD, with warning colors if needed.
 */

function check_uotd_candidates(){ 
    $N=count_uotd_candidates();    // from uotd.inc
    if($N<0){
       echo "<P><font color='RED'>*       
             There was a problem finding candidates for User of the Day.
            </font></P>\n   ";
        return;

    }
    $color="GREEN";
    if($N < 2*UOTD_THRESHOLD) $color="ORANGE";
    if($N < UOTD_THRESHOLD)   $color="RED";
    echo "<P><font color='$color'>*       
             There are $N remaining candidates for User of the Day.
            </font></P>\n   ";
    return;
}


//Generated automatically - do not edit
$cvs_version_tracker[]=
"\$Id: util_ops.inc,v 1.5 2007/11/26 19:18:49 myers Exp $";  

?>
