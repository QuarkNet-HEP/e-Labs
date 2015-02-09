<form action=finish.php method="post">
<div class=intro>
	<div class=row>
	<div class=col-md-3></div><div class=col-md-6 align="center"><h3> You are finished with all events in this group.</h3></div>
	</div><div class=row>
	<div class=col-md-3></div><div class=col-md-6 align="center"><h3> You are done if you don't want to:</h3></div>
	</div><div class=row>
	<div class=col-md-3></div><div class=col-md-6 align="center"><button type="submit"  class="btn btn-primary btn-lg" name="edit" value="edit">Edit group <?php echo $_SESSION["groupNo"];?></button></div>

	<div></div>
</form>


