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


<p>
	
	
	
	
	<center>
			<table width="655">
					<td colspan = 3>
								<center>
									<font color="#0a5ca6" size=+3>
								
										<b>
	 										Detector Performance Study
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr>
				<tr>
					<td valign="top" width=322>
						&nbsp<p>
						<b>Example Observing Cars</b>
						<br>
						Imagine standing at an intersection, counting the number and type of 
						cars that drive past in 20 minutes. <p>

						On your <a href="http://www.shodor.org/interactivate/activities/histogram/">histogram</a>, the x-axis would say "Chevrolet, Ford, 
						Saab, Toyota, Volkswagen." The y-axis would have the numbers 0-14. 
						You would draw a bar to the proper height for each make of car
						(<e:popup href="../graphics/car_hist.gif" width="740" height="510" target="illustration">Illustration</e:popup>).<p>
					
							</td>
							</p>
					<td width=10>&nbsp;
							</td>
					
					<td valign="top" width=322>
						&nbsp<p>
					
							<center>
								<table border="1" cellpadding="2" width=125>
									<tr><td><b>Make</b><hr></td>		<td><b>Count</b><hr></td></tr>

									<tr><td>Chevrolet</td>	<td>12</td></tr>
 									<tr><td>Ford</td>		<td>8</td></tr>
									<tr><td>Saab</td>		<td>1</td></tr>
									<tr><td>Toyota</td>		<td>13</td></tr>
									<tr><td>Volkswagen</td>	<td>5</td></tr>
								</table>
							</center>
						</td>
					</tr>
					
					<tr>
						<td colspan="3">
						<p>
							<hr>
							<p>
						</td>
					</tr>
			
					<tr>
						<td valign="bottom" width=322>
							<img src="../graphics/Ballard3.gif" alt="">
								<p>&nbsp;
						</td>
				<td width=10>&nbsp;
							</td>
						<td valign="top" width=322>
							Our histogram labels read "Time over Threshold (ns)" and "Number of Muons." 
							We measure the length of the response time as <a href="javascript:glossary('pulse_width',350)"><i>time over threshold</i></a>. 
							<p>
	
							The question is: "Do these measurements look right?" Your answer depends on what the 
							<a href="javascript:glossary('detector',350)"> detector</a> 
							usually sees. This plot looks pretty good; The <a HREF="javascript:glossary('counter',350)"> counter</a> is well callibrated. 
							<p>
							But, is today's performance close to yesterday's? 
							Does each of the four counters on one detector indicate the 
							same measurement? 
							
							<p>Back to the cars: Do these measurements look right? If you saw 18 Saabs and 1 Chevrolet would you 
							believe it? Perhaps, if you collected the data in Sweden!

							What if several of you took data. Did everyone at the street corner see all of the 
							cars or did one person see only Chevys? 
							
						</td>
					</tr>
		
					<tr>
						<td colspan="3" align="center">
						
					Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> &
						
					
						<a href="index.jsp">Analysis</a>
						
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
