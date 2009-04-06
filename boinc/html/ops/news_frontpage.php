<?php
/***********************************************************************\
 *  news_frontpage.php - build the Front Page news box
 * 
 * Build the front page news box as HTML which can be included in the 
 * project front page.   Saves some cycles and allows the rest of the front 
 * page to be built some other way.
 *
 * Output is  * enclosed in <TD class='frontpage_news'>... </TD>
 * in the file html/cache/news_frontpage.html
 *
 * If invoked with ?ig=1 then we emit the XML to configure an iGoogle
 * gadget to display the box.
 *
 * If invoked from the command line rather than from the web server, 
 * The contents of the newsbox are written to the file $newsbox_file,
 * which can be read in whole later when the front page is assembled.
 *
 * TODO: add command line arguments to redirect to another file or 
 * to override and send to stdout even from command line
 *
 *
 * Eric Myers <myers@spy-hill.net> - 31 May 2007
 * the idea to do this is from Liz Quigg at FNAL <liz@fnal.gov>
 * @(#) $Id: news_frontpage.php,v 1.4 2009/02/11 19:20:34 myers Exp $
\***********************************************************************/

require_once("../inc/news.inc");
require_once("../inc/util.inc");          // do we really need this?
require_once("../project/project.inc");   // project-specific settings


if( isset($_GET['ig']) ){
    header('Content-type: text/xml');
    echo "<?xml version='1.0' encoding='UTF-8' ?> 
<Module>
  <ModulePrefs
     title='". PROJECT ." News'
     author='". COPYRIGHT_HOLDER. "'
     author_email='". SYS_ADMIN_EMAIL ."'
     author_affiliation='". PROJECT ."'
     description='Front page news box for " .PROJECT. "'
     height='350'
     scrolling='true'
  /> 
  <Content type='url'
           href='" . URL_BASE. $_SERVER['PHP_SELF'] ."'/>
</Module>\n";
    fflush();
    exit;
 }



// Save all output in a buffer in case we want to send it to a file
//
ob_start();

echo " <TD class='frontpage_news'>
       <a href='rss_main.php'><img src='images/rss+xml.gif' align='right'></a>
       <h3>"  .tr(NEWS). "</h3>
    ";


include($news_file);

echo show_news($project_news, CURRENT_NEWS_ITEMS);

if (count($project_news > CURRENT_NEWS_ITEMS)) {
    echo "\n<p align='left'><a href='old_news.php'>News archive...</a></p>\n";
 }


echo "\n</TD>\n";


/***
 * if invoked from the command line (hence no SERVER_ADDR) then
 * write output buffer to the file, if we can */

if( empty($_SERVER['SERVER_ADDR']) ) {
    $x = ob_get_clean();
    if( $x && $h = fopen($newsbox_file, "w", 0775) ){
        fwrite($h, $x);
        fclose($h);
        exit();
    }
    error_log("! ERROR: could not write to $newsbox_file \n");
    exit();
 }


/* otherwise, just flush ouput buffer to the page */

ob_end_flush(); 

?>
