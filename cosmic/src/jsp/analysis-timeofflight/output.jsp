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
	String toffJsonFile = results.getOutputDir() + "/timeOfFlightPlotData";
	String chanRequire = (String) analysis.getParameter("singleChannel_require");
	String chanVeto = (String) analysis.getParameter("singleChannel_veto");
	try {
		//this code is for admin to be able to see the graph
		File f = new File(toffJsonFile);
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
		<title>Time Of Flight Study Analysis Results</title>
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
				<script type="text/javascript" src="timeofflight-singles.js"></script>
				<script type="text/javascript">
				function ajax1() {
					  return $.ajax({
						  type: "GET",
		          success: onDataLoad1
				    });					
				}
        function ajax2() {
            return $.ajax({
              type: "GET",
              success: onDataLoad2
            });
        }
        function ajax3() {
            return $.ajax({
              type: "GET",
              success: onDataLoad3
            });
        }
        function ajax4() {
            return $.ajax({
              type: "GET",
              success: onDataLoad4
            });
        }
        function ajax5() {
            return $.ajax({
              type: "GET",
              success: onDataLoad5
            });
        }
        function ajax6() {
            return $.ajax({
              type: "GET",
              success: onDataLoad6
            });
        }

        var deferred = $.Deferred();
        
				$(document).ready(function() {	
					$.when(ajax1(), ajax2(), ajax3(), ajax4(), ajax5(), ajax6())
				     .done(function (response1, response2, response3, response4, response5, response6) {
				    	    var feedback = document.getElementById("feedback");
				    	    feedback.innerHTML = "";
				     });
				    return deferred.promise();
        }); 	
								
				</script>			

	<h1>Time of flight study result</h1>
	<div id="feedback"></div>
	<a href="output-combined.jsp?id=${timeofflightResults.id}">View all charts combined</a>
	<div class="graph-container-timeofflight">
		<div class="row">
			<div id="chart1">
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="1" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>		
			</div>
			<div id="chart2">
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="2" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>
			</div>
			<div id="chart3">
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="3" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>
			</div>
		</div>		
		<div class="row">
			<div id="chart4">
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="4" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>		
			</div>
			<div id="chart5">
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="5" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>
			</div>
			<div id="chart6">			
				<jsp:include page="single-chart.jsp">
					<jsp:param name="chartIndex" value="6" />
					<jsp:param name="runId" value="${timeofflightResults.id}" />
				</jsp:include>
			</div>
		</div>		
	</div>
<p>
	Analysis run time: ${timeofflightResults.formattedRunTime} <%-- ; estimated: ${timeofflightResults.formattedEstimatedRunTime} --%>
</p>
<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${timeofflightResults.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">time of flight analysis directory</e:popup> 
</p>
<p>
	<e:rerun type="timeofflight" id="${timeofflightResults.id}" label="Change"/> your parameters
</p>

			<input type="hidden" name="outputDir" id="outputDir" value="${results.outputDirURL}"/>
			<e:commonMetadataToSave rawData="${timeofflightResults.analysis.parameters['rawData']}"/>
			<e:creationDateMetadata/>
			<input type="hidden" name="metadata" value="transformation string I2U2.Cosmic::TimeOfFlight"/>
			<input type="hidden" name="metadata" value="study string timeofflight"/>
			<input type="hidden" name="metadata" value="type string plot"/>
			<input type="hidden" name="metadata" value="detectorcoincidence int ${timeofflightResults.analysis.parameters['detectorCoincidence']}"/>
			<input type="hidden" name="metadata" value="eventcoincidence int ${timeofflightResults.analysis.parameters['eventCoincidence']}"/>
			<input type="hidden" name="metadata" value="eventnum int ${timeofflightResults.analysis.parameters['eventNum']}"/>
			<input type="hidden" name="metadata" value="gate int ${timeofflightResults.analysis.parameters['gate']}"/>
			<input type="hidden" name="metadata" value="title string ${timeofflightResults.analysis.parameters['plot_title']}"/>
			<input type="hidden" name="metadata" value="caption string ${timeofflightResults.analysis.parameters['plot_caption']}"/>
			<!-- EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot -->
			<input type="hidden" name="eventCandidates" value="eventCandidates" />
			<input type="hidden" name="eventDir" value="${eventDir}" />
			<input type="hidden" name="eventNum" value="${timeofflightResults.analysis.parameters['eventNum']}" />
			<input type="hidden" name="id" value="${timeofflightResults.id}"/>
			<input type="hidden" name="rundirid" value="${results.id}"/>
			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
