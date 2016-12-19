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
			<table width = "650" cellpadding ="8">
				<tr>
					<td colspan = "3">
						<center><font color="#0a5ca6" size="+3"><b>Detector Performance Study</b></font></center>
	 				</td>
	 			</tr>
	 			
	 			<tr>
	 				<td colspan=3>
	 				<p>&nbsp;
	 				<p>	
	 				The main objective of the <q>system performance</q> study is to understand the quality of the data. In order to 
	 				believe in any science results from the analysis, one must first confirm that the detector performs reliably over time.  
	 				We measure the length of time the <a href="javascript:glossary('photomultiplier tube',350)">photomultiplier tube</a> 
	 				responds to a <a href="javascript:glossary('muon',350)">muon</a> and count the number of muons for each value. 
	 				A data set that has a lot of muons with short response times and only a few muons with longer times may indicate a noisy <a href="javascript:glossary('counter',350)">counter</a>. 
	 				We create a histogram of the number of events (muon hits) as a function of <a href="javascript:glossary('signal width',350)">time over threshold</a> (ToT) 
	 				to evaluate data in the performance study. 
	 				
	 				<p>Figure 24(a) below shows the ideal, <a href="javascript:glossary('Gaussian distribution',350)">Gaussian distribution</a> 
	 				about a mean value for ToT.  Figure 24(b) shows an actual data run plot, which peaks around 12 ns (which is typical for the 1/2 inch thick scintillator, 
	 				the PMT efficiency, and threshold settings used in our experiment).  
	 				
	 				<br><img src="../graphics/tryPerf/perf_ideal_actual.png" alt="">
	 				
	 				<p>The actual data, however, appears more skewed than Gaussian. This histogram may tell us that there is <q>good</q> data in our actual run data, 
	 				but that it is contaminated with short pulses (a.k.a. noise) that were just above threshold. Increasing the threshold value may <q>clean-up</q> this channel in the future.
					When plotting a histogram, one can modify the number of bins into which the data are divided. Choosing a different number of bins for the same dataset can 
					significantly change the shape of the graph and may help evaluate the quality of the data.
					</td>
			    </tr>
			    				    
				<tr>
					<td colspan="3">
						<p>Inspect these plots. Which one shows a counter with an enormous number of 
						short <a href="javascript:glossary('signal',350)">signals</a>? Which two counters have similar performance? What would you 
						do if you owned these four counters?
					<p>&nbsp;
					</td>
				</tr>
				
				<tr>
					<td><img src="../graphics/Ballard1.gif" alt=""></td>
					<td width=5>&nbsp;</td>
					<td><img src="../graphics/Ballard2.gif" alt=""></td>
				</tr>
				
				<tr>
					<td>&nbsp;</td>
					<td width=5>&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				
				<tr>
					<td><img src="../graphics/Ballard3.gif" alt=""></td>
					<td width=5>&nbsp;</td>
					<td><img src="../graphics/Ballard4.gif" alt=""></td>
				</tr>
				
				<tr>
			    	<td colspan=3>
			    	For more background information, see how the <A href="../flash/daq_only_standalone.html">detector works</a>.	
			    	<br>
			    	<i><p>Figure 24(a) is used with permission. Eric W. Weisstein. "Gaussian Distribution." 
			    	<br>&emsp;From <a href="http://mathworld.wolfram.com/GaussianDistribution.html" target="_blank">MathWorld</a>--A Wolfram Web Resource. </i>
			    	</td>
			    </tr>	
				
				<tr>
					<td colspan="3"  align="center">	
						Tutorial Pages: <b>1</b> <a href="tutorial2.jsp">2</a> <a href="tutorial3.jsp">3</a>  <a href="tutorial4.jsp">4</a> & <a href="index.jsp">Analysis</a>
					<p>&nbsp;
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

