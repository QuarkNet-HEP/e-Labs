<div class=Cnt>

<div class=row>
	<div class=col-md-12><strong> Tables: </strong> <span name="groupNo"> 
	<?php 
		foreach($_SESSION["tables"] as $id){ 
			$t=GetTableByID($id); 
			echo $t["name"].' '; }
	?>
	</span>
	</div>
</div>
<div class=container style="display: inline-block;">
<div class=row style="padding-top: 5%;">
<div class=col-md-1 align="center">
<strong>Events / 2GeV</strong>
</div>
<div class=col-md-11>

<canvas id="myChart" width="1000" height="400"></canvas>
</div></div>
<div class=row>
<div class=col-md-10></div><div class=col-md-2> <strong> Mass bin (GeV) </strong> </div></div>

</div>
