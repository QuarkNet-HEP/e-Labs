<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Lifetime study tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="lifetime-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
			
			Options:
				<strong>1)</strong> Find some help on this page. 
				<strong>2)</strong> 
					<e:popup href="../posters/display.jsp?type=poster&amp;name=lifetime_16may16-cosmic-crdata-robert_s._peterson-fermilab_test_array-batavia-il-2016.1114.data" 
						target="MuonLifetime" width="700" height="510">View</e:popup> a poster 
					created using this study. 
				<strong>3)</strong> 
					<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: 
					Step-by-Step Instructions.
	
	<p>
			<center>
			<table width = "655" cellpadding ="8">
				<tr>
					<td colspan = "3">
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Lifetime Study
 								</b>
							</font>
						</center>
					</td>
				</tr>
			
				<tr>
					<td colspan=3>
		 				
					
						<p>A classic modern physics experiment is the measurement of the muon mean lifetime.  Some short-lived cosmic ray <a href="javascript:glossary('muon',100)">muons</a> that reach Earth's surface may stop in a <a href="javascript:glossary('counter',350)">counter</a>, 
						wait around a while and then <a href="javascript:glossary('decay',350)">decay</a>  into an electron, a neutrino and an anti-neutrino. The muon will leave one signature in the detector, and the electron will leave another. 
						One can ask, "How long before the muon decays?  What is its <a href="javascript:glossary('lifetime',100)">lifetime</a>?"  Consider the figure below.
						<br>
						<center><img src="../graphics/tryPerf/lifetimeBasic.png" alt=""></center>
						<br>
						When a muon enters a counter, a signal is generated in that counter. If the muon travels through counter 1 and into counter 2, both of these counters should 
						have a signal at approximately the same time.  This is called a two-fold <a href="javascript:glossary('coincidence',100)">coincidence</a> (signal seen in two counters within a certain small time window).  
						If the muon has stopped within counter 2, however, it will &quot;wait around&quot; until it decays and generate a second signal in the same counter (2) upon decay. 
						The time between the two signals in counter 2, t<sub>DECAY</sub>, can be calculated from the raw data file.  
						
						<p>Furthermore, if no signal occurs in counter 3 (the veto counter), this is a strong 
						indication that a muon did indeed decay in counter 2.  Although existing  e-Lab tools do not include veto capability in software, the DAQ can be configured to require a veto counter in hardware.  In other words,
						veto is a useful concept but not available in the e-Lab analysis tools at the moment.  
						
						<p>For more background, see how the <A href="../flash/daq_only_standalone.html" target="_blank">detector works</a>.
						
					</td>
				</tr>
								
				<tr>
					
					</td>
				</tr>
				
				<tr>
					<td colspan=3>
						&nbsp;
						<p align=center> Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a> <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a></p>	
					</td>
				</tr>
			</table>
			<p>
		</center>
		
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>



