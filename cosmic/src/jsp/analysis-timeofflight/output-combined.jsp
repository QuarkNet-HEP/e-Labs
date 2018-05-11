<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>
<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	
	String timeofflightId = results.getId();
	AnalysisRun timeofflightResults = AnalysisManager.getAnalysisRun(elab, user, timeofflightId);
	request.setAttribute("timeofflightResults", timeofflightResults);
	String message = "";
	String fluxJsonFile = results.getOutputDir() + "/timeOfFlightPlotData";
	String chanRequire = (String) analysis.getParameter("singleChannel_require");
	String chanVeto = (String) analysis.getParameter("singleChannel_veto");
	try {
		//this code is for admin to be able to see the graph
		File f = new File(fluxJsonFile);
		if (!f.exists()) {
			String userParam = (String) request.getParameter("user");
			if (userParam == null) {
				userParam = (String) session.getAttribute("userParam");
			}
			session.setAttribute("userParam", userParam);
			ElabGroup auser = user;
			if (userParam != null) {
			    if (!user.isAdmin()) {
			    	throw new ElabJspException("You must be logged in as an administrator" 
			        	+ "to see the status of other users' analyses");
			    }
			    else {
			        auser = elab.getUserManagementProvider().getGroup(userParam);
			    }
			}
			//create time of flight source data
			TimeOfFlightDataStream tofds = new TimeOfFlightDataStream(results.getOutputDir(), chanRequire, chanVeto);
		}
	} catch (Exception e) {
			message = e.getMessage();
	}	
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Time Of Flight Study Analysis Combined Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/interactive-cosmic-plots.css" />
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="timeofflight-study-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
				<script type="text/javascript" src="../include/elab.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.errorbars.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.symbol.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.selection.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.navigate.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.crosshair.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.stack.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.time.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.text.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/jquery.flot.canvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.axislabels.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/excanvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/excanvas.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/excanvas.compiled.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083083/d3.v3.min.js"></script>
				<script type="text/javascript" src="../include/json/json.worker.js"></script>
				<script type="text/javascript" src="../include/json/json.async.js"></script>
				<script type="text/javascript" src="../include/canvas2image.js"></script>
				<script type="text/javascript" src="../include/base64.js"></script>
				<script type="text/javascript" src="../analysis/analysis-plot.js"></script>
				<script type="text/javascript" src="timeofflight-combined.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						type: "GET",
						success: onDataLoad1
					});
				}); 	
				</script>			

	<h1>Time of flight study result</h1>
	<a href="output.jsp?id=${timeofflightResults.id}">View individual charts</a>
	<div class="graph-container" id="spinner">
		<div id="placeholder" class="graph-placeholder" style="float:left; width:550px; height:550px;"></div>
		<div id="overview" class="graph-placeholder" style="float:right;width:160px; height:150px;"></div>
		<div id="interactive" style="float:right;width:160px; height:325px;">
			<p><label><input id="enableTooltip" type="checkbox" checked="checked"></input>Enable tooltip</label></p>
			<p>
				<label><input id="enablePosition" type="checkbox" checked="checked"></input>Show mouse position:</label>
				<br /><span id="hoverdata" class="hoverdata"></span>
				<br /><span id="clickdata" class="clickdata"></span>
			</p>				
			<p><div id="zoomoutbutton" style="float:left; width:80px; height:30px;"> </div>
			   <div id="resetbutton" style="float:right; width:80px; height:30px;"> </div></p>
			<p><div id="arrows" style="float:right; width:160px; height:100px;"><div id="arrowcontainer" style="position:relative;"></div></div></p>
			<p class="message"></p>
			<p class="click"></p>
		</div>
		<div id="placeholderLegend" class="legend-placeholder"></div>
	</div>
	<div id="incdec">Bin Width
   		<input type="number" name="binWidth" id="binWidth" style="width: 60px;"/>
	</div>
	<div class="slider">
    	<input id="range" type="range" style="width: 650px;">
	</input>
	
<p>
	Analysis run time: ${timeofflightResults.formattedRunTime} 
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${timeofflightResults.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">time of flight analysis directory</e:popup> 
</p>
<p>
	<e:rerun type="timeofflight" id="${timeofflightResults.id}" label="Change"/> your parameters
</p>
<input type="hidden" name="outputDir" id="outputDir" value="${results.outputDirURL}"/>
<% if (!user.isGuest()) { %>
	<p><b>OR</b></p>
		<div class="dropdown" style="text-align: left; width: 180px;">
			<input type="text" name="name" id="newPlotName" value="" size="20" maxlength="30"/>
			<%@ include file="../plots/view-saved-plot-names.jsp" %>
		</div>(View your saved plot names)<br />
<!--This was Edit's original code.  Many functions in onclick (with return) caused problems. Also, chartMsg needed code.        
                <input type="button" name="save" onclick='return validatePlotName("newPlotName"); return saveChart(onOffPlot, "name", "chartMsg", "${results.id}");' value="Save"></input>
				<div id="chartMsg"></div> 
-->
		
		<input type="button" name="save" onclick=' validateAndSaveCombChart(onOffPlot, "newPlotName", "chartMsg", "${results.id}");' value="Save"></input>    
		<div id="chartMsg">&nbsp;</div> 
		 
		<e:commonMetadataToSave rawData="${timeofflightResults.analysis.parameters['rawData']}"/>
		<e:creationDateMetadata/>
		<input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::TimeOfFlight"/>
		<input type="hidden" name="metadata" value="study string timeofflight"/>
		<input type="hidden" name="metadata" value="type string plot"/>
		<input type="hidden" name="metadata" value="detectorcoincidence int ${timeofflightResults.analysis.parameters['detectorCoincidence']}"/>
		<input type="hidden" name="metadata" value="eventcoincidence int ${timeofflightResults.analysis.parameters['eventCoincidence']}"/>
		<input type="hidden" name="metadata" value="eventnum int ${timeofflightResults.analysis.parameters['eventNum']}"/>
		<input type="hidden" name="metadata" value="gate int ${timeofflightResults.analysis.parameters['gate']}"/>
		<input type="hidden" name="metadata" value="radius int -1"/>

		<input type="hidden" name="metadata" value="title string ${timeofflightResults.analysis.parameters['plot_title']}"/>
		<input type="hidden" name="metadata" value="caption string ${timeofflightResults.analysis.parameters['plot_caption']}"/>

		<input type="hidden" name="srcFile" value="plot.png"/>
		<input type="hidden" name="srcThumb" value="plot_thm.png"/>
		<input type="hidden" name="srcSvg" value="plot.svg"/>
		<input type="hidden" name="srcFileType" value="png"/>
		<!-- EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot -->
		<input type="hidden" name="eventCandidates" value="eventCandidates" />
		<input type="hidden" name="eventDir" value="${eventDir}" />
		<input type="hidden" name="eventNum" value="${timeofflightResults.analysis.parameters['eventNum']}" />
		<input type="hidden" name="id" value="${timeofflightResults.id}"/>
		<input type="hidden" name="rundirid" value="${results.id}"/>

<% } %>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
