<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<html>
	<head>
		<title>
			Tutorial Counter Performance Study
		</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
	</head>
		
	<body>
		<center>
			You can:&nbsp
			<ol>
				<li> Find some help on this page</li>
		 		<li>
		 			<e:popup href="../posters/display.jsp?type=poster&amp;name=adlerperformance.data" 
						target="PossibleParticleDecays" width="700" height="510">View</e:popup>
						a poster created using this study&nbsp
				</li>
				<li>
					<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: 
					Step-by-Step Instructions
				</li>
			</ol>
		</center>
	

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
	</body>
</html>

