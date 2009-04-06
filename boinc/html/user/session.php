<?php
/*
 * session.php - dump session variables
 *
 *
 * Eric Myers <myers@spy-hill.net>  - 24 March 2006
 * @(#) $Date: 2006/12/14 18:31:37 $ + $Revsion:$ + $Name:  $
 ************************************************************************/

require_once('../inc/db.inc');
require_once('../inc/util.inc');

db_init(1);
$logged_in_user = get_logged_in_user(false);


page_head(PROJECT . " - SESSION variables",true);

if ( ! $fh = fopen("/tmp/PHP_session.txt", "w") ) {
  debug_msg(4,"cannot open output file /tmp/PHP_session.txt");
}


echo "
  <blockquote>
    ";


// Dump the _SESSION list 

$page="
    <p>
    <u>PHP _SESSION</u><br/>
    ";

if (!empty($_SESSION)){
  foreach($_SESSION as $key=>$value){
    $page .= "$key => $value <br/>\n";
  }
}
else {
  $page ="<p>No _SESSION variables</p>\n";
}

echo $page;
if ( $fh ) fwrite($fh, $page);





// Dump the _GLOBAL list 

$page="
    <p>
    <u>PHP _GLOBAL</u><br/>
    ";

if ($_GLOBAL){
  foreach($_GLOBAL as $key=>$value){
    $page .= "$key => $value <br/>\n";
  }
}
else {
  $page ="<p>No _GLOBAL variables</p>\n";
}

echo $page;
if ( $fh ) fwrite($fh, $page);





// Dump the _GET list 

$page="
    <p>
    <u>PHP _GET</u><br/>
    ";

if ($_GET){
  foreach($_GET as $key=>$value){
    $page .= "$key => $value <br/>\n";
  }
}
else {
  $page ="<p>No _GET variables</p>\n";
}

echo $page;
if ( $fh ) fwrite($fh, $page);






// Dump the _POST list 

$page="
    <p>
    <u>PHP _POST</u><br/>
    ";

if ($_POST){
  foreach($_POST as $key=>$value){
    $page .= "$key => $value <br/>\n";
  }
}
else {
  $page ="<p>No _POST variables</p>\n";
}

echo $page;
if ( $fh ) fwrite($fh, $page);





// Dump the _COOKIE list 

$page="
    <p>
    <u>PHP _COOKIE</u><br/>
    ";

if (!empty($_COOKIE)){
  foreach($_COOKIE as $key=>$value){
    $page .= "$key => $value <br/>\n";
  }
}
else {
  $page ="<p>No _COOKIE variables</p>\n";
}

echo $page;
if ( $fh ) fwrite($fh, $page);









///////////

echo "</blockquote>\n";
fclose($fh);


page_tail(true);


?>
