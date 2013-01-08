<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
<%@ page import="java.util.*" %>
	
<e:analysis name="analysis" type="I2U2.Cosmic::FluxStudy">
	<%
		//these need to always be set-up
		ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("analysis");
		Collection rawData = analysis.getParameterValues("rawData");
		if (rawData != null) {
			List thresholdData = AnalysisParameterTools.getThresholdFiles(elab, rawData);
			List wd = AnalysisParameterTools.getWireDelayFiles(elab, rawData);
			List geo = AnalysisParameterTools.getGeometryFiles(elab, rawData);
			String ids = AnalysisParameterTools.getDetectorIds(rawData);
			String cpldfreqs = AnalysisParameterTools.getCpldFrequencies(elab, rawData);
			String firmwareVersions = AnalysisParameterTools.getFirmwareVersions(elab, rawData); 
			
			request.setAttribute("channels", AnalysisParameterTools.getValidChannels(elab, rawData));
			//<trdefault> is equivalent to analysis.setParameterDefault()
			//It indicates that these parameters are NOT USER CONTROLLED and
			//should not be encoded in the param URLs for a subsequent run.
			%>
	        <e:trdefault name="thresholdAll" value="<%= thresholdData %>"/>
	        <e:trdefault name="wireDelayData" value="<%= wd %>"/>
			<e:trdefault name="detector" value="<%= ids %>"/>
			<e:trdefault name="singlechannelOut" value="singlechannelOut"/>
			<e:trdefault name="geoDir" value="${elab.properties['data.dir']}"/>
			<e:trdefault name="geoFiles" value="<%= geo %>"/>
			<e:trdefault name="cpldfreqs" value="<%= cpldfreqs %>"/>
			<e:trdefault name="firmwares" value="<%= firmwareVersions %>" />
			<%
		}
	%>
	<e:trdefault name="plot_outfile_param" value="plot_param"/>
	<e:trdefault name="plot_outfile_image" value="plot.png"/>
	<e:trdefault name="plot_outfile_image_thumbnail" value="plot_thm.png"/>
	<e:trdefault name="plot_thumbnail_height" value="150"/>
	<e:trdefault name="plot_plot_type" value="1"/>
	<e:trdefault name="plot_xlabel" value="Time UTC (hours)"/>
	<e:trdefault name="plot_ylabel" value="Flux (events/m^2/60-seconds)"/>
	<e:trdefault name="sort_sortKey1" value="2"/>
	<e:trdefault name="sort_sortKey2" value="3"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-flux/output.jsp&onError=../analysis-flux/analysis.jsp"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose flux parameters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>

	<body id="flux-study" class="data">
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
		<h1>Calculate the flux for your data file. Remember, flux = particles / time / area</h1>
<div id="rationale">This analysis looks at the arrival rate of cosmic ray muons over time. The calculations average the instantaneous arrivals and create a scatter plot of rate vs. time.</div>
<div id="rationale">Gain confidence by running a practice analysis.</div>
<hr>
		<table border="0" id="main">
			<tr>
				<td id="center">
					<p>
						<a href="../analysis-flux/tutorial.jsp">Understand the graph</a>
					</p>
					
					<jsp:include page="../data/analyzing-list.jsp"/>
					
					<p id="other-analyses">
						Analyze the same files in
						<e:link href="../analysis-lifetime/analysis.jsp" rawData="${analysis.parameters.rawData}">lifetime</e:link>&nbsp;or&nbsp;
						<e:link href="../analysis-shower/analysis.jsp" rawData="${analysis.parameters.rawData}">shower</e:link>
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
