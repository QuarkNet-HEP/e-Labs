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
 				in a very tiny window of time.  With the <a href="javascript:glossary('GPS',350)">GPS device connected to your 
 				<a href="javascript:glossary('DAQ',350)">DAQ board, the absolute time stamp allows a network of detectors 
 				(at the same site or at different schools) to study cosmic ray showers. Students can look for small showers over their own detectors, 
 				or collaborate with other schools in the area to look for larger showers. The online analysis tools of the e-Lab can check for 
 				multiple detectors firing in coincidence.  They also allow students to make predictions about the direction from which the shower 
 				(and thus the primary cosmic ray) originated. 
		
				The many particles in a shower light up the detector's 
				<a href="javascript:glossary('photomultiplier_tube',350)">photomultiplier tubes</a> (PMT)
				with many <a href="javascript:glossary('signal',350)">signals</a> one after another. 
				Interesting showers have many particles and cover a large area.  
				We set up the detector with the <a href="javascript:glossary('counter',350)">counters</a> unstacked, <img src="../graphics/unstacked.gif" />.  
				Each counter is connected via a channel to the DAQ.  See picture below for a sample setup:
				<p><font size=+2><b><a href="javascript:glossary('coincidence',350)">Coincidence</a> Diagram</b></font></p>
				<img src="../graphics/coincidence-diagram.png">
				
				<p>For more background, see how the <A href="../flash/daq_only_standalone.html" target="_blank">detector works</a>.
				
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

