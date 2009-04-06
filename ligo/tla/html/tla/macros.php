<?php
/***********************************************************************\
 * Macros for TLA project for every displayed page.
 * This page just loads (once) the other components.  
 * No code here, please.
 *
 * This does not include root.php or other code which is specific
 * to one or a few pages.  This is just the common stuff.
 *
 * Eric Myers <myers@spy-hill.net  - 30 March 2006
 * @(#) $Id: macros.php,v 1.31 2009/01/29 19:56:16 myers Exp $
\***********************************************************************/

// This makes us more portable 
//
if( !isset($src_path) ) $src_path='';

//TODO: make sure there is a trailing / if someone forgets?//

// Tracking memory usage:

$memory_initial=memory_get_usage();

require_once($src_path."config.php");

// Various function definitions:

require_once($src_path."util.php");             // general utilities

require_once($src_path."auth.php");             // user authentication
require_once($src_path."tickets.php");          // cross-server authentication
require_once($src_path."decoration.php");       // HTML decoration
require_once($src_path."steps.php");            // step management
require_once($src_path."channels.php");         // channel selectors, etc
require_once($src_path."messages.php");         // status message area
require_once($src_path."time.php");             // time conversion and display
require_once($src_path."plot_options.php");     // ROOT plot controls
require_once($src_path."debug.php");            // Debugging messages
require_once($src_path."controls.php");         // user controls 
require_once($src_path."transformations.php");  // data transformation functions
require_once($src_path."elab_interface.php");   // connection to JSP e-Lab code
require_once($src_path."http_util.php");   // connection to JSP e-Lab code

require_once($src_path."debug.php");  
handle_debug_level(); 

debug_msg(4,"TLA_TOP_DIR is $TLA_TOP_DIR");
debug_msg(5,"PHP version: ".phpversion());

?>
