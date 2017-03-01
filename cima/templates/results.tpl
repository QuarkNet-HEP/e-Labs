<div class=row>
	<div class=col-md-1></div>
	<div class=col-md-10><?php 
	if(isset($_SESSION["comb"])){
		echo'<strong> Tables: </strong>  <span name="database"> '; 
		for($i=0;$i<count($tables);$i++){
			$t=GetTableByID($tables[$i]);
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
	<div class=col-md-10>
		<strong> Location: </strong>
		<span name="database"> '.$_SESSION["database"].'</span>
	</div>
</div>';
}?>
<div class=row>
	<div class=col-md-1></div>
  <div class=col-md-10>
		<strong> Groups: </strong>
			<?php echo
				'<span name="groupNo" style="word-wrap:break-word;">'
					.implode(",",array_keys($groups)).
				'</span>';
			?>
  </div>
</div>

<div class=Cnt>
	<div class=row>
		<div class=col-md-2></div>
		<div class=col-md-8>
			<table class="table">
				<thead>
					<tr>
						<th> Group </th>
						<th> Muon </th>
						<th> Electron </th>
						<th> W </th>
						<th> W- </th>
						<th> W+ </th>
						<th> <!--Z-->NP </th>
						<th> Higgs </th>
						<th> Zoo </th>
						<th> Total </th>
					</tr>
				</thead>
				<tbody>