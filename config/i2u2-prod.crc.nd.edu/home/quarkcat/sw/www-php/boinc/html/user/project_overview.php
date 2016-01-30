<?php
/***********************************************************************\ 
 * Project Overview
 *
 *
 * @(#) $Id: project_overview.php,v 1.1 2009/03/20 12:57:51 myers Exp $
\***********************************************************************/

require_once("../inc/util.inc");
require_once("../project/project.inc");
require_once("../include/transclude.php");

//set_debug_level(3);
$caching=FALSE;

page_head("Project Overview");

// Try to get the page contents from a wiki article:
//
$x = get_wiki_article("I2U2:Project_Overview");

 if( !empty($x) ){
   echo $x;
   page_tail();
   exit(0); 
}

$url="http://" . $_SERVER['SERVER_NAME'].$_SERVER['PHP_SELF'];
debug_msg(0,"This page is broken.  Please notify the staff of the problem.
The URL is <blockquote>$url</blockquote>");
page_tail();

?>
