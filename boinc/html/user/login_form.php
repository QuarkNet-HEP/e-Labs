<?php
    require_once("../inc/db.inc");
    require_once("../inc/util.inc");

    require_once("../include/util.php"); // additional useful stuff


    db_init();
    $user = get_logged_in_user(false);

    //$next_url = $_GET["next_url"];
    $next_url = get_destination();

    page_head("Log in/out");
    print_login_form_aux($next_url, $user);
    page_tail();
?>
