<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include "database.php";

session_start();

if(!isset($_SESSION["database"]) || !isset($_SESSION["groupNo"])){
	header("Location: index.php");
}


if(isset($_POST["fin"]) && $_POST["CustomEvent"]!=""){
	$checked="";
		foreach ($_POST as $k => $v){
			if(strcmp($k,"CustomEvent")!=0 && strcmp($k,"OM")!=0 && strcmp($k,"fin")!=0 ){
				$checked=$checked.$v.";";
			}
		}
		$checked=substr($checked,0,-1);
		WriteEntry($_SESSION["database"],$_POST["CustomEvent"],$checked);
}

if(isset($_POST["fedit"])&&$_POST["fedit"]!=""){
	unset($_SESSION["edit"]);
}

$arr=GetEvents($_SESSION["groupNo"],$_SESSION["database"]);

$freeEvents=GetFreeEvents($_SESSION["groupNo"],$_SESSION["database"]);

if(!isset($freeEvents) && !isset($_SESSION["edit"])){
	header("Location: finish.php");
}

if(isset($_POST["CustomEvent"]) && isset($_SESSION["current"]) && $_SESSION["current"]["id"]!=$_POST["CustomEvent"] && !isset($_POST["fin"])){
	$event=GetEvent($_POST["CustomEvent"]);
}else{
	$event=GetNext($arr,$_SESSION["groupNo"]);
	
}

include 'templates/header.tpl';
if(isset($event)){
	$_SESSION["current"]=$event;
}


$script=0;
include 'templates/navbar.tpl';

include 'templates/table.tpl';

function showM($checked){
	$arr=explode(";",$checked);
	
	if((in_array("H",$arr) || in_array("Z",$arr))){
		return true;
	}else{
		return false;
	}
}

//tempE=GetAllEvents($SESSION["database"]);
for($i=(count($arr)-1);$i>=0;$i--){
	//$tempE=GetEvent($arr[$i]["id"]);
	echo '<div class=row id="'.$arr[$i]["id"].'" style="cursor: pointer;" onmouseover="showdel(this)" onmouseout="nshowdel(this)" onclick="del(this)">
		<div class=col-md-3> 
			'.$arr[$i]['id'].' 
		</div>
		<div class=col-md-3>
			'.$arr[$i]['ev'].'
		</div>
		<div class=col-md-2>
			&nbsp'.$arr[$i]["checked"].'
		</div>
		<div class=col-md-1>';
	if(showM($arr[$i]["checked"])){
		echo round($arr[$i]['mass'],3);
	}
	echo '</div> <div class=col-md-2 align="right" id="del-'.$arr[$i]["id"].'"> </div>	</div>';
}
echo '</div></div></div></div></div></div>';

include 'templates/floor.tpl';

$s=0;
for($i=0;$i<count($arr);$i++){ 
	$s.=$arr[$i]["id"].":".$arr[$i]['mass'].";"; 
}
?>
<script> var massGlobal= '<?php echo $s ?>';</script>;

