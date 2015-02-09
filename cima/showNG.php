<?php
include "database.php";


$MCEvts=explode(",",$_POST["MCE"]);
//$MCEvts[]="test";

for($i=0;$i<count($MCEvts);$i++){
	if($MCEvts[$i]=="notA"){
		$tables=GetIndTables();
	}else{
		$tables=GetTables($MCEvts[$i]);
	}
	for($j=0;$j<count($tables);$j++){
		$groups=GetGroups($tables[$j]["id"]);
			$n=0;
			$e=0;
			for($k=0;$k<count($groups);$k++){
				if($groups[$k]["postAdded"]==0){
					$n++;
				}else{
					$e++;
				}
			}
			echo '<div class=row> '.$n;
			if($e!=0){
				echo "+".$e;
			}
			echo '</div>';
	}
}

