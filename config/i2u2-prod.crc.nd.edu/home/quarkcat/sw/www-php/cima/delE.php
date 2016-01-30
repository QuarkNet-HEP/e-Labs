<?php
session_start();
include 'database.php';
if(isset($_POST["row"])){
	DelRow($_POST["row"],$_SESSION["database"]);
}
?>
