<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include "database.php";

session_start();
$script=0;
$backup=GetConnection($_SESSION["databaseId"],$_SESSION["groupNo"]);

$freeEvents=GetFreeEvents($_SESSION["groupNo"],$_SESSION["database"]);
if(isset($freeEvents)){
	header('Location: fillOut.php');
}

if(isset($_POST["load"]) && $_POST["load"]!=""){
	if(!isset($backup)){
		AddGroupsToTable($_SESSION["databaseId"],$_POST["load"],1);
		connectGroups($_SESSION["databaseId"],$_SESSION["groupNo"],$_POST["load"]);
	}

	$_SESSION["backup"]=1;
	
	$_SESSION["groupNo"]=$_POST["load"];
	header("Location: fillOut.php");
}

if(isset($_POST["edit"]) && $_POST["edit"]!=""){
	$_SESSION["edit"]=1;
	header("Location: fillOut.php");
}


if(!isset($backup)){
	$boundTables=GetTables($_SESSION["MasterClassId"]);

	if(is_array($boundTables)){
		$temp=GetGroups($boundTables);
			if(is_array($temp)){
				for($j=0;$j<count($temp);$j++){
					$boundGroups[]=$temp[$j]["g_no"];
				}
			}
	}
	if(!isset($boundGroups)){
		$boundGroups=0;
	}

	$freeGroups=GetFreeGroups($boundGroups,0);

}else{
	$freeEvents=GetFreeEvents($backup,$_SESSION["database"]);

	if(!isset($freeEvents)){
		$_SESSION["groupNo"]=$backup;
		header("Refresh:0");
	}else{
		$freeGroups[0]=$backup;
	}
}




include "templates/header.tpl";
include 'templates/navbar.tpl';

if(isset($freeGroups)){
	include "templates/GetNext.tpl";
}else{
	include "templates/done.tpl";
}

include 'templates/floor.tpl';
?>
