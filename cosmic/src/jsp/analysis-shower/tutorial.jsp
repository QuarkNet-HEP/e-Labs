<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<center>
	You can:&nbsp
	 <b>1) </b> Find some help on this page &nbsp
			<!--
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adler_flux.data','Possible Particle Decays', 700, 510); ">View</a> a poster created using this study&nbsp
-->	
	<b>2)</b> <e:popup href="tryit.html" target="TryIt" width="600" height="600">Try it</e:popup>: 
	Step-by-Step Instructions
</center>		
<p>
<center>
<p>
<p>	
	
	<table width="655">
		<tr>
							<td colspan = 3>
								<center>
									<font color="#0a5ca6" size=+3>
										<b>
	 										Shower Study
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr><tr>
 			<td colspan=3>
 				<a href="javascript:glossary('shower',350)">Showers</a> can pepper a large area of Earth's surface 
 				in a very tiny window of time. They can be rare, especially 
 				if the area you are looking in is large.
		
				The many particles in a shower light up the detector's 
				<a href="javascript:glossary('photomultiplier_tube',350)">photomultiplier tubes</a> (PMT)
				with many <a href="javascript:glossary('signal',350)">signals</a> 
				one after another. The more particles in the shower, the larger 
				area it covers, the more interesting it is. You could find out the extent of the shower or perhaps the origin of the primary cosmic ray.
				We set up the detector with the counters unstacked, <img src="../graphics/unstacked.gif" />. <br>(How the <A href="../flash/daq_only_standalone.html">detector works</a>) 
			
		<p align=center> <font size=+2><b>From Raw Data to Plot</b></font>
		
				<img src="../graphics/showerDAG.png" alt=""/>
				<p>
				<hr>
				<p>
			</td>
		</tr>
				
		<tr>
		<td  valign="top" width=322>
				<img src="../graphics/shower.png" height= "350" width = "350" alt=""/>
			</td>	
		<td width=5>&nbsp;
							</td>					
			<td valign="top" width=322>
				&nbsp<p>
				&nbsp<p>
				In this event, the detector captured 12 
				PMT
				signals from 3 different locations. <br/>
				<p>	
				Signals are  marked by the red 
				polygons. The polygon's height above the x-y plane (the green spike) tells 
				us the amount of time between the beginning of the shower and the start of 
				the PMT signal at that x-y location. A polygon with no tail represents the 
				beginning of the event. <br/>
	<p>
				We said there are 12 signals in the event. The plot only shows three. Where 
				are the other nine?<br/>

				<p align="center">
				</td></tr>
				<tr><td colspan=3>
					               <p align=center> Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a>
				</p>
					
			</td>
					
						
		</tr>
	</table>
				
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

