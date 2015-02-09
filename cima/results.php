<?php

session_start();
$script=2;

include 'database.php';
include 'templates/header.tpl';
if(!isset($_SESSION["comb"])){
	include 'templates/navbar.tpl';
	$start=1;
	$ng=30;
	for($i=1;$i<$ng;$i++){
		$groups[$i]["mu"]=0;
		$groups[$i]["e"]=0;
		$groups[$i]["W"]=0;
		$groups[$i]["W-"]=0;
		$groups[$i]["W+"]=0;
		$groups[$i]["Z"]=0;
		$groups[$i]["H"]=0;
		$groups[$i]["Zoo"]=0;
		$groups[$i]["sum"]=0;

	}

}else{
	include 'templates/Resnav.tpl';
	$g=GetGroups($_SESSION["tables"]);
	$ng=count($g);
	$start=$g[0]["g_no"];

	for($j=0;$j<$ng;$j++){
		$i=$g[$j]["g_no"];
		$groups[$i]["mu"]=0;
		$groups[$i]["e"]=0;
		$groups[$i]["W"]=0;
		$groups[$i]["W-"]=0;
		$groups[$i]["W+"]=0;
		$groups[$i]["Z"]=0;
		$groups[$i]["H"]=0;
		$groups[$i]["Zoo"]=0;
		$groups[$i]["sum"]=0;

	}
}
/*
old version uses group numbers but is less efficient
if(isset($_SESSION["tables"])){
	foreach($_SESSION["tables"] as $t){
		for($i=0;$i<$ng;$i++){
			$T=GetTableByID($t);
			$events=GetEvents($g[$i]["g_no"],$T["name"]);
			if(isset($events)){
				foreach($events as $asArr){
					$groups[$i]["sum"]++;
					$temp=explode(";",$asArr["checked"]);
					for($j=0;$j<count($temp);$j++){
						if($temp[$j]!=""){
							$groups[$i][$temp[$j]]++;
						}
					}
				}
			}
		}
	}
}elseif(isset($_SESSION["database"])){
	for($i=0;$i<$ng;$i++){
		$events=GetEvents($i+1,$_SESSION["database"]);
		if(isset($events)){
			foreach($events as $asArr){
				$groups[$i]["sum"]++;
				$temp=explode(";",$asArr["checked"]);
				for($j=0;$j<count($temp);$j++){
					if($temp[$j]!=""){
						$groups[$i][$temp[$j]]++;
					}
				}
			}
		}
	}

}
*/

//new version does rely on right order of ids!!
if(isset($_SESSION["tables"])){
	foreach($_SESSION["tables"] as $t){
		$T=GetTableByID($t);
		$events=GetAllEvents($T["name"]);
		if(isset($events)){
			foreach($events as $asArr){
				$i=floor(($asArr["id"]-1)/100)+1;
				$groups[$i]["sum"]++;
				$temp=explode(";",$asArr["checked"]);
				for($j=0;$j<count($temp);$j++){
					if($temp[$j]!=""){
						$groups[$i][$temp[$j]]++;
					}
				}
			}
		}
	}

}elseif(isset($_SESSION["database"])){
	$events=GetAllEvents($_SESSION["database"]);
	if(isset($events)){
		foreach($events as $asArr){
			$i=floor(($asArr["id"]-1)/100)+1;
			$groups[$i]["sum"]++;
			$temp=explode(";",$asArr["checked"]);
			for($j=0;$j<count($temp);$j++){
				if($temp[$j]!=""){
					$groups[$i][$temp[$j]]++;
				}
			}
		}
	}
}



include "templates/results.tpl";

foreach($groups[$start] as $k => $v){
	$tot[$k]=0;
}

foreach($groups as $i => $g){
	echo '<tr><td>'.$i.'</td>';
		foreach($g as $k => $v){
			$tot[$k]+=$v;
			echo '<td>'.$v.'</td>';
		}
	echo '</tr>';
}


echo '</tbody></table></div> <div class=col-md-2></div></div>';
include "templates/results2.tpl";

	foreach($tot as $v){
			echo '<td>'.$v.'</td>';
		}
	if($tot["mu"]!=0){
		echo '<td>'.round($tot["e"]/$tot["mu"],2).'</td>';
	}else{
		echo '<td> not defined</td>';
	}
	if($tot["W-"]!=0){
		echo '<td>'.round($tot["W+"]/$tot["W-"],2).'</td>';
	}else{
		echo '<td> not defined</td>';
	}

	echo '</tr>';
echo '</tbody></table></div><div class=col-md-2></div> </div></div></div>';

include "templates/floor.tpl";
	
?>
