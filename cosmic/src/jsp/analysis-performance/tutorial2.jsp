<html>
	<head>

		<title>
			Tutorial Counter Performance Study II
		</title>

        <!-- include css style file -->
        <link rel="stylesheet" type="text/css" href="../css/style.css"/>
    </head>
<p>

<h1>Detector Performance Study</h1>
<p>
	
	
	
	
	<center>
		<body>
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
		</body>
</html>
