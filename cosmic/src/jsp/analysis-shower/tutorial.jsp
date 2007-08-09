<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Shower Study</h1>
<center>
	You can:&nbsp
	 <b>1) </b> Find some help on this page &nbsp
			<!--
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adler_flux.data','Possible Particle Decays', 700, 510); ">View</a> a poster created using this study&nbsp
-->	
	<b>2)</b> <e:popup href="tryit.html" target="TryIt" width="600" height="600">Try it</e:popup>: 
	Step-by-Step Instructions
</center>		
<center>	
	
	<table width="650" cellpadding="8">
		<tr>
 			<td width="321" valign="top">
 				This is the analysis path for the 
 				<a href="javascript:glossary('shower',350)">shower</a> 
 				study. Showers can pepper an large area of Earth's surface 
 				in a very tiny window of time. They can be rare, especially 
 				if the area you are looking in is large.
			</td>
					
			<td width="321" valign="top">
				The many particles a shower light up the detector's 
				<a href="javascript:glossary('photomultiplier_tube',350)">PMTs</a> 
				with many <a href="javascript:glossary('pulse',350)">pulses</a> 
				one after another. The more particles in the shower, the larger 
				area it covers, the more interesting it is.
			</td>
		</tr>
			
		<tr>
			<td valign="top" colspan ="2" >
				<img src="../graphics/showerDAG.png" alt=""/>
			</td>
		</tr>
				
		<tr>					
			<td valign="top">
				In the event shown on the right, the electronics captured 12 
				<a href="javascript:glossary('photomultiplier_tube',350)">photomultiplier</a> 
				signals. These signals came from three different locations. Each location 
				contributed four pulses to the event.<br/>
					
				<a href="javascript:glossary('pulse',350)">Pulses</a> are  marked by the red 
				polygons. The polygon's height above the x-y plane (the green spike) tells 
				us the amount of time between the beginning of the shower and the start of 
				the PMT pulse at that x-y location. A polygon with no tail represents the 
				beginning of the event. <br/>
	
				We said there are 12 pulses in the event. The plot only shows three. Where 
				are the other nine?<br/>

				<p align="right">
					Want to <a href="tutorial2.jsp">know more?</a>
				</p>
					
			</td>
					
			<td  valign="top" >
				<img src="../graphics/shower.png" height= "350" width = "350" alt=""/>
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

