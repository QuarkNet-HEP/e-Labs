<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Time of Flight study tutorial</title>
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
"cosmic/src/jsp/graphics/stop.gif"
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
	 										Time of Flight Study (1)
	 									</b>
	 								</font>
	 							</center>
	 						</td>
	 					</tr><tr>
 			<td colspan=3>
 				<p>
 				This is an advanced study.  Using the TOF analysis module, one can measure the average time muons take to travel between two counters.  
 				Then, we can calculate average speed (v = d/t).  
 				We use the following definitions (same as Flux): 
 				<li>muon time of arrival at a scintillation counter = hit</li> 
 				<li>scintillation counter = channel</li>
 				</p>
 				
 				<p>1.  We set up the detector and collect data with two counters stacked, one on top of the other.  Measure from the top of counter 1 to the top of 
 				counter 4 to estimate the distance the muon travels (d).<br>
 				<img src="../graphics/stacked.gif" /> <br>
			    <img src="../graphics/tryPerf/ToF_2_counters_together.png"/> <br>
			    Create a histogram similar to the one below, and find the mean time for muon to travel between the counters.  <br></br>
			    <img src="../graphics/tryPerf/TOF_4-1_03cm_23nov15.tiff"/> <br>
			    Find the mean using the advanced controls.  In this case, we find the mean to be -1.74ns and the standard deviation to be 2.59ns.
			    Notice that the mean is slightly negative.  
			    <e:popup href="explain_neg_mean.html" target="Explain negative mean" width="450" height="200">
				Click here for explanation.</e:popup><br></br>
			    </p>
			    
			    <p>2.  The distance between counters, muon's speed, PMT response time, and length of signal cables all affect the time measured between two counters.
			    We must design a way to measure the muon's time of flight that doesn't include all those other experimental effects.
			    This requires another data run.  Collect data with a larger distance between the counters.  How far apart should they be?  We want to have a large enough separation so that 
			    the error on <br></br> 
			    <center>&Delta;t = time of arrival at counter 4 - time of arrival at counter 1</center><br></br>
			    is small compared to the time it takes a muon to traverse the distance between counters.  
			    Recommended:  d ~ 2m to begin with.  Click Explanation Button. <br> 
			    <img src="../graphics/tryPerf/ToF_2_counters_14.png"/> <br>
			    Once again, create a histogram, and find the mean time for muon to travel between the counters.
			    </p>
			    
			    <p>3.  Using the results from steps 1 and 2, we can populate the following table:
			    
			    <table border="1" align="center">
 					<tr align="center">
   						<th>Run</th>
   						<th>x:  Separation (m)</th>
   						<th>y:  Mean Traversal Time (mtt) (ns)</th>
   						<th>Std. dev. of mtt (ns)</th>
 					</tr>
 					<tr align="center">
   						<td style="border:1px solid black;">1</td>
   						<td style="border:1px solid black;">0.3</td>
   						<td style="border:1px solid black;">-1.74</td>
   						<td style="border:1px solid black;">2.59</td>
 					</tr>
 					<tr align="center">
 						<td style="border:1px solid black;">2</td>
   						<td style="border:1px solid black;">2.4</td>
   						<td style="border:1px solid black;">6.31</td>
   						<td style="border:1px solid black;">2.82</td>
 					</tr>
				</table><br>
				
				<e:popup href="explain_2means.html" target="Explain 2 means" width="450" height="200">
				Click here for explanation on why we use the distribution mean.</e:popup><br></br>
				We now have 2 data points.  The x axis represents separation distance, and the y axis represents mean traversal time.  
				We can graph them on paper and calculate the slope of the line connecting them.  This is 1/(muon speed). Q:  What are the units?<br></br>
				<center>&Delta;y / &Delta;x = (6.31 - -1.74)ns/(2.4 - 0.3)m</center><br>
				<center>Therefore, we can say that muon speed = 2.1m/8.05ns = 0.261m/ns = 2.61*10^8m/s</center><br>
			        
			    <img src="../graphics/tryPerf/ToF_2pt_graph.jpg" width="300px" height="auto"/> <br>
			    </p>
			    
			    <p>4.  One can measure muon speed better with more data points representing different separation distances.
			    For example, to generate a third data point, swap the two counters.  Now, the separation distance d = -2.4m because the muon travels 
			    from counter 4 to counter 1.<br></br> 
			    <img src="../graphics/tryPerf/ToF_2_counters_41.png"/> 
			      		
				<table border="1" align="center">
 					<tr align="center">
   						<th>Run</th>
   						<th>x:  Separation (m)</th>
   						<th>y:  Mean Traversal Time (mtt) (ns)</th>
   						<th>Std. dev. of mtt (ns)</th>
 					</tr>
 					<tr align="center">
   						<td style="border:1px solid black;">1</td>
   						<td style="border:1px solid black;">0.3</td>
   						<td style="border:1px solid black;">-1.74</td>
   						<td style="border:1px solid black;">2.59</td>
 					</tr>
 					<tr align="center">
 						<td style="border:1px solid black;">2</td>
   						<td style="border:1px solid black;">2.4</td>
   						<td style="border:1px solid black;">6.31</td>
   						<td style="border:1px solid black;">2.82</td>
 					</tr>
 					<tr align="center">
 						<td style="border:1px solid black;">3</td>
   						<td style="border:1px solid black;">-2.4</td>
   						<td style="border:1px solid black;">-9.98</td>
   						<td style="border:1px solid black;">2.94</td>
 					</tr>
				</table>
					
				<br>We now have 3 data points.  We can graph them on paper and try to put error bars around each point.  
				<e:popup href="explain_error_mean.html" target="Explain Mean Error" width="500" height="250">Click here for explanation on mean error</e:popup>.
				Eyeball it, and draw the best fit line.  Then, calculate the slope of the line to get a better value for muon speed.  <br></br>
			    <center>&Delta;y / &Delta;x = ( - )ns/( - )m</center><br>
				<center>Therefore, we can say that muon speed = m/ns </center><br>
			    <img src="../graphics/tryPerf/ToF_3pt_graph.jpg" width="300px" height="auto"/> <br></br>
			    </p>	    
			    
				<p>5.  Here is another effect to think about.  If you use a large separation, the rate of muons going through both counters may be so low that the 
				trigger rate is dominated by the rate of two different muons, neither going through both counters, so not travelling the path 
				length we think we are measuring.  We do not want to use the times from <font color="red">two different muons</font> 
				since that tells us nothing about the speed of <font color="blue">1 muon</font> hitting both counters. <br></br>
				<img src="../graphics/tryPerf/ToF_2_counters_1vs2muons.png"/> <br></br>			
				How can you minimize this effect?  Go to page 2.
				</p>
			</td>
		</tr>
				
		<tr>
			<td width=5>&nbsp;</td>					
			<td valign="top" width=322>
				&nbsp<p>
				&nbsp<p>
				
			</td>
		</tr>
				
		<tr>
			<td colspan=3>
				<p align=center> Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a></p>				
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


