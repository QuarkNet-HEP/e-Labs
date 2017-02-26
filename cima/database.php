<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

$con=mysqli_connect("i2u2-db.crc.nd.edu","cima","cim@us3r","Masterclass");
if (mysqli_connect_errno($con)) {
 echo "Failed to connect to MySQL: " . mysqli_connect_error();
}

function askdb($q){
	global $con; /* the connection defined above */
	$res=$con->query($q);
	return $res;
}

/* For $group, return its events from the Events table that HAVEN'T
	 already been set in its working $table */
function GetFreeEvents($group,$table){
  $q="SELECT o_no FROM Events WHERE g_no=".$group." AND NOT o_no IN (SELECT o_no FROM `".$table."` WHERE g_no=".$group.") ORDER BY o_no";
	$res=askdb($q);
	while($obj=$res->fetch_object()){
		$result[]=$obj->o_no;
	}
	if(isset($result)){
		return $result;
	}
}

function AddTablesToEvent($tables,$eventID){
	if(isset($tables) && isset($eventID)){
		if(!is_array($tables)){
			$q="INSERT INTO EventTables (tableid,MclassEventID) VALUES (".$tables.",".$eventID.")";
			askdb($q);
		}else{

			for($i=0;$i<count($tables);$i++){
				$q="INSERT INTO EventTables (tableid,MclassEventID) VALUES (".$tables[$i].",".$eventID.")";
				askdb($q);
			}
		}
	}
}

function RemoveTablesFromEvent($tables,$eventID){
	if(isset($tables) && is_array($tables) && isset($eventID)){
		for($i=0;$i<count($tables);$i++){
			$q="DELETE FROM EventTables WHERE tableid=".$tables[$i]." AND MclassEventID=".$eventID;
			askdb($q);
		}
	}
}

function GetAllEvents($table){
	$q="SELECT * FROM `".$table."`";
	$res=askdb($q);
	while($obj=$res->fetch_object()){
			$temp["id"]=$obj->o_no;
			$temp["checked"]=$obj->checked;
			$result[]=$temp;
		}
	if(isset($result)){
		return $result;
	}
}

function GetEvents($group,$table){
    $q="SELECT `".$table."`.o_no, `".$table."`.checked, Events.mass FROM `".$table."` LEFT OUTER JOIN Events ON `".$table."`.o_no = Events.o_no WHERE g_no=".$group." ORDER BY `".$table."`.o_no;";
    $res=askdb($q);
		while($obj=$res->fetch_object()){
			$temp["id"]=$obj->o_no;
			$temp["checked"]=$obj->checked;
			$temp["mass"]=$obj->mass;
			$result[]=$temp;
		}
	if(isset($result)){
		return $result;
	}
}

function GetEvent($o_no){
	$q="SELECT * FROM Events WHERE o_no=".$o_no;

	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result["id"]=$obj->o_no;
		$result["g"]=$obj->g_no;
		$result["mass"]=$obj->mass;
	}else{
		print("error");
		return 0;
		}
	return $result;
}

function GetNext($finEvents,$g_no){
	$k=0;
	$c=0;
	if(isset($finEvents) && is_array($finEvents) && (($g_no-1)*100+1) == $finEvents[0]["id"]){
	for($i=$finEvents[0]["id"];$c<200;$i++){
				$k=$i;
				if(!array_key_exists(($i-$finEvents[0]["id"]),$finEvents)){
					break;
				}
				if($i<$finEvents[($i-$finEvents[0]["id"])]["id"]){
					break;
				}
		}
		$q="SELECT * FROM Events WHERE g_no=".$g_no." AND o_no=".$k;
	}else{
		$q="SELECT * FROM Events WHERE g_no=".$g_no." AND o_no=".((($g_no-1)*100)+1);
	}
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result["id"]=$obj->o_no;
		$result["g"]=$obj->g_no;
		$result["mass"]=$obj->mass;
	}
	if(isset($result)){
		return $result;
	}
}

function WriteEntry($table,$o_no,$checked){
	/* Find the given number o_no in the given table */
	$q="SELECT o_no FROM `".$table."` WHERE o_no=".$o_no;
	$res=askdb($q);
	/* If it's not found, insert it into the table along with the
			 given $checked array */
	if(!$res->fetch_object()){
		$q="INSERT into `".$table."` (o_no,checked) VALUES (".$o_no.",'".$checked."')";
		askdb($q);
	}
}

function DelRow($id,$table){
	$q="DELETE FROM `".$table."` WHERE o_no=".$id;
	askdb($q);
}

function DeleteTable($tableid){
	$q="SELECT hist,name FROM Tables WHERE id=".$tableid;
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$histid=$obj->hist;
		$name=$obj->name;
	}

	$q="DROP TABLE `".$name."`";
	askdb($q);

	$q="DELETE FROM Tables WHERE id='".$tableid."'";
	askdb($q);

	$q="DELETE FROM TableGroups WHERE tableid=".$tableid;
	askdb($q);
	$q="DELETE FROM EventTables WHERE tableid=".$tableid;
	askdb($q);

	$q="DELETE FROM groupConnect WHERE tableid=".$tableid;
	askdb($q);

	$q="DELETE FROM histograms WHERE id=".$histid;
	askdb($q);
}

function DeleteMClassEvent($MClassid){
	$q="DELETE FROM MclassEvents WHERE id=".$MClassid;
	askdb($q);
	$q="DELETE FROM EventTables WHERE MclassEventID=".$MClassid;
	askdb($q);
}

function GetAllTables(){
	$q="SELECT * FROM Tables";
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$temp["hist"]=$obj->hist;
		$temp["name"]=$obj->name;
		$temp["active"]=$obj->active;
		$result[]=$temp;
	}
	if(isset($result)){
		return $result;
	}
}

function SetActivation($id,$act){
	$q="UPDATE MclassEvents SET active=".$act." WHERE id='".$id."'";
	askdb($q);
}

function CreateHist(){
	$data="";
	for($i=0;$i<68;$i++){
		$data=$data."0;";
	}
	$data=substr($data,0,-1);
	$q="INSERT INTO histograms (data) VALUES ('".$data."')";
	askdb($q);
}

function AddGroupsToTable($tableid,$Groups,$PostAdded=0){
		if(isset($Groups) && isset($tableid)){
			if(is_array($Groups)){
				for($i=0;$i<count($Groups);$i++){
					$q="SELECT * FROM TableGroups WHERE tableid=".$tableid." AND g_no=".$Groups[$i];
					$res=askdb($q);
					if(!$res->fetch_object()){
						$q="INSERT INTO TableGroups (g_no,tableid,postAdded) VALUES (".$Groups[$i].", ".$tableid.", $PostAdded)";
						askdb($q);
					}
				}
			}else{
				$q="SELECT * FROM TableGroups WHERE tableid=".$tableid." AND g_no=".$Groups;
				$res=askdb($q);
				if(!$res->fetch_object()){
					$q="INSERT INTO TableGroups (g_no,tableid,postAdded) VALUES (".$Groups.", ".$tableid.", $PostAdded)";
					askdb($q);
				}
			}
		}
}

function DelGroupsFromTables($tables,$groups){
		if(isset($tables) && isset($groups)){
			if(is_array($tables)){
				$tstr=implode(",",$tables);
			}else{
				$tstr=$tables;
			}
			if(is_array($groups)){
				$gstr=implode(",",$groups);
			}else{
				$gstr=$groups;
			}

			$q="DELETE FROM TableGroups WHERE tableid IN (".$tstr.") AND g_no IN (".$gstr.")";
			askdb($q);
		}
	}

function CreateTable($name,$Groups){
	$q="SELECT name FROM Tables WHERE name='".$name."'";
	$res=askdb($q);
	if(!$res->fetch_object() && isset($name) && $name!=""){
		$q="CREATE TABLE `".$name."` (o_no INT, checked VARCHAR(20));";
		askdb($q);

		CreateHist();

		$q="SELECT MAX(id) AS id FROM histograms";
		$res=askdb($q);
		$histid=$res->fetch_object()->id;

		$q="INSERT INTO Tables (name,hist) VALUES ('".$name."', ".$histid.")";
		askdb($q);

		$q="SELECT MAX(id) AS id FROM Tables";

		$res=askdb($q);
		$tableid=$res->fetch_object()->id;
		AddGroupsToTable($tableid,$Groups);
		return $tableid;
	}
}

function GetMCEvents(){
	$q="SELECT * FROM MclassEvents WHERE 1";
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$temp["id"]=$obj->id;
		$temp["name"]=$obj->name;
		$temp["active"]=$obj->active;
		$result[]=$temp;
	}
	if(isset($result)){
		return $result;
	}
}

function GetTableByID($tableid){
	$q="SELECT * FROM Tables WHERE id=".$tableid;
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result["id"]=$obj->id;
		$result["name"]=$obj->name;
	}
	if(isset($result)){
		return $result;
	}
}


function GetHistDataForTable($tname){
	$q="SELECT id,data FROM histograms WHERE id=(SELECT hist FROM Tables WHERE name='".$tname."')";
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result["id"]=$obj->id;
		$result["data"]=$obj->data;
	}
	return $result;
}

function UpData($data,$id){
	$q="UPDATE histograms SET data='".$data."' WHERE id=".$id;
	askdb($q);
	}

function CreateEvent($name){
	$q="SELECT * FROM MclassEvents WHERE name='".$name."'";
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$test=$obj->name;
	}
	if(!isset($test)){
		$q="INSERT INTO MclassEvents (active,name) VALUES ( 1,'".$name."')";
		askdb($q);
	}else{
		return 0;
	}
}

function GetLastEvent(){
	$q="SELECT MAX(id) AS id FROM MclassEvents";
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		return GetMClassEvent($obj->id);
	}
}

function GetMClassEvent($id){
	$q="SELECT * FROM MclassEvents WHERE id='".$id."'";
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result["name"]=$obj->name;
		$result["id"]=$obj->id;
		$result["active"]=$obj->active;
	}
	if(isset($result)){
		return $result;
	}
}


function GetTables($event){
	$q="SELECT * FROM Tables WHERE id IN (SELECT tableid FROM EventTables WHERE MclassEventID='".$event."')";
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$temp["id"]=$obj->id;
		$temp["name"]=$obj->name;
		$result[]=$temp;
	}
	if(isset($result)){
		return $result;
	}
	}

function GetGroups($Tables){

	if(isset($Tables)){
		if(is_array($Tables)){
			if(is_array($Tables[0])){
				for($i=0;$i<count($Tables);$i++){
					$tables[]=$Tables[$i]["id"];
				}

				$q="SELECT g_no,postAdded FROM TableGroups WHERE tableid IN ( ".implode(",",$tables).")";

			}else{
				$q="SELECT g_no,postAdded FROM TableGroups WHERE tableid IN (".implode(",",$Tables).")";
			}
		}else{
			$q="SELECT g_no,postAdded FROM TableGroups WHERE tableid=".$Tables;
		}
		$q=$q." ORDER BY g_no";
		$res=askdb($q);
		while($obj = $res->fetch_object()){
			$temp["g_no"]=$obj->g_no;
			$temp["postAdded"]=$obj->postAdded;
			$result[]=$temp;
		}
		if(isset($result)){
			return $result;
		}
	}
}


function GetIndTables(){
	$q="SELECT * FROM Tables WHERE NOT id IN (SELECT tableid FROM EventTables WHERE 1)";
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$temp["id"]=$obj->id;
		$temp["name"]=$obj->name;
		$result[]=$temp;
	}
	if(isset($result)){
		return $result;
	}
}


function GetFreeTables($event,$boundGroups,$overlab){
	$q="SELECT * FROM Tables WHERE NOT id IN (SELECT tableid FROM EventTables WHERE MclassEventID='".$event."')";
	if($overlab==1){
		$q=$q.";";

	}else{
		if(isset($boundGroups) && is_array($boundGroups)){
			$q=$q." AND NOT id IN (SELECT tableid FROM TableGroups WHERE g_no IN (".$boundGroups[0];
			for($i=1;$i<count($boundGroups);$i++){
				if(isset($boundGroups[$i]["id"])){
					$q=$q.", ".$boundGroups[$i]["id"];
				}
			}
			$q=$q." ) )";
		}
	}
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$temp["id"]=$obj->id;
		$temp["name"]=$obj->name;
		$result[]=$temp;
	}
	if(isset($result)){
		return $result;
	}
}

function GetFreeGroups($boundGroups,$overlab){
	if(isset($boundGroups) && is_array($boundGroups) && $overlab==0){
/*		$q="SELECT DISTINCT g_no FROM Events WHERE NOT g_no IN ( ".implode(",",$boundGroups).")";*/
			$q="SELECT DISTINCT g_no FROM Events WHERE NOT g_no IN ( ".implode(",",$boundGroups).") ORDER BY g_no";
	}else{

/*		$q="SELECT DISTINCT g_no FROM Events WHERE 1";*/
			$q="SELECT DISTINCT g_no FROM Events WHERE 1 ORDER BY g_no";
	}
	$res=askdb($q);
	while($obj = $res->fetch_object()){
		$result[]=$obj->g_no;
	}
	if(isset($result)){
		return $result;
	}
}

function connectGroups($tableid,$gstd,$gbackup){
	$q="INSERT INTO groupConnect (gstd,gbackup,tableid) VALUES (".$gstd.",".$gbackup.",".$tableid.")";
	askdb($q);
}

function GetConnection($tableid,$group){
	$q="SELECT gbackup FROM groupConnect WHERE tableid=".$tableid." AND gstd=".$group;
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result=$obj->gbackup;
	}
	if(isset($result)){
		return $result;
	}

}

function isbackup($tableid,$groupid){
	$q="SELECT postAdded FROM TableGroups WHERE tableid=".$tableid." AND g_no=".$groupid;
	print($q);
	$res=askdb($q);
	if($obj = $res->fetch_object()){
		$result=$obj->postAdded;
	}
	if(isset($result)&&$result==1){
		return true;
	}else{
		return false;
	}
}


?>
