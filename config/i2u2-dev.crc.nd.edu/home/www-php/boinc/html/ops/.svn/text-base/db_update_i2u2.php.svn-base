#! /usr/bin/env php
<?php
/***********************************************************************\
 * Database updates - specific to the I2U2 project, beyond basic BOINC
 *
 *
\***********************************************************************/

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/ops.inc");

// Utilities to make it easier to do a database update
//
require_once("../include/db_update_util.php");


cli_only();
$rc = db_init_cli();
if($rc != 0) {
    echo "ERROR: Cannot connect to database.  RC=$rc \n";
    exit($rc);
 }


set_time_limit(0);

// e-Lab research group name and password are saved so that students
// don't have to keep entering it

function update_5_08_2008(){
    description("Table to save elab group and password");
    do_query("CREATE TABLE elab_group (
        userid              integer     not null,
        elab_name           varchar(16) not null,
        group_name          varchar(64) not null,
        password            varchar(64) not null,
        timestamp           int, 
        PRIMARY KEY ( `userid` , `elab_name`)
                ) TYPE=MyISAM;");

}


update_5_08_2008();

?>
