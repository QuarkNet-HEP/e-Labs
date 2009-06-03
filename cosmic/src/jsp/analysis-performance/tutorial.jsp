<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Performance study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="performance-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			
		You can:
			<strong>1)</strong> Find some help on this page
			<strong>2)</strong>
				<e:popup href="../posters/display.jsp?type=poster&amp;name=adlerperformance.data" 
				target="PossibleParticleDecays" width="700" height="510">View</e:popup>
				a poster created using this study&nbsp
			<strong>3)</strong>
				<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: 
				Step-by-Step Instructions
	

		<center>        
	
			<p>
		
			<p>
	
			<table width = "650" cellpadding ="8">
				<tr>
					<td colspan = "3">
						<center>
							<font color="#0a5ca6" size="+3">
							<p>
						
							
								<b>
									Detector Performance Study
								</b>
							</font>
						</center>
	 				</td>
	 			</tr>
	 			
	 			<tr>
	 				<td colspan=3>
	 				<p>&nbsp;
	 				<p>	
	 				In order to believe in any science results from your analysis, you must first believe that the detector is performing reliably over time. We measure the length of time the <a href="javascript:glossary('photomultiplier_tube',150)">photomultiplier tube</a> responds to a <a HREF="javascript:glossary('muon',100)">muon</a> and count the number of muons 
	 					for each value. A lot of  muons with short response times and only a few muons with longer times may indicate a noisy 
						<a href="javascript:glossary('counter',350)">counter</a>.
						<br> (How the <A href="../flash/daq_only_standalone.html">detector works</a>) 
	 				<p align=center><font size=+2><b>
	 					From Raw Data to a Plot</b></font>
	 				
					</td>
					
				</tr>
		
				<tr>
					<td colspan="3">
						<img src="../graphics/performanceDAG.png" alt="">
						<p>
<hr>
<p>
					</td>
				</tr>
		
				
		
				<tr>
					<td colspan="3">
				
						
						<p>Inspect these plots. Which one shows a counter with an enormous number of 
						short <a href="javascript:glossary('signal',350)">signals</a>? Which two counters have similar performance? What would you 
						do if you owned these four counters?
					<p>&nbsp;
					</td>
				</tr>
		<tr>
					<td colspan="3" align="center">
						
					Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> &
						
					
						<a href="index.jsp">Analysis</a>
							<p>&nbsp;
					</td>
				</tr>
				<tr>
					<td>
					
						<img src="../graphics/Ballard1.gif" alt=""></td><td width=5>&nbsp;
							</td><td><img src="../graphics/Ballard2.gif" alt=""> 
					</td>
				</tr>
				
				<tr>
					<td>
						&nbsp;
					</td>
					<td width=5>&nbsp;
							</td>
					<td>
						&nbsp;
					</td>
				</tr>
				
				<tr>
					<td>
						<img src="../graphics/Ballard3.gif" alt=""></td><td width=5>&nbsp;
							</td><td><img src="../graphics/Ballard4.gif" alt="">
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

