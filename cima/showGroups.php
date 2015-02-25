<?php
include "database.php";


$tables=explode(",",$_POST["tables"]);
//$MCEvts[]="test";
$k=0;
$groups=GetGroups($tables);

if($_POST["source"]=="index"){
		echo '<div class=row align="center"><strong>Choose your group</strong></div>';
	}

for($i=0;$i<count($groups);$i++){
		if($_POST["source"]=="Backend"){
			echo '<option>'.$groups[$i]["g_no"].'</option>';
		}elseif($_POST["source"]=="index"){
			echo '<div class=row> <div class=col-md-3></div><div class=col-md-6 style="cursor: pointer;" align="center" id="'.$groups[$i]["g_no"].'" onmouseover="OverCol(this)" onmouseout="OffCol(this)" onclick="GSel(this)">'.$groups[$i]["g_no"].'</div></div>';
		}

}


