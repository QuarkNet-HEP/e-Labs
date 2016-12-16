<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


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
	
	<body id="shower-tutorial-2" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			<p>
			<center>
			<p>
			<p>
			<table width="655">
				<tr>
					<td colspan = 3>
						<center><font color="#0a5ca6" size=+3><b>Shower Study</b></font>
	 					&nbsp;<p></center>
	 				</td>
	 			</tr>
	 			<tr>
	 				<td colspan = 3>
	 					The detector identified 1376 shower candidates.  There's a data table for each shower candidate 
						that meets your input parameters.
						<br> <center><img src="../graphics/tryPerf/shower_cand_tutorial.png" alt=""></center>
						<br> Look at the data table for Sep 1, 2016 01:02:17 UTC. 										
	 			</tr>
				<tr>
		 			<td width="322" valign="top">
		 				<img src="../graphics/tryPerf/shower_cand_tutorial.png" alt="">
					</td>
					<td width=10>&nbsp;</td>
					
					<td width="322" valign="top">
						In this event, the detector captured 10 PMT signals from 2 different locations. <br>
						<img src="../graphics/tryPerf/shower_event_tutorial.png" alt="">         			
					</td>
				</tr>
				
				<tr>
					<td colspan ="3" >&nbsp;
					<p>
					Signals are  marked by the red polygons. The polygon's height above the x-y plane (the green spike) tells 
					us the amount of time between the beginning of the shower and the start of 
					the PMT signal at that x-y location. A polygon with no tail represents the 
					beginning of the event. 
					<p>
					We said there are 10 signals in the event. The plot only shows nine. Where is the other one?					
					<p>
					From the table, you can see that the event fired <a href="javascript:glossary('photomultiplier_tube',350)">PMTs</a> in two 
                	<a href="javascript:glossary('detector',350)">detectors</a>: 6148 and 6119.  
                	Look at the amount of time between the signals in detector 6119. The signal times are so close together (40.0ns & 41.3ns) that 
                	they only show up as one polygon on this plot. If you zoom in (rerun the analysis with a different time scale),
                	you can see the other one.
					<p>
					The plot tells us that detector 6148 fired first, then 6119. The table can give us much more information. 
					Does this event candidate look like a shower to you?
					</td>
				</tr>
					
				<tr><td colspan=3>
					<p align=center>
							         Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a>
					</p>
					</td>
				</tr>
				
			</table>
			</center>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

