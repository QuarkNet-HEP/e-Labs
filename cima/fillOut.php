<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
include "database.php";

/* Prepare to use session variables and set a session cookie */
session_start();

/* If a database or group # have not been set yet, load the index page */
if(!isset($_SESSION["database"]) || !isset($_SESSION["groupNo"])){
	header("Location: index.php");
}

/* How many decimal places to use when rounding masses */
$rnd=2;
/* Allowed labels for particle states */
$stateLabels = array('e','mu','W+','Wp','W-','W','Z','Zed','H','Higgs','Zoo'); 

/* If the form is submitted with a nonempty CustomEvent,
	   define a $checked string for that event */
/* Introduced $strUserInput as alternative 27Jan2017 JG */
if(isset($_POST["fin"]) && $_POST["CustomEvent"]!=""){
	$strUserInput="";
	/* Create $strUserInput out of the POST array */
	/* First, the id's of any checkboxes the user selected */
	foreach ($_POST as $k => $v){
		if( in_array($v,$stateLabels) ){
			$strUserInput=$strUserInput.$v.";";
		}
	}
	/* Second, the optional user-input mass */
	if( array_key_exists("massEntry", $_POST) ){
		/* Check to make sure user entered actual number for mass */
		if( !is_numeric($_POST["massEntry"]) ){
			$strUserInput=$strUserInput."NaN;";
		} else{
			$strUserInput=$strUserInput.$_POST["massEntry"].";";
		}
	}
	/* Remove the superfluous final semicolon: */
	$strUserInput=substr($strUserInput,0,-1);
	/* WriteEntry() defined in database.php */
	/* Write the custom event and its POSTed data to the database */
	WriteEntry($_SESSION["database"],$_POST["CustomEvent"],$strUserInput);
}

/* Is the session being edited? */
if(isset($_POST["fedit"]) && $_POST["fedit"]!=""){
	unset($_SESSION["edit"]);
}

/* Define $arr.  This happens at every Submit */
/* GetEvents() and GetFreeEvents() are defined in database.php */
$arr=GetEvents($_SESSION["groupNo"],$_SESSION["database"]);

$freeEvents=GetFreeEvents($_SESSION["groupNo"],$_SESSION["database"]);

if(!isset($freeEvents) && !isset($_SESSION["edit"])){
	header("Location: finish.php");
}

if(isset($_POST["CustomEvent"]) && isset($_SESSION["current"]) && !isset($_POST["fin"])){
	$event=GetEvent($_POST["CustomEvent"]);
}else{
	$event=GetNext($arr,$_SESSION["groupNo"]);
}

function calcEv($id){
	return $_SESSION["groupNo"].'-'.$id%100;
}

include 'templates/header.tpl';
if(isset($event)){
	$_SESSION["current"]=$event;
}

$script=0;
include 'templates/navbar.tpl';

/* The particle selection panel: */
include 'templates/table.tpl';

/* Show the mass from the DB in the analysis table? */
function showMassDB($checked){
	$arrChecked=explode(";",$checked);
	if(in_array("H",$arrChecked)){
		return true;
	}else{
		return false;
	}
}

/* Show the mass from the Input Box in the analysis table? */
function showMassInput($checked){
	$arrChecked=explode(";",$checked);
	if(in_array("Z",$arrChecked)){
		return true;
	}else{
		return false;
	}
}

/* Extract the user-entered mass from $checked */
/* JG 25Jan2017 */
function userMass($checked){
	global $rnd;
	$arrChecked=explode(";",$checked);
	if( is_numeric(end($arrChecked)) ){
		return round(end($arrChecked),$rnd);	
  } else{
		return end($arrChecked);
	}
}

/* Extract the user-entered checkboxes from $checked */
/* JG 25Jan2017 */
function userChecks($checked){
	global $stateLabels;
  $arrChecked=explode(";",$checked);
	$strTemp="";
	foreach ($arrChecked as $k => $v){
		if(in_array($v,$stateLabels)){
		  if(strcmp($v,"mu")==0){
				/* Print actual \mu's :) */
				$strTemp=$strTemp."&mu;, ";
			} else{
				$strTemp=$strTemp.$v.", ";
			}
		}
	}
  return substr($strTemp,0,-2);
}

/* Create the analysis table line-by-line */
/* Column headers are in table.tpl */
for($i=(count($arr)-1);$i>=0;$i--){
	echo '<div class=row id="'.$arr[$i]["id"].'" style="cursor: pointer;" onmouseover="showdel(this)" onmouseout="nshowdel(this)" ondblclick="del(this)">
		<div class=col-md-3>
			'.($arr[$i]['id'] % 100).'
		</div>
		<div class=col-md-3>
			'.calcEv($arr[$i]['id']).'
		</div>
		<div class=col-md-2>
			'.userChecks($arr[$i]['checked']).'
		</div>
		<div class=col-md-1>'; /* end of echo */
			if(showMassDB($arr[$i]['checked'])){
				echo round($arr[$i]['mass'],$rnd);
			} else if(showMassInput($arr[$i]['checked'])){
		  	echo userMass($arr[$i]['checked']);
  		}
	echo '</div> <div class=col-md-2 align="right" id="del-'.$arr[$i]["id"].'"> </div>	</div>';
}
echo '</div></div></div></div></div><div class=col-md-2></div></div>';

include 'templates/floor.tpl';

$s=0;
for($i=0;$i<count($arr);$i++){
	$s.=$arr[$i]["id"].":".$arr[$i]['mass'].";";
}
?>
<script> var massGlobal= '<?php echo $s ?>'; var group='<?php echo $_SESSION["groupNo"] ?>';</script>


