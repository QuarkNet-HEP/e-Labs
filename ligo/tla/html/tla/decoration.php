<?php
/***********************************************************************\
 * decoration.php -  functions for display of output pages
 *
 *
 *
 * eric myers <myers@spy-hill.net  - 30 march 2006
 * @(#) $id: decoration.php,v 1.50 2009/03/24 15:28:18 myers exp $
\***********************************************************************/

require_once("debug.php");   
require_once("config.php");


/*****************************************************************\ 
 * begin/end html pages 
 */

/*  html_begin() starts the html output for a page.   don't call it
 *  until you are sure you don't want to send headers()  */

function html_begin($title,$right_stuff='') {
    global $self, $user_level, $debug_level;

    /* track memory usage */

    if($debug_level>1){
        memory_save_usage('memory_html_begin');
    }

    /* background color based on user level */

    $bgc='lightgrey';
    if( isset($user_level) ) {
        if($user_level==1)  $bgc='#ccffcc';
        if($user_level==2)  $bgc='lightblue';
        if($user_level>2)   $bgc='lightgrey';
        //no//if($user_level==5)  $bgc='white';
    }
    // Override: setting background was overkill -EAM
    $bgc='white';

    /* begin document: */

    //  todo: need to sort out which one we want to claim to support ***
    echo "<!doctype html public '-//w3c//dtd xhtml 1.0 transitional//en' "
        ." 'http://www.w3.org/tr/xhtml1/dtd/xhtml1-transitional.dtd'> \n";

    echo "<html>\n<head> \n";

    echo "<title>"  .$title. "\n</title>\n";
    // todo: <meta> tags go here


    /* favicon is the Address Bar icon */

    echo "<link rel='shortcut icon' type='image/x-icon' href='/favicon.ico'>\n";

    /* Style sheets come in a full cascade... */

    echo "<link rel=stylesheet type='text/css' href='style.css'>\n";












    echo "</head>\n <body bgcolor='$bgc'>\n";

    /* The entire page is a self-posting form */

    $form_name=basename($self,'.php');
    echo "<form name='$form_name' method='post' action='$self'>\n";

    recall_variable('auto_update');
    global $auto_update;
    echo "<script language='javascript'>function submit_form(f){";
    if( $auto_update == 'on') echo " f.submit(); ";
    else echo " /* do nothing */ ";
    echo "} </script>\n";

    ligo_masthead($title);
}


/*****************
 * The masthead is displayed at the top of every page 
 */

function ligo_masthead($title,$right_stuff='&nbsp;'){
echo <<<END
	<!-- Begin Tool Masthead -->
	<div id="top">
		<div id="header">
			<div id="header-image">
				<img src="/elab/ligo/graphics/ligo_logo.gif" alt="Header Image" />
			</div>
			<div id="header-title">
				LIGO e-Lab
			</div>
			<div id="second-header-title">
				&nbsp;
			</div>
			<link type="text/css" href="/elab/ligo/css/header.css" rel="Stylesheet" />
			<link type="text/css" href="/elab/ligo/css/nav-rollover.css" rel="Stylesheet" />
			<link type="text/css" href="/elab/ligo/include/jquery/css/default/jquery-ui-1.7.custom.css" rel="Stylesheet" />	
			<script type="text/javascript" src="/elab/ligo/include/jquery/js/jquery-1.3.2.min.js"></script>
			<script type="text/javascript" src="/elab/ligo/include/jquery/js/jquery-ui-1.7.custom.min.js"></script>
		
			<script type="text/javascript">
			$(document).ready(function() {
				$("#nav-home").mouseover(function(){ // Home
					$("#subnav").children().hide(); 
					$("#sub-home").show();
				});
				$("#nav-library").mouseover(function(){ // Library
					$("#subnav").children().hide();
					$("#sub-library").show(); 
				});
				$("#nav-data").mouseover(function(){ // Data
					$("#subnav").children().hide();
					$("#sub-data").show(); 
				});
				$("#nav-posters").mouseover(function(){ // Posters
					$("#subnav").children().hide();
					$("#sub-posters").show();
				});
				$("#nav-siteindex").mouseover(function(){ // Site Index
					$("#subnav").children().hide();
					$("#sub-siteindex").show();
				});
				$("#nav-assessment").mouseover(function(){ // Assessment
					$("#subnav").children().hide();
				});
			});
			</script>
		
			<div id="nav">
				<table>
					<tr>
						<td id="menu">
							<ul>
								<li><a href="/elab/ligo/home" id="nav-home">Home</a></li>
								<li><a href="/elab/ligo/library" id="nav-library">Library</a></li>
								<li><a href="/elab/ligo/data" id="nav-data">Data</a></li>
								<li><a href="/elab/ligo/posters" id="nav-posters">Posters</a></li>
								<li><a href="/elab/ligo/site-index" id="nav-siteindex">Site Map</a></li>
								<li><a href="/elab/ligo/assessment/index.jsp" id="nav-assessment">Assessment</a></li>
							</ul>
						</td>
					</tr>
					<tr>
						<td id="subnav">
							<ul id="sub-home">
								<li><a href="/elab/ligo/home/cool-science.jsp">Cool Science</a></li>
								<li><a href="/elab/ligo/site-index/site-map-anno.jsp">Explore!</a></li>
								<li><a href="/elab/ligo/home/about-us.jsp">About Us</a></li>
							</ul>
							<ul id="sub-library">
								<li><a href="/library/index.php/Category:LIGO">Glossary</a></li>
								<li><a href="/elab/ligo/library/resources.jsp">Resources</a></li>
								<li><a href="/elab/ligo/library/big-picture.jsp">Big Picture</a></li>
								<li><a href="/elab/ligo/library/FAQ.jsp">FAQs</a></li>
								<li><a href="/elab/ligo/library/site-tips.jsp">Site Tips</a></li>
							</ul>
							<ul id="sub-data">
								<li><a href="/ligo/tla/tutorial.php">Tutorial</a></li>
								<li><a href="/ligo/tla/">Bluestone</a></li>
								<li><a href="/elab/ligo/plots/">Plots</a></li>
							</ul>
							<ul id="sub-posters"> 
								<li><a href="/elab/ligo/posters/new.jsp">New Poster</a></li>
								<li><a href="/elab/ligo/posters/edit.jsp">Edit Posters</a></li>
								<li><a href="/elab/ligo/posters/view.jsp">View Posters</a></li>
								<li><a href="/elab/ligo/posters/delete.jsp">Delete Poster</a></li>
								<li><a href="/elab/ligo/plots">View Plots</a></li>
								<li><a href="/elab/ligo/jsp/uploadImage.jsp">Upload Image</a></li>
							</ul>
							<ul id="sub-siteindex">
								<li><a href="/elab/ligo/site-index/site-map-anno.jsp">Site Index</a></li>	
								<li><a href="/elab/ligo/site-index/site-map-anno.jsp">Explore!</a></li>
							</ul>
						</td>
					</tr>
				</table>
			</div>	
END;
			user_tools();
echo <<<END
		</div>
	</div>
    <!-- END Tool Masthead -->
END;
}

function user_tools() {
	global $user_level, $logged_in_user;
	
	if( isset($hide_user) && $hide_user ) {   // don't show user/login or cache indicator
        echo "&nbsp;";
    }
    else {              
        echo "<div id=\"header-current-user\">";
        show_user_login_name();
        echo "</div>\n";
    }
	
	if( !isset($user_level) ) $user_level=1;
    debug_msg(7,"User level is " .$user_level);
    user_level_control();
}


/* The title_bar() shows the title and user info  */
// TODO: remove as it does nothing

function title_bar($title){
    
    global $current_step_title;
    
    $current_step_title = $title;

    echo "\n<!-- Tile/User Bar -->\n";
    echo " <TABLE WIDTH=100% border=0 ><TR>
           <TD ALIGN=LEFT><font size=+2 face='helvetica,arial'><b><em>\n".
        "\n</b></em></font><br/> </TD>\n";

    echo "<TD align='CENTER' valign='TOP' width='33%'>\n";

    echo "</TD>\n";

    /* User level control and login info */

    echo " <TD ALIGN=RIGHT VALIGN=TOP> \n";

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
 * we were called from.  
 *
 * @uses $gWikiTitle - array of wiki pages transcluded into this page
 * @uses $Path_to_wiki to construct link to wiki page names
 */

function html_end(){
  global $gWikiTitle, $Path_to_wiki;

  global $orig_referer, $debug_level;

  // Link back to referer, if there is one
  //
  if( $orig_referer ) {
    echo "<P><a href='" .$orig_referer.
      "'>Click here to go back to what you were doing...</a></P>\n";
  }
  echo "\n</form>\n";    


  // Show links to transcluded content
  //
  if ( !empty($gWikiTitle) ){
    $wiki_url ="http://" . $_SERVER['SERVER_NAME'] . $Path_to_wiki . "/";
    echo "<div class='edit_link'>";
    foreach ($gWikiTitle as $title ){
      $edit_url = $wiki_url . "index.php/$title";
      echo "<a href='$edit_url'>&middot; $title</a>&nbsp; ";
    }
    echo "</div>\n";
  }

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
               onclick=\"javascript:window.open('$url', 'Glossary: $term', 'width=520,height=600, resizable=1, scrollbars=1');return false;\"".
                ">$help</a>]</sup>";
}



/***********************************************************************\
 * Control Panel.   This makes it look like GTK tool in LIGO Control Room
 */

function controls_begin(){
    global $user_level;
    
    global $current_step_title;
    
    if (empty($current_step_title)) {
    	$current_step_title = "&nbsp;";
    }

    echo "  <table border=\"0\" id=\"frame\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";
    echo "    <tr><td id=\"frame-top-left\"></td><td id=\"frame-top-left-inner\"></td>";
    echo "      <td id=\"frame-top\"><div id=\"title\">$current_step_title</div></td><td id=\"frame-top-right-inner\"></td>";
    echo "      <td id=\"frame-top-right\"></td></tr>\n";
    echo "    <tr><td id=\"frame-left\"></td><td colspan=\"3\" id=\"center\">\n";

    steps_as_blocks('main_steps');
    show_message_area();
}


function controls_next(){ // TODO:  change this to controls_sep()??
    //echo "</TD></TR></TR><TD>\n";
}


function controls_end(){
    global $debug_level, $user_level ,$Nplot;

	echo "<div class=\"control\">\n";

    echo "<table width='100%' border=0><tr><td>\n";

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
    prev_next_buttons('main_steps');
    echo "</div>\n";
    
    echo "    </td><td id=\"frame-right\"></td></tr>\n";
    echo "    <tr><td id=\"frame-bottom-left\"></td><td id=\"frame-bottom-left-inner\"></td>";
    echo "      <td id=\"frame-bottom\"></td><td id=\"frame-bottom-right-inner\"></td>";
    echo "      <td id=\"frame-bottom-right\"></td></tr>\n";
    echo "  </table>\n";
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
    "\$Id: decoration.php,v 1.54 2009/06/17 20:54:23 myers Exp $";
?>
