<?php
/***********************************************************************\
 * Media2File.php                            Version 0.3 of 6 Sept. 2007
 *
 * This is a MediaWiki extension which changes the name of the 
 * pseudo-namespace for non-image uploaded files from "Media:" to "File:"
 * So to link to such an uploaded file you'd use syntax like
 * [[File:filname.pdf]] or [[File:filname.pdf|text of link]].
 *
 * Even after you do this, Media: still works, at least with MW 1.10.1.
 * I'm not sure why, and you shouldn't count on this in the future.
 * 
 * Be sure to alter the system messages MediaWiki:upload and 
 * MediaWiki:uploadtext to reflect this change.
 *
 * The default behaviour is that Media: no longer works, but see below
 * about how to make Media: continue to work as before.
 *
 * Written by Eric Myers <myers@spy-hill.net>  - 6 September 2007
 * @(#) $Id: $
\***********************************************************************/

// Extension information (shown by Special:Version)

$wgExtensionFunctions[] = 'SetupMedia2File';   // runs automatically
$wgExtensionCredits['other'][] =
    array(
          'name' => 'Media2File',
          'version' => '0.3',
          'author' => 'Eric Myers',
          'description' => 'Changes the Media: pseudo-namespace into File: ',
          'date' => '6 September 2007',
          'type' => 'parser'
          // 'url' => 'http://pirates.spy-hill.net/glossary/index.php/BOINC_Authentication'
          );


if( !defined('NS_MEDIA') ) define('NS_MEDIA', -2);


/* Create the hook for the parser, to change the name */

function SetupMedia2File(){
    global $wgHooks;

    /* This hook may go away, but for now it's earlier enough for
     * our purposes. */

    //THIS WORKS//
    $wgHooks['LogPageValidTypes'][] = 'turn_Media_into_File';

    //TODO: find another hook before Language.php is loaded.
    //NOPE// $wgHooks['AuthPluginSetup'][] = 'turn_Media_into_File';
    //NOPE// $wgHooks['SiteNoticeBefore'][] = 'turn_Media_into_File';
    //NOPE// $wgHooks['ArticleFromTitle'][] = 'turn_Media_into_File';
    //NOPE// $wgHooks['GetFullURL'][] = 'turn_Media_into_File';

}

/* Change the name to File: */ 

function turn_Media_into_File(){ // changes the name before parsing
    global $wgCanonicalNamespaceNames;
    global $namespaceNames;
    global $wgContLang;


    $wgCanonicalNamespaceNames[NS_MEDIA] = 'File';
 
    /* if you comment out the next line then 'Media:' (or whatever
     * it is in the chosen language) will also still work.
     * In fact, this next line isn't the right one, so right now 
     * Media: does indeed still work.
     */

    $wgContLang->namespaceNames[NS_MEDIA] = 'File';
}

//EOF//