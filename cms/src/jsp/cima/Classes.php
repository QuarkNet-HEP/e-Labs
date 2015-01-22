<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

include 'database.php';
session_start();
if(!isset($_SESSION["AUTHUSER"])){
	header('Location: auth.php');
}

if(isset($_POST["create"])){
	CreateTable($_POST["NewName"],substr($_POST["histsel"],1));
}

if(isset($_POST["Results"]) && $_POST["Results"]=="R"){
	unset($_SESSION["tables"]);
	if(isset($_POST["tselect"]) && $_POST["tselect"]!=""){
		$_SESSION["tables"]=$_POST["tselect"];
	}elseif(isset($_POST["Eselect"]) && $_POST["Eselect"]!=""){
		for($i=0;$i<count($_POST["Eselect"]);$i++){
			$tables=GetTables($_POST["Eselect"][$i]);
				for($j=0;$j<count($tables);$j++){
					$_SESSION["tables"][]=$tables[$j]["id"];
				}
		}
	}
	if(isset($_SESSION["tables"])){
		$_SESSION["comb"]=1;
		header("Location: results.php");
	}
}

if(isset($_POST["delete"]) && $_POST["delete"]=="d"){
	if(isset($_POST["tselect"]) && $_POST["tselect"]!=""){
		foreach($_POST["tselect"] as $t){
			DeleteTable($t);
		}
	}elseif(isset($_POST["Eselect"]) && $_POST["Eselect"]!=""){
		foreach($_POST["Eselect"] as $t){
			DeleteMClassEvent($t);
		}
	}

}
/*
	if(strcmp(substr($_POST["tselect"],-8,1),"n")==0){
		$act=1;
	}else{
		$act=0;
	}
	$tname=str_replace(" (active)","",$_POST["tselect"]);
	$tname=str_replace(" (inactive)","",$tname);*/

$MCE=GetMCEvents();


if(isset($_POST["changeA"]) && $_POST["changeA"]=="cA"){
	for($i=0;$i<count($MCE);$i++){
		for($j=0;$j<count($_POST["Eselect"]);$j++){
			if($_POST["Eselect"][$j]==$MCE[$i]["id"]){
				if($MCE[$i]["active"]==0){
					SetActivation($MCE[$i]["id"],1);
					$MCE[$i]["active"]=1;
				}else{
					SetActivation($MCE[$i]["id"],0);
					$MCE[$i]["active"]=0;

				}
			}
		}
	}
}

if(isset($_POST["chist"])){
	CreateHist($_POST["HistName"]);
}

$freetables=GetIndTables();

include 'templates/header.tpl';
include 'templates/AA.tpl';
//$_SESSION["currentT"]=$tables;

include 'templates/floor.tpl';

?>
