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
			TimeOfFlightDataStream tofds = new TimeOfFlightDataStream(results.getOutputDir());
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
				<script type="text/javascript" src="../include/jquery/flot083/jquery.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.errorbars.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.symbol.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.selection.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.navigate.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.crosshair.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.stack.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.time.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.text.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/jquery.flot.canvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.min.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/excanvas.compiled.js"></script>
				<script type="text/javascript" src="../include/jquery/flot083/d3.v3.min.js"></script>
				<script type="text/javascript" src="../include/json/json.worker.js"></script>
				<script type="text/javascript" src="../include/json/json.async.js"></script>
				<script type="text/javascript" src="../include/canvas2image.js"></script>
				<script type="text/javascript" src="../include/base64.js"></script>
				<script type="text/javascript" src="../analysis/analysis-plot.js"></script>
				<script type="text/javascript" src="timeofflight-singles.js"></script>
				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						type: "GET",
						success: onDataLoad1
					});
				}); 	
				</script>			

	<h1>Time of flight study result</h1>
	<a href="output-combined.jsp?id=${timeofflightResults.id}">View all charts combined</a>
	<div class="graph-container-timeofflight">
		<div class="row">
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="1" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>		
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="2" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="3" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>
		</div>		
		<div class="row">
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="4" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>		
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="5" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>
			<jsp:include page="single-chart.jsp">
				<jsp:param name="chartIndex" value="6" />
				<jsp:param name="runId" value="${timeofflightResults.id}" />
			</jsp:include>
		</div>		
	</div>
<p>
	Analysis run time: ${timeofflightResults.formattedRunTime}; estimated: ${timeofflightResults.formattedEstimatedRunTime}
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
	<%@ include file="save-form.jspf" %>
<% } %>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
