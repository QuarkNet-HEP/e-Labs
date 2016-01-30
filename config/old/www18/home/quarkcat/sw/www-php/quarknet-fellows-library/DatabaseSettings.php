<?php
/***********************************************************************\ 
 * Database settings for the wiki.
 *
 * To protect the passwords in this file, 
 *   a) do not check this file into CVS
 *   b) chmod o-r  to remove world read permissions.
 *   c) chgrp apache (or www-data on Debian systems) and chmod g+r
 *      to that the web server can read the file.
 * Beware that if/when you edit the file the group may revert to a default
 * and the file will no longer be readable by the web server.
 * 
 * Eric Myers <Eric.Myers@ligo.org> 
 * @(#) Last changed: -EAM 03Jul2008
\***********************************************************************/ 

$wgDBtype           = "mysql";
$wgDBserver         = "";
$wgDBname           = "";
$wgDBuser           = "";
$wgDBpassword       = "";
$wgDBport           = "5432";
$wgDBprefix         = "";

# MySQL table options to use during installation or update
$wgDBTableOptions   = "TYPE=InnoDB";

# Schemas for Postgres
$wgDBmwschema       = "mediawiki";
$wgDBts2schema      = "public";

# Experimental charset support for MySQL 4.1/5.0.
$wgDBmysql5 = false;

?>
