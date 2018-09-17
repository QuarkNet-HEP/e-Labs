<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include "database.php";

session_start();
//print_r($_SESSION);
$script=1;

include 'templates/header.tpl';

echo '<script src="js/Chart.js"> </script>';
echo '<script src="js/MakeCharts.js"> </script>';

/* $_SESSION["comb"] is set in Classes.php */
if(!isset($_SESSION["comb"])){
	if(!isset($_SESSION["database"])){
		header("Location: index.php");
	}
	include 'templates/navbar.tpl';
	include 'templates/hist.tpl';

	$datax=GetHistDataForTable($_SESSION["database"]);
	$_SESSION["currentHist"]=$datax;
}else{
	$basescript="hist.php";
	if(isset($_SESSION["tables"])){
		if(isset($_GET["i"])){
			$tables[]=$_SESSION["tables"][$_GET["i"]];
		}else{
			$tables=$_SESSION["tables"];
		}
		include 'templates/Resnav.tpl';
		include 'templates/histBackend.tpl';


		foreach($tables as $t){
			$table=GetTableByID($t);
			$pretemp=GetHistDataForTable($table["name"]);
			$temp=explode(";",$pretemp["data"]);
			//print_r($temp);
			if(!isset($data)){
				$data=$temp;
			}else{
				for($i=0;$i<count($temp);$i++){
					$data[$i]=$data[$i]+$temp[$i];
				}
			}
		}
		$datax["data"]=implode(";",$data);
	}else{
	header("Location: Classes.php");
	}
}



echo '<script> MakeHist("'.$datax["data"].'"); </script>';
include 'templates/floor.tpl';
?>