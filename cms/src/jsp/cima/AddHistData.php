<?php
session_start();
include 'database.php';
print($_POST["d"]);
$data=explode(";",$_SESSION["currentHist"]["data"]);
if($_POST["d"]!=1){
	$data[$_POST["x"]]++;
}elseif($data[$_POST["x"]]!=0){
	$data[$_POST["x"]]--;
}
$d=implode(";",$data);

//print_r($_SESSION);
UpData($d,$_SESSION["currentHist"]["id"]);
$_SESSION["currentHist"]["data"]=$d;
?>
