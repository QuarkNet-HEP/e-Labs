<?php
  /**************************
   *
   *************************/

require_once("../inc/util_ops.inc");
require_once("../inc/db.inc");
require_once("../inc/uotd.inc");

db_init();

if( empty($_SERVER['SERVER_ADDR']) ) {
    echo "update_uotd.php:  Update the user of the day\n";
    echo "=================================================\n";
   build_uotd_page();
   exit;
 }

admin_page_head("Update User of the Day");
echo "<P><pre>\n";
build_uotd_page();
echo "</pre><p>\n";
admin_page_tail();

?>
