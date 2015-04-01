<?php
session_destroy();
session_start();


if(isset($_POST["submit"])&& $_POST["username"]=="Admin"&& $_POST["password"]=="Cima4CMS2"){
	$_SESSION["AUTHUSER"]=true;
	header('Location: Classes.php');	
}
	
include "templates/header.tpl";
//print_r($_POST);
include "templates/auth.tpl";
include "templates/floor.tpl";
?>
