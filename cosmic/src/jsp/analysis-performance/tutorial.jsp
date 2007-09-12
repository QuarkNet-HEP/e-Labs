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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
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
					<td colspan = "2">
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Detector Performance Study
								</b>
							</font>
						</center>
	 				</td>
	 			</tr>
	 			
	 			<tr>
	 				<td width="321" valign="top">
	 					This is the analysis path for the performance study. The plot shows 
	 					how often the <a href="javascript:glossary('pulse_width',350)">pulse widths</a> 
	 					were a particular value. 
					</td>
				
					<td width="321" valign="top">
						Many, many short pulses with few longer pulses may indicate a noisy 
						<a href="javascript:glossary('counter',350)">counter</a>.
					</td>
				</tr>
		
				<tr>
					<td colspan="2">
						<img src="../graphics/performanceDAG.png" alt="">
					</td>
				</tr>
		
				<tr>
					<td colspan="2" align="right">
						Want to <a href="tutorial2.jsp">know more?</a>
					</td>
				</tr>
		
				<tr>
					<td colspan="2">
						Inspect the plots below. Which one shows a counter with an enormous number of 
						short pulses? Which two counters have similar performance? What would you 
						do if you owned these four counters?
					</td>
				</tr>
		
				<tr>
					<td>
						<img src="../graphics/Ballard1.gif" alt=""></td><td><img src="../graphics/Ballard2.gif" alt=""> 
					</td>
				</tr>
				
				<tr>
					<td>
						&nbsp;
					</td>
					
					<td>
						&nbsp;
					</td>
				</tr>
				
				<tr>
					<td>
						<img src="../graphics/Ballard3.gif" alt=""></td><td><img src="../graphics/Ballard4.gif" alt="">
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

