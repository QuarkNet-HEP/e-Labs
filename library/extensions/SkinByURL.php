<?php
/***********************************************************************\
 * SkinByURL.php                             Version 0.3 of 14 July 2008
 *
 * This is a MediaWiki extension which causes a page to be displayed 
 * with a particular skin based on the name of the file used to access
 * the page.  Just replace "index" in index.php with the name of the skin.
 * For example, you could force a display in the "chick" skin (for hand-held 
 * devices) by changing the entry point from "index.php" to "chick.php"
 *
 * Installation:
 *    1) Move this file to the 'extensions' subdirectory of the wiki, 
 *    2) For each skin you wish to use this way, make a link to index.php
 *       in the main wiki directory.  For example, to use the "chick" skin
 *       as described above cd to the main directory (the one containing
 *       the extensions and skins subdirectories) and give the command
 *
 *            ln -s index.php chick.php
 *
 *       (It's probably possible to do this also with an Alias in your
 *       web server configuration, but I've not yet tested it.)
 * 
 * Tested with MediaWiki 1.10.3 on 14 July 2008
 *
 * Written by Eric Myers <myers@spy-hill.net>  - 11 July 2008
 * @(#) $Id: $
\***********************************************************************/

// Configuration: (no configurable options yet)


/***********
 * Extension information (shown by Special:Version)
 */

//$wgExtensionFunctions[] = 'set_skin_from_url';    // run automatically?

$wgExtensionCredits['other'][] =
    array(
          'name' => 'SkinByURL',
          'version' => '0.3',
          'author' => 'Eric Myers',
          'description' => "Specify the skin using the filename in the URL ".
                           " (eg. myskin.php rather than index.php)",
          'date' => '14 July 2008', 
          'url' => 'http://pirates.spy-hill.net/glossary/SkinByURL'
          );



/* If the name of the entry point is not index.php then we put a hook
 * into OutputPage to check for a skin name.  We cannot check the filename
 * here is the name of a skin, because the list of valid skin names is not 
 * yet available.  But we can alter links to use this alternate entry point
 * in any case.
 */

$pattern="/.*\/(.*)\.php.*/";
if( preg_match($pattern,$_SERVER['PHP_SELF'],$matches) > 0){
    $filename=$matches[1];
    if( $filename != "index" ){
        $skin_name = $filename;
        $wgHooks['OutputPageParserOutput'][] = 'set_skin_from_url';
        //$wgScript  ="$wgScriptPath/$skin_name.php"; // keep links in this skin
        //$wgArticlePath      = "$wgScript/$1";
    }
 }


//TODO: If we can use a different hook, one invoked before the parser
//  but after valid skins are listed, then we could move the entry point change
//  to the hook function and only change the entry point if it is indeed
//  a valid skin name.  But this is a minor point.



/* Force a change of skin if the entry point is a valid skin name rather 
 * than "index"
 */

function set_skin_from_url(){
    global $wgValidSkinNames;
    global $wgUser, $wgDefaultSkin, $wgScript, $wgArticlePath;

    // Extract entry point filename (sans .php extension)
    //
    $pattern="/.*\/(.*)\.php.*/";
    if( preg_match($pattern,$_SERVER['PHP_SELF'],$matches) < 1) return FALSE;
    $filename=$matches[1];

    // Is the filename a valid skin name?
    //
    if( !array_key_exists($filename,$wgValidSkinNames) ) return FALSE;
    $skin_name=$filename;

    $wgDefaultSkin = $skin_name;                // for anonymous users
    $wgUser->setOption('skin', $skin_name);     // for logged in users
}

?>
