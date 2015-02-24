<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>

<%
	ElabUserManagementProvider p = elab.getUserManagementProvider();
	CosmicElabUserManagementProvider cp = null;
	if (p instanceof CosmicElabUserManagementProvider) {
		cp = (CosmicElabUserManagementProvider) p;
	}
	else {
		throw new ElabJspException("The user management provider does not support management of DAQ IDs. ");
	}    
	String message = "";
	String id = request.getParameter("id");
	AnalysisRun results = AnalysisManager.getAnalysisRun(elab, user, id);
	ArrayList fileArray = (ArrayList) results.getAttribute("inputfiles");
	//check that there is data from only one detector
	String[] detector = new String[fileArray.size()];
	for (int i = 0; i < fileArray.size(); i++) {
		String filename = (String) fileArray.get(i);
		String[] parts = filename.split("\\.");
		detector[i] = parts[0];
	}
	for (int i = 0; i < detector.length - 1; i++) {
		if (detector[i] != detector[i+1]) {
			message = "We cannot graph data from multiple detectors.";
		}
	}
	Collections.sort(fileArray);
	request.setAttribute("fileArray", fileArray);
	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Blessing Plots From Flux Study</title>
		<link type="text/css" href="../css/nav-rollover.css" rel="Stylesheet" />		
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css"/>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>		
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="benchmark"  >
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
		<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
		<script type="text/javascript" src="../include/excanvas.min.js"></script>
		<script type="text/javascript" src="blessing.js"></script>
		<script type="text/javascript" src="benchmark.js"></script>			
		<script>
			$(document).ready(function() {
				if ("<%=fileArray%>" != null && "<%=fileArray%>" != "") {					
					$.ajax({
						url: "get-data-range.jsp?file=<%=fileArray%>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoadRange
					});
				}
			});
		</script>	
<h1>View blessing plots by date range.</h1>
	<c:choose>
		<c:when test="${empty message }">
			<h2>Rates</h2>
			<!-- control added to change axes values -->
			<jsp:include page="chartcontrols-range.jsp">
				<jsp:param name="chartName" value="channel" />
			</jsp:include>				
			<div id="channels" style="background-color:#FFFFFF">
				<div id="channelChart" style="width:750px; height:250px; text-align: left;"></div>
				<div id="channelChartLegend" style="width: 750px;"></div>
			</div>
			<!-- EPeronja-07/31/2013 570-Bless Charts: add option to save them as plots -->
			<div style="text-align:center; width: 100%;">
				Filename <input type="text" name="channelChartName" id="channelChartName" value=""></input><input type="button" name="save" onclick='return saveChart(onOffPlot, "channelChartName", "channelMsg");' value="Save Channel Chart"></input>     
				<div id="channelMsg"></div>   
			</div>
								
			<h2>Trigger Rate</h2>
			<!-- control added to change axes values -->
			<jsp:include page="chartcontrols-range.jsp">
				<jsp:param name="chartName" value="trigger" />
			</jsp:include>					
			<div id ="triggerChart" style="width:750px; height:250px; text-align: left;"></div>
			<div style="text-align:center; width: 100%;">
				Filename <input type="text" name="triggerChartName" id="triggerChartName" value=""></input><input type="button" name="save" onclick='return saveChart(trigPlot, "triggerChartName", "triggerMsg");' value="Save Trigger Chart"></input>     
				<div id="triggerMsg"></div>   
			</div>
		</c:when>
		<c:otherwise>
			<div>${message }</div>
		</c:otherwise>
	</c:choose>
	<c:if test="${not empty fileArray}">
		<table>
			<tr><th>Files in charts</th></tr>
		<c:forEach items="${fileArray }" var="file">
			<tr><td>${file }</td></tr>
		</c:forEach>
		</table>
	</c:if>
	
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
