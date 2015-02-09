<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);
session_start();
//session_destroy();

$_SESSION["groupNo"]=31;
$_SESSION["database"]="T2";
$_SESSION["databaseId"]=8;

$_SESSION["MasterClass"]="test";
$_SESSION["MasterClassId"]=2;

include "fillOut.php";
//print_r($_SESSION);
/*$q="SELECT MAX(id) FROM histograms";
$res=askdb($q);
$obj=$res->fetch_object();
print_r($obj);
print($obj->MAX(id));*/


?>
