<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
	
<elab:analysis name="analysis" type="Quarknet.Cosmic::PerformanceStudy">
	<%
		//these need to always be set-up
		//also, this piece of code is ugly
		String[] rawData = request.getParameterValues("rawData");
		if(rawData != null) {
			List thresholdData = AnalysisParameterTools.getThresholdFiles(rawData);
			String ids = AnalysisParameterTools.getDetectorIds(rawData);
			
			Collection channels = DataTools.getValidChannels(elab, rawData);
			String singleChannels = ElabUtil.join(channels, null, null, " ");
			String singleChannelOuts = ElabUtil.join(channels, "singleOut", null, " ");
			String freqOuts = ElabUtil.join(channels, "freqOut", null, " ");
			ElabAnalysis a = (ElabAnalysis) request.getAttribute("analysis");
			
			//<trdefault> is equivalent to analysis.setParameterDefault()
			//It indicates that these parameters are not user controlled and
			//should not be encoded in the param URLs for a subsequent run.
			%>
	        <elab:trdefault name="thresholdAll" value="<%= thresholdData %>"/>
			<elab:trdefault name="detector" value="<%= ids %>"/>	  
			<elab:trdefault name="singlechannel_channel" value="<%= singleChannels %>"/>
			<elab:trdefault name="singlechannelOut" value="<%= singleChannelOuts %>"/>
			<elab:trdefault name="freqOut" value="<%= freqOuts %>"/>
			<%
		}
	%>
	<elab:trdefault name="plot_outfile_param" value="plot_param"/>
	<elab:trdefault name="plot_outfile_image" value="plot.png"/>
	<elab:trdefault name="plot_outfile_image_thumbnail" value="plot_thm.png"/>
	<elab:trdefault name="plot_thumbnail_height" value="150"/>
	<elab:trdefault name="plot_plot_type" value="7"/>
	<elab:trdefault name="plot_xlabel" value="Time over Threshold (nanosec)"/>
	<elab:trdefault name="plot_ylabel" value="Number of muons"/>
	<elab:trdefault name="freq_binType" value="1"/>
	<elab:trdefault name="freq_col" value="5"/>
	
	<elab:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-performance/output.jsp&onError=../analysis-performance/analysis.jsp"/>
	</elab:ifAnalysisIsOk>
	<elab:ifAnalysisIsNotOk>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose performance parameters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="performance-study" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<c:choose>
	<c:when test="${param.rawData != null}">
		<h1>Do you trust the detector? Analyze its performance before you use the data for other studies.</h1>
		<table border="0" id="main">
			<tr>
				<td id="center">
					<p>
						<a href="tutorial.jsp">Understand the graph</a>
					</p>
					
					<jsp:include page="../data/analyzing-list.jsp">
						<jsp:param name="f" value="${param.rawData}"/>
					</jsp:include>
					
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

	</elab:ifAnalysisIsNotOk>
</elab:analysis>
