<div class=Cnt>
<form action="MCEvents.php" method="post">
<div class=row>
	<div class=col-md-2></div>
	<div class=col-md-8>
		<h3>Create new Masterclass Event</h3>
	</div>
	<div class=col-md-2></div>
</div>	
<div class=row>
<div class=col-md-2></div>
	<div class=col-md-3>

		<strong>Enter name of new event:</strong> <br>
		<input name="EventName" type="text" placeholder="Event name" maxlength="30" size="30">
	</div>
	<div class=col-md-4 align="left">
		<button type="submit" class="btn btn-primary btn-lg" name="chist">Create Event</button>
	</div>
	<div class=col-md-3></div>
</div>
</form>
<form action="MCEvents.php" method="post">
<div class=row>
	<div class=col-md-2></div>
	<div class=col-md-8>
		<h3>Edit Event</h3>
	</div>
	<div class=col-md-2></div>
</div>	

<div class=row>
	<div class=col-md-2></div>
	<div class=col-md-2> <strong>Select event:</strong> <br>
	<select name="Eventsel" style="width: 100%">
	<?php for($i=0;$i<count($MCE);$i++){
		echo '<option value="'.$MCE[$i]["id"].'">'.$MCE[$i]["name"].'</option>';
	}?>
	</select>
	</div>
	<div class=col-md-7 align="left">
		<button type="submit" class="btn btn-primary btn-lg" name="Edit">Edit Event</button>
	</div>
</div>
<div class=row>
</form>
<div class=col-md-2></div>
<form action="Classes.php" method="post">

<div class=col-md-10> <h3>Manage Tables:</h3>  </div></div>

<div class=row>
	<div class=col-md-2></div>
	<div class=col-md-2> 
		<button type="submit" class="btn btn-default" name="changeA" value="cA">change active status</button> </div>
	<div class=col-md-2> 
		<button type="submit" class="btn btn-default" name="delete" value="d">delete</button> </div>
	<div class=col-md-2> 
		<button type="submit" class="btn btn-default" name="Results" value="R">Results</button> </div> <div class=col-md-6> </div> </div>
	</div> 

<div class=row>
	<div class=col-md-2></div>
	<div class=col-md-10>
	   <div class=container-fluid>
		<div class=row>
		<div class=col-md-2><strong> Masterclasses </strong></div><div class=col-md-2><strong> status</strong></div><div class=col-md-2><strong> Tables</strong></div><div class=col-md-2><strong># of Groups</strong></div><div class=col-md-4></div>
	</div>
	   <div class=row>

	   <div class=col-md-2>
	   <select name="Eselect[]" id="Eselect" style="width: 100%" size="10" onclick="GetTables()" multiple>
	   <?php 
			if(isset($MCE) && is_array($MCE)){
				for($i=0;$i<count($MCE);$i++){
					echo '<option value="'.$MCE[$i]["id"].'"> '.$MCE[$i]["name"].'</option>';
				}
			}
			if(isset($freetables) &&  is_array($freetables)){
				echo '<option value="notA"> unassigned tables </option>';

			}
			?>
	  </select></div> <div class=col-md-2>
	<?php 
		if(isset($MCE) && is_array($MCE)){

			for($i=0;$i<count($MCE);$i++){
				echo '<div class=row><div class=col-md-12>';
				if($MCE[$i]["active"]==0){
					echo '(inactive)';
				}else{
					echo '(active)';
				}
				echo '</div></div>';
			}
		}
	?>
	</div><div class=col-md-2>
	  <select name="tselect[]" id="tables" style="width: 100%" size="10" multiple>
	   </select></div>
	<div class=col-md-2>
		<div class=container-fluid id="NG">
	
	</div></div><div class=col-md-4></div>
	</div></div>  </div>  </div> </div>
	</form>


	
