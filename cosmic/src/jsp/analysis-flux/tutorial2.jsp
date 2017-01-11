<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Flux study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="flux-tutorial" class="data, tutorial">
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
					
					
					<table width = 650>
						<tr>
							<td colspan = 3>
								<center><font color="#0a5ca6" size=+3><b>Flux Study</b></font></center>
	 						</td>
	 					</tr>
				
						<tr>
							<td colspan=3>
								<p>The <a HREF="javascript:glossary('detector',100)">detectors</a> record the arrival time of the <a href="javascript:glossary('muon',100)">muons</a> in a raw data file.  
								When analyzing flux study data, students select the dataset and channel(s) to be analyzed. The analysis tools produce a histogram of flux vs. time similar to the one shown below. 
								Students can juxtapose data regarding their independent variable as a function of time to look for correlations.										
							</td>

						</tr>
				
						<tr>
							<td colspan = 3>
							<p>
							<center><font size=+2><b>Sample Plot</b></font></center>
							</td>
						</tr>
	
						<tr>
							<td valign=top width=322>
								<img src="../graphics/flux.png">
							</td>

							<td width=5>&nbsp;</td>
			
							<td valign=top width=322>
								&nbsp<p>
								<p> 
								One interesting feature occurs periodically in this <a href="http://www.shodor.org/interactivate/activities/scatterplot/">scatter plot</a>: 
								the flux diminishes and increases regularly; do you see it? What might cause this? Is the effect real or is it the result of the way this file was plotted? Is there a way that you can tell?
								<p>
								This plot shows <a HREF="javascript:glossary('flux',350)">flux</a> measurements for <a HREF="javascript:glossary('detector',350)">detector # 5078 </a> 
								from 7 May to 11 May 2003. The counters were stacked, one on top of the other, <img src="../graphics/stacked.gif" />.
								<p>
								<center>
									<IMG SRC="../graphics/stacked.jpg" BORDER=1> 
									<br> (How the <A href="../flash/daq_only_standalone.html">detector works</a>) 
								</center>
							</td>
						</tr>
						
						<tr>
							<td colspan=3>
								&nbsp<p align=center> Tutorial Pages: <a href="tutorial.jsp">1</a> <b>2</b> <a href="tutorial3.jsp">3</a> & <a href="index.jsp">Analysis</a>
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

