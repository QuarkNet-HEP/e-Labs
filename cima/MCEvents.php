<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);

include 'database.php';
session_start();

if(!isset($_SESSION["AUTHUSER"])){
	header('Location: auth.php');
}



if(!isset($_POST["EventName"]) && !isset($_SESSION["EventName"]) && !isset($_POST["Edit"])){
	header('Location: Classes.php');
}


if(isset($_POST["EventName"])){
	$_SESSION["EventName"]=$_POST["EventName"];
	CreateEvent($_POST["EventName"]);
	$e=GetLastEvent();
	$_SESSION["EventID"]=$e["id"];
}

if(isset($_POST["Edit"])){
	$_SESSION["EventID"]=$_POST["Eventsel"];
	$e=GetMClassEvent($_POST["Eventsel"]);
	$_SESSION["EventName"]=$e["name"];
}

if(isset($_POST["overlab"]) && $_POST["overlab"]=="o"){
		$_SESSION["overlab"]=1;

}else{
	$_SESSION["overlab"]=0;
}


if(isset($_POST["CreateT"])){
	if(isset($_POST["tableName"])){
		$id=CreateTable($_POST["tableName"],$_POST["Groups"]);
		AddTablesToEvent($id,$_SESSION["EventID"]);
	}
}

if(isset($_POST["bind"]) && $_POST["bind"]=="bind"){
	if(isset($_POST["Ftables"])){
		AddTablesToEvent($_POST["Ftables"],$_SESSION["EventID"]);
	}
}

if(isset($_POST["free"]) && $_POST["free"]=="free"){
	if(isset($_POST["BTables"])){
		RemoveTablesFromEvent($_POST["BTables"],$_SESSION["EventID"]);
	}
}

if(isset($_POST["finished"]) && $_POST["finished"]=="finished"){
	header('Location: Classes.php');
}



if(isset($_POST["AddG"]) && $_POST["AddG"]=="AddG" && isset($_POST["Groups"])){
	AddGroupsToTable($_POST["Tsel"],$_POST["Groups"]);
}


if(isset($_POST["DelG"]) && $_POST["DelG"]=="DelG" && isset($_POST["Bgroups"]) && (isset($_POST["BTables"]) || isset($_POST["Ftables"]))){
	if(isset($_POST["BTables"]) && !isset($_POST["Ftables"])){
		$tables=$_POST["BTables"];
	}	
	elseif(!isset($_POST["BTables"]) && isset($_POST["Ftables"])){
		$tables=$_POST["Ftables"];

	}
	elseif(isset($_POST["BTables"]) && isset($_POST["Ftables"])){
		$tables=array_merge($_POST["BTables"],$_POST["Ftables"]);

	}
	DelGroupsFromTables($tables,$_POST["Bgroups"]);
}

$boundTables=GetTables($_SESSION["EventID"]);

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
$indTables=GetFreeTables($_SESSION["EventID"],$boundGroups,$_SESSION["overlab"]);
$freeGroups=GetFreeGroups($boundGroups,$_SESSION["overlab"]);

include 'templates/header.tpl';

//print_r($_POST);
//print_r($_SESSION);

include 'templates/MCEvents.tpl';

include 'templates/floor.tpl';
