<?php
include "database.php";


$MCEvts=explode(",",$_POST["MCE"]);
//$MCEvts[]="test";
$k=0;
for($i=0;$i<count($MCEvts);$i++){
	if($MCEvts[$i]=="notA"){
		$tables=GetIndTables();
	}else{
		$tables=GetTables($MCEvts[$i]);
	}
	if($_POST["source"]=="index"){
		echo '<div class=row align="center"><strong>Choose your location</strong></div>';
	}
	for($j=0;$j<count($tables);$j++){
		if($_POST["source"]=="Backend"){
			echo '<option value="'.$tables[$j]["id"].'">'.$tables[$j]["name"].'</option>';
		}elseif($_POST["source"]=="index"){
			echo '<div class=row> </div><div class=col-md-12 style="cursor: pointer;" align="center" id="'.$tables[$j]["id"].'" onmouseover="OverCol(this)" onmouseout="OffCol(this)" onclick="TSel(this)">'.$tables[$j]["name"].'</div></div>';
		}

	}
}

