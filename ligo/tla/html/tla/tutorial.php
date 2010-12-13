<?php
/***********************************************************************\
 * tutorial.php - tutorial for Bluestone, the LIGO Analysis Tool
 *
 * This page displays the Bluestone tutorial pages.
 * The content is actually taken from the wiki.
 * We use the magic of regular expressions to alter links in 
 * the wiki content.
 *
 * Eric Myers <myers@spy-hill.net  - 31 July 2008
 * @(#) $Id: tutorial.php,v 1.7 2009/06/17 21:02:46 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general TLA utilities

require_once("../include/transclude.php");

set_debug_level(0);
$messages_shown=TRUE;	// trick to get messages to show
$caching=FALSE;

check_authentication();	// check authentication, but do not require it


/***********************************************************************\
 * Action: process the tutorial buttons
\***********************************************************************/

$title = "Bluestone Tutorial";

$step= trim($_GET['step']);
if( is_numeric($step) ){
  $title = "Bluestone Tutorial%2C_step_$step";
}

debug_msg(2,"Wiki page title: $title");

$body = get_wiki_article($title);


/**
 * Alter the text to fix any links
 */

// 1. Unlink wiki links to pages that don't exist in the wiki
//      (as evidenced by the action=edit suffix)
// 
$pattern = ',<a href="/library/[A-Za-z0-9]+\.php[^"]*action=edit"'
	  .'[^>]*>([^<]*)</a>,si';
$body = preg_replace($pattern, " \\1 ", $body); 


// 2. Images in the wiki are linked to their wiki page
//    Remove that link, while preserving the image
//    Works for both index.php/Image:Name and index.php?title=Image:Name

$pattern = ',<a href=[^>]+(/|\?title=)Image:[^>]+>(<img [^>]+>)</a>,si';
$body = preg_replace($pattern, " \\2 ", $body); 


// 3. Convert tutorial wiki link to just this tutorial
//     (Note use of , for regexp because / is for paths) 
//    This gets both index.php/Article and index.php?title=Article
//
$pattern=',href="/library/[A-Za-z0-9]+\.php(/|\?title=)Bluestone_Tutorial%2C_step_(\d+)",si';
$body = preg_replace($pattern, 'href="tutorial.php?step=\\2"',  $body);


// 4. Convert other wiki links to Glossary pop-ups 
//    Now this handles both index.php/Article and index.php?title=Article
//

$pattern='%<a href="/library/[A-Za-z0-9]+\.php(/|\?title=)([^"]+)"[^>]*>([^<]+)</a>%si';
debug_msg(4,"Searching for pattern <code>$pattern</code>");
$url="/library/kiwi.php?title=\\2";
$onclick = "onclick=\"javascript:window.open('$url', 'Glossary: \\2',"
	      ." 'width=520,height=600, resizable=1, scrollbars=1'); "
	      ." return false;\" " ;
$replacement = "\n<a target='_glossary' href=\"$url\" $onclick >\\2</a>\n";
debug_msg(5,"onclick: <code>$onclick</code>");
debug_msg(5,"replacement: <code>$replacement</code>");
$body = preg_replace($pattern, $replacement, $body);


/***********************************************************************\
 * Display Page: 
\***********************************************************************/

if( $step ){
  $title = "Bluestone Tutorial, step $step";
 }
html_begin($title);

if( !empty($body) ){
   echo "\n$body\n\n";
}

html_end();

?>
