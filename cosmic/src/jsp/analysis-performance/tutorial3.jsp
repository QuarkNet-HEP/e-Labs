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

<h1>Detector Performance Study</h1>
	<p>
	
		<center>
			<table width=650>
				<tr>
					<td valign=top>
						This study aims to understand the quality of the collected data. One tool for this is a 
						histogram of the number of events with a particular length of Time over Threshold (ToT).<p>

						In a very loose sense, ToT is a measure of the amount of energy deposited in the 
						<a HREF="javascript:glossary('scintillator',350)">scintillator</a> for a given 
						<a HREF="javascript:glossary('muon',100)">muon </a>passage. There is a correlation 
						between the<a HREF="javascript:glossary('pulse_width',350)"> width of the pulse</a> 
						in time and the height of the pulse. A well calibrated 
						<a HREF="javascript:glossary('counter',350)"> counter</a> shows a good 
						Gaussian distribution of ToT.<p>

						This particular graph shows a very noisy counter with a large peak centered at 3 ns. 
						This peak is so large that the Gaussian that may be centered near 8 ns is obscured.
					</td>
				
					<td valign=top>
						<img src="../graphics/Ballard3.gif" alt="">
					</td>
				</tr>
			
				<tr>
					<td align=right>
						Go back to the <a href="index.jsp">analysis</a>
					</td>
					
					<td>
						&nbsp
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
