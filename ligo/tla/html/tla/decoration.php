<?php
/***********************************************************************\
 * decoration.php -  functions for display of output pages
 *
 *
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: decoration.php,v 1.50 2009/03/24 15:28:18 myers Exp $
\***********************************************************************/

require_once("debug.php");   
require_once("config.php");


/*****************************************************************\ 
 * Begin/End HTML pages 
 */

/*  html_begin() starts the HTML output for a page.   Don't call it
 *  until you are sure you don't want to send headers()  */

function html_begin($title,$right_stuff='') {
    global $self, $user_level, $debug_level;

    /* Track memory usage */

    if($debug_level>1){
        memory_save_usage('memory_html_begin');
    }

    /* Background color based on user level */

    $bgc='lightgrey';
    if( isset($user_level) ) {
        if($user_level==1)  $bgc='#ccffcc';
        if($user_level==2)  $bgc='lightblue';
        if($user_level>2)   $bgc='lightgrey';
        //NO//if($user_level==5)  $bgc='white';
    }
    $bgc='lightgrey';

    /* Begin Document: */

    //  TODO: need to sort out which one we want to claim to support ***
    echo "<!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' "
        ." 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'> \n";

    echo "<HTML>\n<HEAD> \n";

    echo "<TITLE>"  .$title. "\n</TITLE>\n";
    // TODO: <META> tags go here


    /* Favicon & Style Sheets */

    echo "<link rel='shortcut icon' type='image/x-icon' href='/favicon.ico'>\n";
    echo "<link rel=stylesheet type='text/css' href='style.css'>\n";

    echo "</HEAD>\n <BODY bgcolor='$bgc'>\n";

    /* the entire page is a self-posting form */

    $self = $_SERVER['PHP_SELF'];        // this is global so others may use it
    $form_name=basename($self,'.php');
    echo "<form name='$form_name' method='POST' action='$self'>\n";

    recall_variable('auto_update');
    global $auto_update;
    echo "<script language='JavaScript'>function submit_form(f){";
    if( $auto_update == 'on') echo " f.submit(); ";
    else echo " /* do nothing */ ";
    echo "} </script>\n";

    tool_masthead($title);
    title_bar($title,$right_stuff);
}


/* The masthead is displayed at the top of EVERY page 
 * //TODO: link to MASTER_URL that works on all sites */

function tool_masthead($title,$right_stuff='&nbsp;'){
    echo "\n<!-- Tool Masthead -->
     <TABLE class='masthead' width=100% border=0 BGCOLOR='black' ><TR>
       <TD WIDTH=15% VALIGN='TOP' ALIGN=LEFT>
              <a href='/' >
              <img src='img/ligo_logo.gif' border='0'
                   valign='TOP' align='LEFT' alt='LIGO' 
                   title='return to the top level'></a>
       </TD>";

    echo "
       <TD valign='CENTER' align='CENTER' >
          <font size='4' color='white' face='helvetica,sans-serif' ><b>
        <div id='header-title'>
                	Welcome to the LIGO I2U2 e-Lab
        </div>
            </b></font>
       </TD>\n ";

    echo "
       <TD valign='TOP' align='RIGHT' >
          <font size='3' color='grey' face='helvetica,sans-serif' ><b>
        <div id='second-header-title'>
        	Laser Interferometer Gravitational-Wave Observatory
        </div>
            </b></font>
       </TD>\n ";


echo "</TR><TD colspan='3'> <hr color='white'></TD></TR>\n  ";

    echo "</TABLE>";

    echo "\n<!-- END Tool Masthead -->\n";
}



/* The title_bar() shows the title and user info  */

function title_bar($title){
    global $user_level, $logged_in_user;

    echo "\n<!-- Tile/User Bar -->\n";
    echo " <TABLE WIDTH=100% border=0 ><TR>
           <TD ALIGN=LEFT><font size=+2 face='helvetica,arial'><b><em>\n"
        .$title.
        "\n</b></em></font><br/> </TD>\n";

    echo "<TD align='CENTER' valign='TOP' width='33%'>\n";

    echo "</TD>\n";

    /* User level control and login info */

    echo " <TD ALIGN=RIGHT VALIGN=TOP> \n";

    if( !isset($user_level) ) $user_level=1;
    debug_msg(7,"User level is " .$user_level);
    user_level_control();

    if( isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
        echo "&nbsp;";
    }
    else {              
        echo "&nbsp;<br>&nbsp;";
        echo "<font size='-1'>\n";
        show_user_login_name();
        echo "</font>\n";
    }

    echo "</TD></TR></TABLE>";
    echo "\n<!-- END Tile/User Bar -->\n";
}


/* tool_footer() is displayed at the bottom of every page */

function tool_footer($show_return='', $show_date=false) {
    global $debug_level, $user_level, $msgs_list;
    global $TLA_tool_name, $self;

    // Show any outstanding debugging messages
    if( $debug_level>0 )  {
      if( !empty($msgs_list) ) show_message_area();
    }

  echo "\n<!-- project footer -->\n<p>\n"; 
  echo " </blockquote>
        <hr>\n";

  echo "<table width='100%' border=0><tr>\n";

  // CVS version tag

  $tag = $TLA_tool_name." ".cvs_tag_name();
  //  $tag .= " [".cvs_version()."]";

  if( strpos($self,'tla_test') !== FALSE ) $tag .= " TEST";
  if( strpos($self,'tla_dev') !== FALSE ) $tag .= " DEV";

  echo "<TD width='33%'><font size='-2' color='gray'>  $tag </font></TD> \n";

  // Date stamp?

  if (1 || $show_date) {
    echo "<td align='center'>
	<font size='-2' color='gray'>generated ".
        gmdate('j M Y G:i:s', time()) . " UTC"."</font>
	</td>\n";
  }

    // Bug report LINK
    //

  // secret link to operations page, at least for us

  echo "<td width='33%' align='right'> \n";  
  if( $user_level > 0 ){
        echo "<font size='1'><i>
        <a href='/HelpDeskRequest.php?elab=LIGO&part=Data+Analysis+Tool'
           target='bugrpt'>Report a Bug</a></i></font>\n";
    }

  if( is_test_client() ){
      echo "&nbsp;/&nbsp;<a href='testing.php'>&pi;</a>\n";
  }
  else {
      echo "&nbsp;\n";
  }

  echo "	</td>\n</tr></td></table>\n";
  
  if($debug_level > 2) {
      echo "<P><pre>_POST=" . print_r($_POST,true). "</pre>\n";
  }
}


/* end_html() ends the page, possibly with a link back to the page
 * we were called from.   This will likely fork into two version.... */

function html_end(){
    global $orig_referer, $debug_level;

  if( $orig_referer ) {
    echo "<P><a href='" .$orig_referer.
      "'>Click here to go back to what you were doing...</a></P>\n";
  }
  echo "\n</form>\n";    
  echo "</BODY>\n</HTML>\n";
}



/* glossary_link($term, $text) lets you easily make a link to 
 * the glossary entry for "term", with link text $text.
 * But only if GLOSSARY_URL is set.   This should be the complete
 * URL to the wiki, to which the $term will be appended to make
 * the link URL.  */

function glossary_link($term, $text){
    if( !defined('GLOSSARY_URL') ) return $text;
    $title = "title='Glossary definition of \"$term\"' ";
    $term = strtr($term, " ", "_");      // spaces in term become underscores
    $url =  GLOSSARY_URL . $term; 
    $onclick = "onclick=\"javascript:window.open('$url', 'Glossary: $term',"
	      ." 'width=520,height=600, resizable=1, scrollbars=1');"
	      ."  return false;\"" ;
    $link = " <a target='_glossary' href='$url' $title $onclick >$text</a> ";
    return $link;
}

function glink($term){ // shortcut
    return glossary_link($term,$term);
}


/* help_link( $term) is a glossary link, but just for help.
 * The link is in a superscript, and presentation is verbose
 * or terse, or none at all, depending on user level.
 * TODO: replace [?] with an image
 */

function help_link($term){
    global $user_level;

    if($user_level>2) return;    
    if( !defined('GLOSSARY_URL') )  return;

    $term = strtr($term, " ", "_");      // spaces in term become underscores
    $url =  GLOSSARY_URL . $term; 

    $help="what's this?";          // TODO: replace with an image       
    if($user_level>1) $help="?";   // TODO: replace with an image

    return "<sup>[<a target='_help' href='$url'
               onclick=\"javascript:window.open('$url', 'Glossary: $term', 'width=520,height=600, resizable=1, scrollbars=1');return false;\"
                >$help</a>]</sup>";
}



/***********************************************************************\
 * Control Panel.   This makes it look like GTK tool in LIGO Control Room
 */

function controls_begin(){
    global $user_level;

    echo "<div class='control' >
       <TABLE width='100%' border=7  >
       <TR><TD>\n        ";

    steps_as_tabs('main_steps');
    controls_next();
    show_message_area();
    controls_next();
}


function controls_next(){ // TODO:  change this to controls_sep()??
    echo "</TD></TR></TR><TD>\n";
}


function controls_end(){
    global $debug_level, $user_level ,$Nplot;

    controls_next();

    echo "<table width='100%' border=0><tr><td>\n";


    auto_update_control();

    // Plot number

    if( isset($Nplot) && $Nplot > 0) {
        echo "&nbsp;|&nbsp; Plot # $Nplot \n";
    }


    // Debug level controls
    //
    if( is_test_client() ){
        echo "</td><td align='center'>\n";
        echo select_debug_level();
        if( is_test_client() ){
            echo "<a href='testing.php'>&pi;</a>\n";
        }
    }

    // Memory usage display
    //
    if( $debug_level > 1 && $user_level > 0 || is_test_client() ){
        $memory_here=memory_get_usage();
        echo "</td><td align='right'>\n";
        echo " Memory: " . memory_format($memory_here);

        // What page started with:
        global $memory_initial;
        if( 0 && isset($memory_initial) ){
            $dMem = $memory_here - $memory_initial;
            echo "\n <font size='-1'>(Page started with " .
                memory_format($memory_initial).")</font>\n";
        }

        // Additional to render the page (since output started): OFF!
        global $memory_html_begin;
        if(0 && isset($memory_html_begin)){
            $dMem = $memory_here - $memory_html_begin;
            echo "\n <font size='-1'> To render: " . memory_format($dMem)
                ."</font>\n";
        }
    }


    // end status line
    //
    echo "</td></tr></table>\n";  

    // Back/Reset/Next buttons inside the control panel
    //
    controls_next();
    prev_next_buttons('main_steps');

    echo "</TD></TR></TABLE></div>\n"; // end of entire control box
}


function hrule(){
    echo "    <hr>  \n";
}



/***********************************************************************\
 * Page Forms  - this is all deprecated.  Every HTML page is now a form 
 *     which submits to itself.   But these might be useful elsewhere.
\***********************************************************************/

function form_begin($name){
  global $self, $form_name;
  debug_msg(8,"form_begin() is used on this page, please remove it.");
  return;

  $self = $_SERVER['PHP_SELF'];        // this is global so others may use it
  $name=basename(self,'php');
  echo "\n
    <form name='$name' method='POST' action='$self'>
        ";
}


function form_end(){
  debug_msg(8,"form_end() is used on this page, please remove it.");
  return;
  echo "\n      </form>\n";
}

$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: decoration.php,v 1.50 2009/03/24 15:28:18 myers Exp $";
?>
