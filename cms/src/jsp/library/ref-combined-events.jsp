<html>
	<head>
		<title>
			Data displays with multiple events
		</title>
		<%@ include file="../jsp/include/javascript.jsp" %>
	<script>
function hide_glossary(){
document.getElementById("glossary").style.left=0
document.getElementById("glossary").style.top=0
document.getElementById("glossary").style.width= 1;
document.getElementById("glossary").style.height =1;
document.getElementById("glossary").innerHTML="" ;
}
function show_glossary(event,txt){
document.getElementById("glossary").style.left=event.clientX+20
document.getElementById("glossary").style.top=event.clientY+30
document.getElementById("glossary").style.width=300;
document.getElementById("glossary").style.height =100;
document.getElementById("glossary").innerHTML=txt;

}

</script>

</head>
	
	<link rel="stylesheet"  href="../include/styletut.css" type="text/css">

	<body onLoad="focus()" background="../graphics/Quadrille.gif">
    			 		<h2>
    	 					Data displays with multiple events
		    	 		</h2>
		<table WIDTH=600>
	    	<tr>
	    		<td>
					<p>Here are three different dielectron events each
					with different total energies.</p><p><img src="../graphics/dielectron-energy-3events.jpg" border="0"></p>
					<p>Multiple events can be displayed together according to types. See this screencast showing how to move from <a href="../video/multiple-events.html" target="screencast">single events to histograms</a>.</p>
					<p>Here's an example of a histogram made from many events like the ones shown above.</p>
					<p>What is plotted here is the <a href=# onmouseover="javascript:show_glossary(event,'The invariant mass is that portion of the total energy of the offspring particles that they inherit from the mass of their decaying parent. For example, for two muons that are the offsring of a Z particle.')"
					onmouseout="javascript:hide_glossary()">invariant mass</a> of dielectron events. The bumps like the one you see below
					emerge as you plot many individual dielectron events.</p>
					<img src="../graphics/DielectronMassSpectrum.png" border="1">
					<p>Try this exercise (<a href="javascript:showRefLink('http://ed.fnal.gov/work/event-id-new/cms_game_daddy-bars.html',850,750)">Safari/Firefox</a> - <a href="javascript:showRefLink('http://ed.fnal.gov/work/event-id-new/cms_game_daddy-newgame.html',850,750)">Internet Explorer</a>) to practice associating the invariant mass of individual dimuon events with the histogram.


					</p>
					<p>Histograms reveal statistical properties that cannot be considered on an event by event basis. <a href="ref-combined-events-stats.html">Learn more.</a>
					<p>Why are the distribution of events so broad and overlapping?  See here to <a href="ref-combined-distrib.html">go further</a>.</p>
				</td>
			</tr>
			<tr>
			<td>
					<p><br />Be sure to go back to the  <a href="javascript:reference('interpret data',650,400)">interpret data reference</a> and fill in your logbook.</p>
					</td></tr>
   			<tr>
   				<td align="right">
   					<HR><A HREF="javascript:window.close();">Close Window</font></A>
   				</td>
   			</tr>
		</table>



<div id='glossary'
style='position:absolute;left:0;top:0;width:1;height:1;border:1px solid
black;background-color:rgb(250,250,255)'></div>

	</body>
</html>

    
