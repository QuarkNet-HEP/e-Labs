<form action=fillOut.php method="post">
<div class=row>
<div class=col-md-4>
<div class=container-fluid>
<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><strong> Masterclass: </strong> <?php echo '<span name="database"> '.$_SESSION["MasterClass"].'</span>'; ?>
	</div>
</div>
<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><strong> location: </strong> <?php echo '<span name="database"> '.$_SESSION["database"].'</span>'; ?>
	</div>

</div>
<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><strong> Group: </strong> <?php echo '<span name="groupNo"> '.$_SESSION["groupNo"].'</span>';
	if(isset($_SESSION["backup"])){ echo " as backup";} ?>
	</div>
	<div class=col-md-8></div>
</div>
</div></div>
<div class=col-md-8>
	<?php
	if(isset($_SESSION["edit"])){
		echo '<button type="submit" id="fedit"';
		if(isset($event)){echo 'disabled="true"';}
		echo 'class="btn btn-default" name="fedit" value="1">finish editing</button>';
	}
	?>
</div>
</div>

<div class=Cnt> 
<div class="row">
	<div class=col-md-4></div>
	<div class=col-md-4>
		<div class=row>
			<div class="container-fluid">

			<div class=col-md-3  style="border-right:1px solid #000;"> <strong>final state </strong></div>

			<div class=col-md-3><strong> primary </strong> </div>
			</div>
		</div>
	</div>
</div>

	<div class="row">
		<div class=col-md-1></div> 
		<div class=col-md-1> 
			Event index:<br> <select id="EvSelOver" name="CustomEvent" onchange="this.form.submit()">
		<?php 
		echo '<option  id="SelEvent" selected>';

		if(isset($event)){
			echo $event['id']."";
		}
			echo ' </option>';
		if(isset($event)){
			for($i=0;$i<count($freeEvents);$i++){
				if($freeEvents[$i]!=$event['id']){
					echo '<option> '.$freeEvents[$i].'</option>';
				}
			}
		}
		echo '</select>
		</div>
		<div class=col-md-2>';
				echo 'Event number:<br><span id="Eventid">';
				if(isset($event)){
					echo calcEv($event['id'])."";
				}
				echo '</span>';
		?>
		</div>
		
		<div class=col-md-4>
			<div class="container-fluid">
			<div class="row">
				<div class=col-md-3 style="border-right:1px solid #000;"> <input type="checkbox" id="e" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  name="electron" value="e">Electron </div>

				<div class=col-md-3> <input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?> id="H" name="Higgs" value="H">Higgs </div>
				<div class=col-md-3><input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  id="Z" name="Z" value="Z">Z </div>

				<div class=col-md-3>	<input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  id="Zoo" name="Zoo" value="Zoo">Zoo </div>
	
			</div>
			<div class="row">
				<div class=col-md-3 style="border-right:1px solid #000;"> <input type="checkbox" id="mu" name="muon" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  value="mu">Muon</div>
				<div class=col-md-3>	<input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  id="W"  name="W" value="W">W </div>
				<div class=col-md-3>	<input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  id="Wp" name="W+" value="W+">W+ </div>
				<div class=col-md-3>	<input type="checkbox" <?php echo 'onclick="SelP(this,'.round($event["mass"],3).')"';?>  id="W-" name="W-" value="W-">W- </div>
			</div>
			</div>
		</div>

		<div class=col-md-1> Mass:<br> <span id="mass"></span> </div>	

		<div class=col-md-3><button type="submit" disabled="true" id="next" name="fin" class="btn btn-primary btn-lg">Next</button></div>
	</div>

</div></form>
<div class=row>

<div class=col-md-1></div>
<div class=col-md-8>
<div class=container-fluid>
	<div class=row style="padding-right: 3%;">
		<div class=col-md-3> 
			<strong> Event index </strong>
		</div>
		<div class=col-md-3>
			<strong>Event number</strong>
		</div>
		<div class=col-md-2>
			<strong> Chosen Values</strong>
		</div>
		<div class=col-md-1>
			<strong> Mass </strong>
		</div>
		<div class=col-md-3></div>
	</div>
	<div class=container-fluid style="overflow-y: scroll; height: 50%;">


			

