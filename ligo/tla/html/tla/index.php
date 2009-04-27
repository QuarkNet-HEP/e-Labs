<?php
/***********************************************************************\
 * index.php - entry point for Bluestone, the LIGO Analysis Tool
 *
 * This page arranges for proper authentication and redirects 
 * to the proper place.   It does not actually display anything.
 *
 * Eric Myers <myers@spy-hill.net  - 31 July 2008
 * @(#) $Id: index.php,v 1.10 2009/04/22 18:18:41 myers Exp $
\***********************************************************************/

require_once("macros.php");             // general TLA utilities

check_authentication();
handle_reset();
//set_debug_level(3);


recall_variable('elab_group');
recall_variable('elab_cookies');

debug_msg(4, "this_dir is $this_dir, self is $self");

// Initialize steps
//
if( !isset($main_steps) ) {
    main_steps_init('main_steps');
 }
debug_msg(4,"main_steps will pass us to " . $main_steps[1]->url );


// Determine destination
//
$next_url = get_destination();
if( empty($next_url) ){
    $next_url=fill_in_url($this_dir."/" . $main_steps[1]->url);
 }

debug_msg(2,"index: next_url is $next_url");

// get student elab_group or cookie
// BYPASS THIS FOR NOW...

debug_msg(2,"auth_type: $auth_type");

if( 0 && ($auth_type == 'referer' || $_SESSION['AUTH_TYPE'] == 'referer') ){

    if( empty($elab_group) || empty($elab_cookies[$elab]) ){// need login?

        // Can't do it if we don't have the right tools
        if( !function_exists('http_get') ){
            add_message("Just so you know, it won't be possible to connect"
                        ." to the e-Lab site" , MSG_WARNING);
            add_message("(Bluestone requires the http_pecl extension for that.)"
                        , MSG_INFO);
	}
    else {
        add_message("You need to grant Bluestone access to your e-Lab.");
        add_message("Please enter the name and password of your research group.");
	set_destination($next_url);
        $u = $this_dir."/elab_login.php";
        debug_msg(1,"Jumping to $u...");
        //header("Location: " .$u);      // Redirect!
        //exit(0);        
    }
 }
 else {
     debug_msg(2,"Research group: $elab_group");
     debug_msg(3,"JSESSIONID cookie: ". $elab_cookies[$elab]['Value']);
 }
}


// Go to default starting point
//
debug_msg(3,"Location: $next_url");
if( $debug_level < 3 ) {// TESTING ONLY - TO BE REMOVED
    header("Location: $next_url");
    exit(0);
 }


$cvs_version_tracker[]=        //Generated automatically - do not edit
    "\$Id: index.php,v 1.10 2009/04/22 18:18:41 myers Exp $";


/***********************************************************************\
 * Display Page: this is only here for debugging for level 3
\***********************************************************************/

add_message("<a href='$next_url'>Get Started...</a>");

html_begin("Welcome to the LIGO e-Lab");
debug_msg(5,"elab_cookies: <pre>". print_r($elab_cookies,true)."</pre>");

controls_begin();

controls_end();
html_end();

?>
