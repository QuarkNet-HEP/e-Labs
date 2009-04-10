<?php 
/***********************************************************************\
 * LocalSettings.php for I2U2 Library (http://i2u2.spy-hill.net/library)
 *
 * This version of the file was copied from a working version on 
 * Pirates@Home and then edited to change "pirates" to "i2u2" everywhere
 * (actually it was a bit more than that, but not much). 
 *
 * See includes/DefaultSettings.php for all configurable settings
 * and their default values, but don't forget to make changes in _this_
 * file, not there.
 *
 * If you customize your file layout, set $IP to the directory that contains
 * the other MediaWiki files. It will be used as a base to locate files.
 * 
 * First Created: -EAM 01May2006
 * Last changed:  -EAM 07Jul2008
 *
 * @(#) $Id: LocalSettings.php,v 1.9 2009/03/19 18:50:07 myers Exp $
\***********************************************************************/

// Installation Path, $IP
// Note that we assume below that other components of the site are 
// installed under the directory _above_ $IP

if( defined( 'MW_INSTALL_PATH' ) ) {
    $IP = MW_INSTALL_PATH;
} else {
    $IP = dirname( __FILE__ );
}

$path = array( $IP, "$IP/includes", "$IP/languages" );
set_include_path( implode( PATH_SEPARATOR, $path ) );

require_once( "includes/DefaultSettings.php" );

# If PHP's memory limit is very low, some operations may fail.
ini_set( 'memory_limit', '20M' );

if ( $wgCommandLineMode ) {
    if ( isset( $_SERVER ) && array_key_exists( 'REQUEST_METHOD', $_SERVER ) ) {
        die( "This script must be run from the command line\n" );
    }
} elseif ( empty( $wgNoOutputBuffer ) ) {
    ## Compress output if the browser supports it
    if( !ini_get( 'zlib.output_compression' ) ) @ob_start( 'ob_gzhandler' );
}

###################################
# Paths and URLs:

$wgSitename         = "I2U2";

// Set the session name to match the BOINC project and we can work within one session

$wgSessionName      = "boinc_session"; //to match the BOINC project

$wgScriptPath       = "/library";
$wgScript           = "$wgScriptPath/index.php";
$wgRedirectScript   = "$wgScriptPath/redirect.php";

## For more information on customizing the URLs please see:
## http://meta.wikimedia.org/wiki/Eliminating_index.php_from_the_url
## If using PHP as a CGI module, the ?title= style usually must be used.
$wgArticlePath      = "$wgScript/$1";
# $wgArticlePath      = "$wgScript?title=$1";

$wgStylePath        = "$wgScriptPath/skins";
$wgStyleDirectory   = "$IP/skins";
$wgLogo             = $wgScriptPath."/UUEOb-med.gif";
$wgFavicon          = $wgScriptPath."/UUEOb-favicon.jpg";


$wgEnableEmail = true;
$wgEnableUserEmail = true;


## For a detailed description of the following switches see
## http://meta.wikimedia.org/Enotif and http://meta.wikimedia.org/Eauthent
## There are many more options for fine tuning available see
## /includes/DefaultSettings.php
## UPO means: this is also a user preference option
$wgEnotifUserTalk = true; # UPO
$wgEnotifWatchlist = true; # UPO
$wgEmailAuthentication = true;


## Database settings (should not be stored in CVS)
#
include("DatabaseSettings.php");


## If you have the appropriate support software installed
## you can enable inline LaTeX equations:
$wgUseTeX            = false;
$wgMathPath         = "{$wgUploadPath}/math";
$wgMathDirectory    = "{$wgUploadDirectory}/math";
$wgTmpDirectory     = "{$wgUploadDirectory}/tmp";

$wgLocalInterwiki   = "library";

$wgLanguageCode = "en";

$wgProxyKey = "ccec0f84409f79687d5eb28901cddd6fbb3f0afba1beecb0414756c25aef6f49";



## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
# $wgEnableCreativeCommonsRdf = true;
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "";
$wgRightsText = "";
$wgRightsIcon = "";
# $wgRightsCode = ""; # Not yet used
$wgCheckCopyrightUpload=true;


$wgDiff3 = "/usr/bin/diff3";

# When you make changes to this configuration file, this will make
# sure that cached pages are cleared.

$configdate = gmdate( 'YmdHis', @filemtime( __FILE__ ) );
$wgCacheEpoch = max( $wgCacheEpoch, $configdate );

# Shared memory (cache) settings: 

$wgMainCacheType = CACHE_NONE;
$wgMessageCacheType = CACHE_NONE;

$wgUseFileCache = false;
/** Directory where the cached page will be saved */
$wgFileCacheDirectory = "{$wgUploadDirectory}/cache";

$wgParserCacheType = CACHE_NONE;
$wgEnableParserCache = false;
$wgParserCacheExpireTime = 600;

$wgMemCachedServers = array();


/***********************************************************************
 * Upload Configuration:
 */

$wgUploadPath       = "$wgScriptPath/upload";
$wgUploadDirectory  = "$IP/upload";

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads        = true;

$wgUseImageResize       = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

## If you want to use image uploads under safe mode,
## create the directories images/archive, images/thumb and
## images/temp, and make them all writable. Then uncomment
## this, if it's not already uncommented:
$wgHashedUploadDirectory = true;

## If you want to allow any file extension to be uploaded:
#$wgStrictFileExtensions = false;


# Or specify file extenstions which are allowed, above and beyond
# the standard image extensions.
#
$wgFileExtensions =
    array_merge($wgFileExtensions,
                array( 'pdf', 'doc', 'ppt', 'xls', 'kml', 'kmz', 
		'ps', 'eps' )
                );


# To show links to non-image uploaded files we need to allow
# embeded external images for the icon.  Could this be abused?
# Or use Image: namespace for the icons.
#
$wgAllowExternalImages = true;


## Turn off mime type detection to avoid "this file is corupt" error.
## See [[Meta:Uploading_files]] for details
## This is just a workaround until we can FIX the mime type detection
##wgVerifyMimeType = false  ;

## If PHP configuration does not have proper MIME type detection you
## may be able to fix MIME detection by being this specific:

#$wgMimeDetectorCommand= "/usr/bin/file -bi ";

/***********************************************************************
 * Debugging
 */

# This debug log file should be not be publicly accessible if it is used, as it
# may contain private data. 
#$wgDebugLogFile         = $IP .'/../log_alvarez/mediawiki-debug.log';
$wgDebugLogFile         = '/usr/local/apache/logs/mediawiki-debug.log';


# See meta:How_to_debug_MediaWiki for information on profiling



/***********************************************************************
 * Skins.  Change the default skin based on entry point filename.
 */

## Default skin: you can change the default skin. Use the internal symbolic
## names, ie 'standard', 'nostalgia', 'cologneblue', 'monobook':
$wgDefaultSkin = 'monobook';
$wgAllowUserCss = true;


/***********************************************************************
 * Policy settings:
 */

// Disabled as per MediaWIki-announce of 22Jan2008
//  (We shouldn't be using this anyway right now)
//
$wgEnableAPI = false;


# Disable edits until we can control user access!!!  
#$wgReadOnly="The wiki is read-only because it is still being set up.";

$wgEmergencyContact = "myers@spy-hill.net";
$wgPasswordSender   = "i2u2-admin@spy-hill.net";

# Turn this back to true for production, but have it off for design and development
$wgEnableParserCache = false;

# Don't allow anonymouse comments on talk pages
$wgDisableAnonTalk=true;


/** 
 * Should editors be required to have a validated e-mail
 * address before being allowed to edit?   Not yet, but someday.
 */
$wgEmailConfirmToEdit=false;

unset($wgWhitelistAccount['user']);


/**
 * Extensions:
 */ 

# Citations via <ref> text </ref> and <references/>
require_once( "{$IP}/extensions/Cite/Cite.php" ); 

# Allow editing of talk pages (or not) even if not allowed to edit articles
require_once("extensions/talkright.php");

# Allow permissions to be set on an entire namespace
require_once( "extensions/NamespacePermissions.php" ); 

# Turn the Media: pseudo-namespace into File:
require_once( "extensions/Media2File.php" );  

#  Automatic BOINC authentication:
require_once("extensions/BOINCAuthPlugin.php");
$BOINC_html = $IP ."/../boinc/html/";
$BOINC_config_xml = $IP ."/../boinc/config.xml";

# Input boxes
require_once("extensions/inputbox.php");

# Parser Functions are used by the Google-trans template                        
require_once( "$IP/extensions/ParserFunctions/ParserFunctions.php" );


/***********
# Multiple languages in a single wiki                                           
require_once( "$IP/extensions/Polyglot/Polyglot.php" );
$wgPolyglotLanguages = array('en', 'es', 'de', 'fr');
$wfPolyglotExcemptTalkPages=true;
$wfPolyglotFollowRedirects=true;

*********/

# Display pages based on skin name as alternate page entry point                
require_once( "$IP/extensions/SkinByURL.php" );

# Bugzilla Reports extension lets us generate bug report lists
# from our Bugzilla site.  Password info is in DatabaseSettings.php 

require_once("$IP/extensions/BugzillaReports/BugzillaReports.php");


/**
 * Groups and Permissions:
 */

/* Implicit group for all visitors (hence all anonymous users)
 * This is where we disable anonymous account creation, page creation, etc.. */

$wgGroupPermissions['*'    ]['read']            = true;   // or false?
$wgGroupPermissions['*'    ]['talk']            = false;  // -EAM 9Jan2008
$wgGroupPermissions['*'    ]['edit']            = false;
$wgGroupPermissions['*'    ]['createtalk']      = false;
$wgGroupPermissions['*'    ]['createpage']      = false;
$wgGroupPermissions['*'    ]['upload']          = false;
$wgGroupPermissions['*'    ]['createaccount']   = false;

/* General group for all authenticated users.  But is that enough? */

$wgGroupPermissions['user' ]['read']            = true;
$wgGroupPermissions['user' ]['talk']            = true;
$wgGroupPermissions['user' ]['createtalk']      = true;
$wgGroupPermissions['user' ]['edit']            = true;
$wgGroupPermissions['user' ]['upload']          = true;
$wgGroupPermissions['user' ]['createpage']      = false;
$wgGroupPermissions['user' ]['createaccount']   = false;

/* Let "bureaucrats" also use 'patrol' */
 
$wgGroupPermissions['bureaucrat']['patrol']         = true;
$wgGroupPermissions['bureaucrat' ]['edit']          = true;
$wgGroupPermissions['bureaucrat' ]['createtalk']    = true;
$wgGroupPermissions['bureaucrat' ]['createpage']    = true;
$wgGroupPermissions['bureaucrat' ]['upload']        = true;
$wgGroupPermissions['bureaucrat']['move']           = true;
$wgGroupPermissions['bureaucrat']['rollback']       = true;
$wgGroupPermissions['bureaucrat']['protect']        = true;
$wgGroupPermissions['bureaucrat']['block']          = true;
$wgGroupPermissions['bureaucrat' ]['createaccount'] = false;


// The permissions for groups based on BOINC special-user bits
// are kept in this separate file:
//
require_once("UserPermissions.php");

?>
