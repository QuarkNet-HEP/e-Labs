<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
	
<e:analysis name="analysis" type="I2U2.Cosmic::ShowerStudy">
	<%
		ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("analysis");
		Collection rawData = analysis.getParameterValues("rawData");
		if(rawData != null) {
			List thresholdData = AnalysisParameterTools.getThresholdFiles(elab, rawData);
			String ids = AnalysisParameterTools.getDetectorIds(rawData);
			List wd = AnalysisParameterTools.getWireDelayFiles(elab, rawData);
			List geo = AnalysisParameterTools.getGeometryFiles(elab, rawData);
			String cpldfreqs = AnalysisParameterTools.getCpldFrequencies(elab, rawData);

			%>
	        <e:trdefault name="thresholdAll" value="<%= thresholdData %>"/>
	        <e:trdefault name="wireDelayData" value="<%= wd %>"/>
			<e:trdefault name="detector" value="<%= ids %>"/>
			<e:trdefault name="geoDir" value="${elab.properties['data.dir']}"/>
			<e:trdefault name="geoFiles" value="<%= geo %>"/>
			<e:trdefault name="cpldfreqs" value="<%= cpldfreqs %>"/>
			<%
		}
	%>
	<e:trdefault name="plot_outfile_param" value="plot_param"/>
	<e:trdefault name="plot_outfile_image" value="plot.png"/>
	<e:trdefault name="plot_outfile_image_thumbnail" value="plot_thm.png"/>
	<e:trdefault name="plot_thumbnail_height" value="150"/>
	<e:trdefault name="eventCandidates" value="eventCandidates"/>
	<e:trdefault name="plot_plot_type" value="2"/>
	<e:trdefault name="plot_xlabel" value="East/West (meters)"/>
	<e:trdefault name="plot_ylabel" value="North/South (meters)"/>
	<e:trdefault name="plot_zlabel" value="Time\n(ns)"/>
	<e:trdefault name="sort_sortKey1" value="2"/>
	<e:trdefault name="sort_sortKey2" value="3"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-shower/event-choice.jsp?submit=true&onError=../analysis-shower/analysis.jsp"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose shower parameters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-study" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<c:choose>
	<c:when test="${analysis.parameters.rawData != null}">
		<h1>Look for showers in your data</h1>
<div id="rationale">This analysis looks for cosmic ray muons that arrive at or near the same time over the geographic area defined by data you select. The routine displays a list of events that "pass" criteria that you set in the fields below. The plot shows the location and timing separation of <a href="javascript:glossary('signal',350)">signals</a> observed in your event. 
</div>
<div id="rationale">Gain confidence by running a practice analysis.</div>
<hr>
		<table border="0" id="main">
			<tr>
				<td id="center">
					<p>
						<a href="../analysis-shower/tutorial.jsp">Understand the graph</a>
					</p>
					
					<jsp:include page="../data/analyzing-list.jsp"/>
					
					<p id="other-analyses">
						Analyze the same files in
						<e:link href="../analysis-lifetime/analysis.jsp" rawData="${analysis.parameters.rawData}">lifetime</e:link>&nbsp;or&nbsp;
						<e:link href="../analysis-flux/analysis.jsp" rawData="${analysis.parameters.rawData}">flux</e:link> 
					</p>
					
				    <c:if test="${!(empty analysis.invalidParameters) && param.submit != null}">
				    	<h2>Invalid keys:</h2>
				        <ul class="errors">
				            <c:forEach var="f" items="${analysis.invalidParameters}">
				                <li><c:out value="${f}"/></li>
				            </c:forEach>
				        </ul>
				    </c:if>
				    
				    <%@ include file="controls.jsp" %>
				</td>
			</tr>
		</table>
	</c:when>
	<c:otherwise>
		<table border="0" id="main">
			<tr>
				<td id="center">
					<span class="error">No files selected!</span>
					<p>
						Please <a href="index.jsp">choose</a> at least one day to analyze.
					</p>
				</td>
			</tr>
		</table>
	</c:otherwise>
</c:choose>
			</div>
			<!-- end content -->	
	
			<div id="footer">

			</div>
		</div>
		<!-- end container -->
	</body>
</html>

	</e:ifAnalysisIsNotOk>
</e:analysis>
