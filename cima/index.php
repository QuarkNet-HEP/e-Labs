<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
session_start();
session_destroy();
include 'database.php';
include 'templates/header.tpl';
$MCE=GetMCEvents();
include 'templates/front.tpl';
include 'templates/floor.tpl';

?>

