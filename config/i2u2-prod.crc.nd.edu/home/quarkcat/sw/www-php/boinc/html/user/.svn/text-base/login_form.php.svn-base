<?php
    require_once("../inc/db.inc");
    require_once("../inc/util.inc");

    require_once("../include/util.php"); // additional useful stuff

    require_once("../include/debug.php");
    //set_debug_level(3);


    db_init();
    $user = get_logged_in_user(false);

    $next_url = get_destination();

    page_head("Log in/out");
    print_login_form_aux($next_url, $user);

    if( $debug_level > 0 ) {
      echo "\n<font color='grey'>Destination: $next_url</font>\n";
    }
    page_tail();
?>
