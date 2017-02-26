<div class=Cnt>
<div class=row>
<div class=col-md-4>
<div class=container-fluid>
<div class=row>
	<div class=col-md-10><strong> Masterclass: </strong> <?php echo '<span name="database"> '.$_SESSION["MasterClass"].'</span>'; ?>
	</div>
</div>
<div class=row>
	<div class=col-md-10><strong> Location: </strong> <?php echo '<span name="groupNo"> '.$_SESSION["database"].'</span>'; ?>
	</div>
</div>
<div class=row>
	<div class=col-md-10><strong> Groups: </strong> <?php echo '<span name="groupNo"> '.'all groups'.'</span>'; ?>
	</div>
</div>
</div>
</div>
<div class=col-md-6>
	<font size="1">
	Instructions (also available as <a href="http://leptoquark.hep.nd.edu/~kcecire/drupal_lib/video2015/cima_4.swf" target="_blank">screencast</a>):
	<br>
	You can add the mass value from your events table into the mass histogram by clicking on the matching bin.
	The bins have a 2 GeV/c² width, e.g. the bin labelled "1" should contain events from 0.000 GeV/c² to 1.999 GeV/c² and so on.
	If you made a mistake, you can remove an entry from a bin as explained below the histogram.
	Please be aware that the mass histogram is used by all groups.
	Thus you can see entries from other groups as well.
	</font>
</div>

</div>

<div class=container style="display: inline-block;">
<div class=row style="padding-top: 5%;">
<div class=col-md-1 align="center">
<strong>Events / (2GeV/c²)</strong>
</div>
<div class=col-md-11>
<canvas id="myChart" width="2000" height="600" onmouseup="update(event)"></canvas></div></div>
<div class=row>
<div class=col-md-10></div><div class=col-md-2> <strong> Mass bin (GeV/c²) </strong> </div></div>
</div>
<div class=row style="padding-top: 2%;"> <div class=col-md-1></div><div class=col-md-4 align="center">Tip: Remove data from the histogram by holding the ctrl key <br> (the command key for mac users) </div></div>
</div>
