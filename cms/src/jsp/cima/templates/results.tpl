<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><?php 
	if(isset($_SESSION["comb"])){
		echo'<strong> Tables: </strong>  <span name="database"> '; 
		for($i=0;$i<count($_SESSION["tables"]);$i++){
			$t=GetTableByID($_SESSION["tables"][$i]);
			echo $t["name"]." ";
		}
	}else{
	echo '<strong> Masterclass: </strong> <span name="database"> '.$_SESSION["MasterClass"].'</span>'; 
	}
		?>
	</div>
</div>
<?php
if(!isset($_SESSION["comb"])){

echo'<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><strong> location: </strong> <span name="database"> '.$_SESSION["database"].'</span>
	</div>';
}?>

<div class=Cnt>
<div class=row>
<div class=col-md-2></div>
<div class=col-md-8>

<table class="table">
<thead>
<tr>
<th> Group </th> <th> Muon </th><th> Electron </th><th> W </th><th> W- </th><th> W+ </th><th> Z </th><th> Higgs </th><th> Zoo </th><th> Total </th>

</tr></thead><tbody>

