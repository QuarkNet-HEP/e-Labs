<!--/* Rounding parameter $rnd defined in fillOut.php */-->

<form action=fillOut.php method="post">
<div class=row>
	<div class=col-md-3>
		<div class=container-fluid>
			<div class=row>
				<div class=col-md-1></div>
				<div class=col-md-10>
					<strong> Masterclass: </strong>
					<?php echo '<span name="database">'.$_SESSION["MasterClass"].'</span>'; ?>
				</div>
			</div>
			<div class=row>
				<div class=col-md-1></div>
				<div class=col-md-10>
					<strong> location: </strong>
					<?php echo '<span name="database"> '.$_SESSION["database"].'</span>'; ?>
				</div>
			</div>
			<div class=row>
				<div class=col-md-1></div>
				<div class=col-md-10>
	  			<strong> Group: </strong>
					<?php echo '<span name="groupNo"> '.$_SESSION["groupNo"].'</span>';
	        if(isset($_SESSION["backup"])){ echo " as backup";} ?>
				</div>
				<div class=col-md-8></div>
			</div>
		</div>
	</div>
	<div class=col-md-1>
		<?php
			if(isset($_SESSION["edit"])){
				echo '<button type="submit" id="fedit"';
				if(isset($event)){echo 'disabled="true"';}
				echo 'class="btn btn-default" name="fedit" value="1">finish editing</button>';
			}
		?>
	</div>
	<div class=col-md-6>
		<font size="1">
		<strong>Instructions</strong>
			(also available as <a href="http://leptoquark.hep.nd.edu/~kcecire/drupal_lib/video2015/cima_4.swf" target="_blank">screencast</a>):
			<br>
			<ol>
				<li>For each event, identify the final state and select a primary state candidate.
	  			<ul>
						<li>For Higgs or Zoo candidate, no final state is chosen</li>
						<li>If you cannot decide between W+ and W-, choose W instead</li>
					</ul>
				</li>
<!--  <li><span id="Znote">If you've selected a Z as the primary state candidate, find its mass from the Event Display and enter it.</span></li> -->
  			<li><span id="Znote">If you think the final state is a neutral particle (like a Z), but you don't know its exact type, select NP for "neutral particle."  Find its mass from the Event Display and enter it.</span>
				</li>
  			<li>Once you have selected everything, click "Submit".</li>
			</ol>
			In case of an error, double clicking the data line will reload it; you can then try it again. 
		</font>
	</div>
</div>

<div class=Cnt>
	<!-- Interface Row -->
	<div class="container" style="border:1px solid black">
		<div class="row" style="background-color: none;">
			<!-- Col 1: Select Event -->
			<div class=col-md-3
					 style="background-color:whitesmoke; border-right: 4px solid black;">
				<strong>Select Event</strong></br>
				<div style="background-color:none; padding: 0.5em 0.2em 0.5em 0.4em;">
					<span style="display: inline-block;"><!-- Select Event span -->
						Event index:
						<select id="EvSelOver"
										name="CustomEvent"
										onchange="this.form.submit()">
							<?php	echo '<option  id="SelEvent" selected ';
					 					if(isset($event)){
											echo "value=".$event['id'].">".($event['id'] % 100)."";
										}				
										else{ echo ">";	}
										echo ' </option>';
																		
										if(isset($event)){
											for($i=0;$i<count($freeEvents);$i++){
												if($freeEvents[$i]!=$event['id']){
													echo '<option value='.$freeEvents[$i].'>'.($freeEvents[$i] % 100).'</option>';
												}
											}
										}
							?>
						</select>
					</span></br><!--/Select Event span -->
					<span style="display: inline-block; padding-top: 5%;"><!-- Event number span -->
						<?php  echo 'Event number: <span id="Eventid">';
									 if(isset($event)){
									   echo calcEv($event['id'])."";
									 }
									 echo '</span>';
						?>
					</span><!--/Event number span -->
				</div>
			</div><!--/Col 1: Select Event -->
					
			<!-- Col 2: Select Particles -->
			<div class=col-md-6 style="background-color:whitesmoke;">
				<div class="row"
						 style="background-color:none;"><!-- Select Particles row -->
							
					<!-- Final State column on the left -->
					<div class=col-md-4
							 style="background-color:none; border-right: 1px solid black;">
						<div class="row"><div class=col-md-12>
								<strong> final state </strong>
						</div></div>
						<div class="row"><div class=col-md-12>
							<div style="background-color:none; padding: 0.5em 0.2em 0.5em 0.4em;">
								<div>
									<input type="checkbox"
													<?php echo
												 		'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
												 	?>
												 	id="e" name="electron" value="e">
									Electron</br>
									<input type="checkbox" 
												 	<?php echo
												 		'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
													?>
												 	id="mu" name="mu" value="mu">
									Muon (&mu;)
								</div>
							</div>
						</div></div>
					</div><!-- /Final State column -->
							
					<!-- Primary State column on the right -->
					<div class=col-md-8 style="background-color:none;">
						<div class="row"><div class=col-md-12>
							<strong> primary state candidate</strong>
						</div></div>
						<div class="row"><!-- Primary State row-->
							<!-- col-md-4-->
							<div class=col-sm-4>
								<div style="background-color:none; padding: 0.5em 0.2em 0.5em 0.4em;">
									<input type="checkbox"
													<?php echo
												 		'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
													?>
													id="W-" name="W-" value="W-">
									W<sup>&ndash;</sup><br/>
									<input type="checkbox"
													<?php echo
														'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
													?>
													id="Wp" name="W+" value="W+">
									W<sup>+</sup>
								</div>
							</div>
									
							<div class=col-sm-4>
								<div style="background-color:none; padding: 0.5em 0.2em 0.5em 0.4em;">
									<input type="checkbox"
													<?php echo
												 		'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
												 	?>
													id="NP" name="NP" value="NP">
									<!--Z-->NP<br/>
									<input type="checkbox"
													<?php echo
												 		 'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
												 	?>
													id="W" name="W" value="W">
									W
								</div>
							</div>
									
							<!-- Use shading or border to indicate "special" -->
							<div class=col-sm-4>
								<div style="background-color:lightgrey; padding: 0.5em 0.2em 0.5em 0.4em;">
									<input type="checkbox"
													<?php echo
														'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
													?>
													id="H" name="Higgs" value="H">
									Higgs<br/>
									<input type="checkbox"
													<?php echo
														'onclick="SelP(this,'.round($event["mass"],$rnd).')"';
													?>
													id="Zoo" name="Zoo" value="Zoo">
									Zoo
								</div>
							</div><!-- /Higgs-Zoo column -->
						</div><!-- /Primary State row -->
					</div><!-- /Primary State column -->
				</div><!-- /Select Particles row -->
			</div><!-- /Col 2: Select Particles -->
					
			<!-- Col 3: Mass Entry and Submit -->
			<div class=col-md-3
					 style="background-color:whitesmoke; border-left: 4px solid black; padding-top: 0%; text-align:center;">
				<!-- stacked vertically: -->
				<span style="display: inline-block; padding-top: 5%;">
				  <span	style="color:grey"
								id="massInput" class="massInput" name="massInput">
					  <!--Z-->
						NP Mass:
						<input type="text" name="massEntry" id="massEntry"
									 size="3%" disabled="disabled">
						<span style="font-size:xx-small;">GeV/c²</span>
					</span>
				</span><br/>
				<span style="display: inline-block; padding-top: 5%; padding-bottom:5%;">
					<button type="submit" disabled="true" id="next"
									name="fin" class="btn btn-primary btn-md">
						Submit
					</button>
				</span>
			</div><!-- /Col 3: Mass Entry and Submit -->
					
		</div><!-- End of Interface Row -->
	</div><!-- container-fluid -->
</div><!-- class=Cnt-->
</form>

<div class=row>
  <div class=col-md-1>
</div>
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


			

