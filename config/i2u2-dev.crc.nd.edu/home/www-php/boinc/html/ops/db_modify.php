<?php
/***********************************************************************\
 * Modifications to the BOINC database for I2U2 and related projects.
 * These are not officially part of BOINC (maybe some will some day?)
 * Tested on Pirates@Home first.
 *
 * Updates are enclosed in functions; you have to invoke them at the end
 * of the script, just as is done in db_update.php for BOINC updates.
 *
 * Eric Myers <myers@spy-hill.net> - 3 August 2006
 * $Date: 2006/10/20 20:42:38 $ + $Revision: 1.2 $ + $Name:  $
\***********************************************************************/

require_once("../inc/db.inc");
require_once("../inc/util.inc");
require_once("../inc/ops.inc");

cli_only();
db_init_cli();

set_time_limit(0);

function do_query($query) {
    echo "Doing query:\n$query\n";
    $result = mysql_query($query);
    if (!$result) {
        die("Failed!\n".mysql_error());
    } else {
        echo "Success.\n";
    }
}

// Add 'keyword' item to postings

function add_post_keyword() {
  $cmd= "ALTER TABLE post ADD keyword varchar(254)";
  do_query($cmd);
}


// Add forum_attachment table

function add_forum_attachment() {
    do_query(
     "CREATE TABLE forum_attachment (
        id              integer     not null auto_increment,
        post            integer     not null,   
        user            integer     not null,   -- creator's id
        timestamp       integer     not null,   -- create time
        caption         varchar(254), 
        orig_filename   varchar(254), -- original file name
        filename        varchar(254), -- where it lives now
        ext             char(5),      -- original file extension
        filetype        varchar(63),  -- MIME type or similar
        size            integer,
        md5             varchar(33),
        hidden          tinyint(1) unsigned not null default 0,
        primary key (id)
        ) type=InnoDB"
    );
}

//Pirates@Home only: we forgot this field at first

function add_attach_ext(){
    do_query(
     "ALTER TABLE forum_attachment ADD  ext char(5)"
    );
}


// Add file_locker item table

function add_file_locker() {
    do_query(
     "CREATE TABLE locker_item (
        id              integer     not null auto_increment,
        user            integer     not null,   -- creator's id
        timestamp       integer     not null,   -- create time
        description     varchar(254), -- brief description
        orig_filename   varchar(254), -- original file name
        ext             char(5),      -- original file extension
        filepath        varchar(254), -- where it lives now
        filetype        varchar(63),  -- MIME type or similar
        size            integer,
        md5             varchar(33),
        hidden          tinyint(1) unsigned not null default 0,

//...TODO           -- source
        file_source     
        orig_owner         


        primary key (id)
     ) type=InnoDB"
    );
}









/********************************
 * Make it so!
 */

//add_post_keyword();
//add_forum_attachment();
//add_attach_ext();


?>
