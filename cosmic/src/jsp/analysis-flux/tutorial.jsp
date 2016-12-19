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

				You can:
				<strong>1)</strong> Find some help on this page
				<strong>2)</strong>
				<e:popup href="../posters/display.jsp?type=poster&name=adler_flux.data" target="possibleparticledelays" width="700" height="510">View</e:popup> a poster created using this study
				<strong>3)</strong>
				<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: Step-by-Step Instructions
	
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
							&nbsp<p>Definition of Cosmic ray flux:
							<center><font size=+2>&Phi;<sub>CR</sub> = <sup>(events)</sup>&frasl;<sub>(time)(area)</sub></font></center>
								<p>Since the area of the detector remains constant during an experiment, <a HREF="javascript:glossary('flux',100)">flux</a> studies ask the question, 
								&quot;How does the rate (events/time) at which cosmic rays pass through a <a href="javascript:glossary('counter',100)">counter</a> depend on a certain variable?&quot;
								One can consider flux throughout the day or year to see if there are changes in the arrival rate of these particles. 
								For example, one can see if it depends on time of day or perhaps solar activity.   
								<p>Flux experiments may include several <a href="javascript:glossary('geometry',100)">geometries</a> of your detectors such as:
								<ol>
									<li>closely stacked counters that require coincidence (2, 3, or 4)<br><img src="../graphics/tryPerf/flux_234stacks.png" align="middle"></li>
									<li>two stacks of stacked counters<br><img src="../graphics/tryPerf/flux_2counter_stacks.png" align="middle"></li>									
									<li>separated, stacked counters that require coincidence to look at flux from only a particular direction of the sky
									<br><img src="../graphics/tryPerf/flux_separated_stack.png" align="middle"></li>
									<li>multiple counters placed in the same plane to increase detector area<br><img src="../graphics/tryPerf/flux_4counters_plane.png" align="middle"></li>
									<li>avoid using a single counter (1-fold coincidence dominated by noise)<br><img src="../graphics/tryPerf/flux_1counter.png" align="middle"></li>				
									</ul>
								</ol>									
							</td>
							
							</td>
						</tr>
				
						<tr>
							<td colspan=3>
								&nbsp<p align=center> Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> & <a href="index.jsp">Analysis</a>
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

