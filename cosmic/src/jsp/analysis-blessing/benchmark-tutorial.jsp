<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark tutorial</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark-tutorial" class="data, tutorial">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content" style="margin-left:auto; margin-right:auto; width:70%;">
			<table width="100%" cellpadding ="8">
				<tr>
					<td style="text-align: center;"><font color="#0a5ca6" size="+3">Benchmark Tutorial</font></td>
				</tr>
				<tr>
					<td style="text-align: left;">
						Go to: "Cosmic Ray e-Lab&#8594;Upload &#8594;Benchmark"<br />
						<img src="../graphics/benchmark_menu.png" name="Benchmark Menu" alt="Benchmark Menu"></img>						
						This is where a detector owner will select a <strong>best standard</strong> data file for 
						comparison to other files in order to bless the other. <br />
						The file owner needs to review the blessing plots and use judgement to select one standard file.<br />
						So, first pull down the DAQ list to see your DAQ#s,
						<img src="../graphics/detector_pull_down.png" name="Detector pull down" alt="Detector Pull down"></img>
						and select your appropriate DAQ#. <br />
						Now, set the date range to include one CRMD configuration (coincidence and geometry).<br />
						Click "Select Benchmark". This will present a list of candidates for selection. <br/>
						<img src="../graphics/select_benchmark.png" name="Select Benchmark" alt="Select Benchmark"></img><br />
						Review the list of candidates by clicking on the file number (such as "6119.2013.1012.0") and looking
						at the Singles Rates and Trigger Rate. <br />
						Use your judgment to decide if this file is representative of all the data for your particular CRMD configuration. A
						high quality file will have steady Singles & Trigger Rates, plus Soingles will fall between 12 to 35 Hz for 
						the standard QuarkNet counters. Here is an example of good blessing plot: <br />
						<img src="../graphics/good_blessing_plot.png" name="Good Example" alt="Good Example"></img><br />
						and this shows a bad blessing plot: <br />
						<img src="../graphics/bad_blessing_plot.png" name="Bad Example" alt="Bad Example"></img><br />
						Notice how one of the channels wanders around indicating irregular rates.<br />
						After you have selected a representative file, type a helpful name that you will recognize later and click "Save".
						Now, when you go back to "Upload" &#8594; "Upload" the chosen benchmark will appear on the pull-down list next to the DAQ#.<br />					
						Later, if the detector configuration changes (coincidence, geometry) then a new benchmark file
	 					needs to be selected. <br /><br />
	 					(Examples go here)	 <br /><br />
						When selecting files for analysis, review the blessing plots by clicking on the "star". 
						See if you agree with the owner assessment for quality data.
					</td>
	 			</tr>
			</table>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

