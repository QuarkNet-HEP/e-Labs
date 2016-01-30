<?php
session_start();

include 'database.php';

$temp=GetHistDataForTable($_SESSION["database"]);
$data=explode(";",$temp["data"]);
if($_POST["d"]!=1){
	$data[$_POST["x"]]++;
}elseif($data[$_POST["x"]]!=0){
	$data[$_POST["x"]]--;
}
$d=implode(";",$data);

//print_r($_SESSION);
UpData($d,$_SESSION["currentHist"]["id"]);
$_SESSION["currentHist"]["data"]=$d;
echo $d;
?>
