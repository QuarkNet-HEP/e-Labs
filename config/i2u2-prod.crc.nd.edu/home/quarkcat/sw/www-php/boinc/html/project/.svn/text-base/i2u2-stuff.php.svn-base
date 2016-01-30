<?php
/***********************************************************************\
 * Project specific functions for I2U2 in general, not specific e-Labs
 *
 *
 * @(#) $Id: i2u2-stuff.php,v 1.3 2009/06/24 17:44:31 myers Exp $
\**********************************************************************/


/**
 * Determine the elab name from the URL /elab/<name>/...
 */
function get_elab_from_URL(){
  global $gElab;	// also set this globally

  $elab = "";
  $self = $_SERVER['PHP_SELF']; 
  $url_pattern=",^/elab/([-a-zA-Z0-9]+)/,";
  $n = preg_match($url_pattern, $self, $matches);
  if($n>0) list($all, $elab) = $matches;
  debug_msg(3,"elab: $elab");
  $gElab=$elab;
  return $elab;
  }



/**
 * Link to Help Desk Request form
 */
function elab_help_link($elab){
  global $BOINC_prefix;
  $x = "";
  $elab_list=array('any' => 'Any/All',
		   'cosmic' => 'Cosmic Rays',
		   'cms' => 'CMS',
		   'ligo' => 'LIGO',
		   'adler' => 'Adler iLab');

  $elab_name = $elab_list[$elab]; 
  $elab_arg = empty($elab_name) ? "" : "?elab=".urlencode($elab_name);

  $x .=  "<div class='help_link right'>
	Report a problem or ask a question:
	<a target='_blank'
   	   href='".$BOINC_prefix
		  ."/HelpDeskRequest.php$elab_arg'>Help Desk Request Form</a>
	</div>\n";	
  $x .= "\n<br/><hr noshade size=1>\n";
  return $x;
}


/**
 * Generate links for cascade of style sheets 
 */
function elab_stylesheets($elab,$styleSheet=''){
  global $gStyleSheets;

  $x = "";

  // 1. Main stylesheet (this is how BOINC did it)
  //
  if( empty($styleSheet) ) $styleSheet = URL_BASE . STYLESHEET;
  $x .= "
     <link rel='stylesheet' type='text/css' href='$styleSheet'>";

  // 2. URL-based stylesheets:
  //
  $self = $_SERVER['PHP_SELF'];  
  $styles = explode("/", dirname($self)); // just directory names
  foreach( $styles as $name ) {
    if(empty($name)) continue;
    $css_url="/elab/$elab/css/$name".".css";
    $x .= "
     <link rel='stylesheet' type='text/css' href='$css_url' />";
  }

  // 3. Additional stylesheets from $gStyleSheets (note the plural!) 
  //
  if ( !empty($gStyleSheets) ){
    foreach( $gStyleSheets as $css_url ){
      $x .= "
        <link rel='stylesheet' type='text/css' href='$css_url'>";
    }
  }
  return $x;
}




// General project banner, if one of the e-Lab banners isn't appropirate
//
function i2u2_masthead(){
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
	     $elab
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

   $elab = get_elab_from_URL();

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



// Header page for the main portal page is special (for now)
//

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

    i2u2_masthead();
}


?>
