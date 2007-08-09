<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
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
			<table width="650">
				<tr>
					<td valign="top">
						Imagine standing at an intersection and counting the number and type of 
						vehicles that drive past in 20 minutes. <p>

						If you put these on a histogram, the x-axis would say "Chevrolet, Ford, 
						Toyota, Saab, Volkswagen." The y-axis would have the numbers 0-14 and 
						you could draw a bar to the proper height for each make of car 
						(<a href="javascript:openHist()"><b>illustration</b></a>).<p>
					</td>
					
					<td valign="top">
							<center>
								<table border="1" cellpadding="2">
									<tr>
										<td>
											Make
										</td>
							
										<td>
											Count
										</td>
									</tr>
							
									<tr>
										<td>
											Chevrolet
										</td>
							
										<td>
											12
										</td>
									</tr>
 
 									<tr>
										<td>
											Ford
										</td>
								
										<td>
											8
										</td>
									</tr>

									<tr>
										<td>
											Saab
										</td>
										
										<td>
											1
										</td>
									</tr>
		
									<tr>
										<td>
											Toyota
										</td>
								
										<td>
											13
										</td>
									</tr>
	
									<tr>
										<td>
											Volkswagen
										</td>
									
										<td>
											5
										</td>
									</tr>
								</table>
							</center>
						</td>
					</tr>
					
					<tr>
						<td colspan="2">
							<hr>
						</td>
					</tr>
			
					<tr>
						<td valign="bottom">
							<img src="../graphics/Ballard3.gif" alt="">
						</td>
				
						<td valign="top">
							Our histogram labels read "Time over Threshold (ns)" and "Frequency." 
							Time over threshold, also called 
							<a href="javascript:glossary('pulse_width',350)">pulse width</a>, 
							indicates the length of time that the 
							<a href="javascript:glossary('photomultiplier_tube',150)">photomultiplier tube</a> 
							responded to the passage of the particle. The frequency indicates how often 
							that particular length occurred in the data set.<p>
	
							The question to consider is: "Do these measurements look right?" Go back to 
							the automobile example. If you saw 18 Saabs and 1 Chevrolet would you 
							believe it? Perhaps, if one collected the data in Sweden!<p>

							Your answer depends on what the 
							<a href="javascript:glossary('detector',350)"> detector</a> 
							usually sees. Is today's performance close to yesterday's? 
							Does each of the four counters on one detector indicate the 
							same measurement? Did everyone at the street corner see all of the 
							cars or did one person see only Chevys? <p>
						</td>
					</tr>
		
					<tr>
						<td colspan="2" align="right">
							Want to <a href="tutorial3.jsp">know more?</a>
						</td>
					</tr>
				</table>
			</cener>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
