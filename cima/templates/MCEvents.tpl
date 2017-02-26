<div class="row panelRow">
	<div class=col-md-12>
		<h4> Masterclass information </h4>
	</div>
</div>
<form action="MCEvents.php" method="post">

<div class="row panelRow">
	<div class=col-md-2>Event name:<strong> <?php echo "".$_SESSION["EventName"]; ?> </strong></div>
	<div class=col-md-2>Event id:<strong> <?php echo "".$_SESSION["EventID"]; ?></strong></div>
	<div class=col-md-2>Allow data overlap 
	<?php if($_SESSION["overlab"]==1){ 
		echo '<input type="checkbox" name="overlab" onclick="this.form.submit() "value="o" checked="true">';
			}else{
				echo '<input type="checkbox" name="overlab" onclick="this.form.submit()" value="o">';
			}
	?> </div>
	<div class=col-md-6><button type="submit" class="btn btn-default" name="finished" value="finished">finished</button></div>

</div>

<!--
<div class="row panelRow">
	<div class=col-md-12>
		<h4> Fast configure Masterclass </h4>
	</div>
</div>
<form action="MCEvents.php" method="post">

<div class="row panelRow">
	<div class=col-md-2>
		<input type="text" name="Ntables" placeholder="Number of tables" maxlength="15" size="15">
	</div>
	<div class=col-md-2>
		<input type="text" name="NGroups" placeholder="Number of groups/table" maxlength="22" size="22">
	</div>
	<div class=col-md-8>
		<button type="submit" class="btn btn-default" name="AutoConf">Do it</div>
	</div>
</div>
</form>	
!-->

<div class="row panelRow">
	<div class=col-md-12>
		<h4> Configure Masterclass </h4>
	</div>
</div>

<div class=Cnt>
<div class="row panelRow">
	<div class=col-md-4> 
		<div class=container-fluid>
			<div class="row panelRow">
				<div class=col-md-12>
					<strong>Enter new name -or- choose existing table</strong>
				</div>
			</div>
			<div class="row panelRow">
				<div class=col-md-8>
					<input type="text" name="tableName"
								 placeholder="new table name"
								 maxlength="30" size="30">
				</div>
				<div class=col-md-4><select name="Tsel">
					<?php for($i=0;$i<count($boundTables);$i++){
						echo '<option value="'.$boundTables[$i]["id"].'">'
							.$boundTables[$i]["name"].
						'</option>';
					}?>
				</select></div>

			</div>
			<div class="row panelRow">
				<div class=col-md-12>
					<strong> Assign Groups </strong>
				</div>
			</div>
			<div class="row panelRow">
				<select name="Groups[]" style="width: 100%"	size="10" multiple>
					<?php for($i=0;$i<count($freeGroups);$i++){
							echo "<option value=".$freeGroups[$i].">".$freeGroups[$i]."</option>";
						} ?>
				</select>
			</div>
			<div class="row panelRow">
				<div class=col-md-6>
					<button type="submit" class="btn btn-default"
									name="CreateT" value="CT">
						Create table
					</button>
				</div>
				<div class=col-md-6>
					<button type="submit" class="btn btn-default"
									name="AddG" value="AddG">
						Add to table
					</button>
				</div>
			</div>
		</div>
	</div>
	<div class=col-md-8>
		<div class=container-fluid>
			<div class="row panelRow">
				<div class=col-md-4>
					<div class=container-fluid>
						<div class="row panelRow">
						<strong> Free tables </strong>
						</div>
						<div class="row panelRow">
						<select name="Ftables[]" id="Ftables" style="width: 100%" onclick="PostGroups()" size="13" multiple>
						<?php for($i=0;$i<count($indTables);$i++){
							echo "<option value=".$indTables[$i]["id"].">".$indTables[$i]["name"]."</option>";
						} ?>
						</select>
						</div>
						<div class="row panelRow">
						<button type="submit" class="btn btn-default" name="bind" value="bind">Add tables</button> 
						</div>

						</div>
					</div>
				<div class=col-md-4>
					<div class=container-fluid>
						<div class="row panelRow">
						<strong>bound tables </strong>
						</div>
						<div class="row panelRow">
						<select name="BTables[]" id="BTables" style="width: 100%" onclick="PostGroups()" size="13" multiple>
						<?php for($i=0;$i<count($boundTables);$i++){
							echo "<option value=".$boundTables[$i]["id"].">".$boundTables[$i]["name"]."</option>";
						} ?>
						</select>
						</div>
						<div class="row panelRow">
						<button type="submit" class="btn btn-default" name="free" value="free">Remove tables</button> 
						</div>
					</div>
				</div>
				<div class=col-md-4>
					<div class=container-fluid>
						<div class="row panelRow">
						<strong>Groups </strong>
						</div>
						<div class="row panelRow">
						<select name="Bgroups[]" id="bg" style="width: 100%" size="13" multiple>
						</select>
						</div>
						<div class="row panelRow">
						<button type="submit" class="btn btn-default" name="DelG" value="DelG">Remove Groups</button> 
						</div>
					</div>
				</div>

			</div>
		</div>
	</div>
</form>
</div>
