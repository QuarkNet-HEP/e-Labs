<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>

<e:analysis name="analysis" type="I2U2.Cosmic::PerformanceStudy">
	<%
		ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("analysis");
		Collection rawData = analysis.getParameterValues("rawData");
		if(rawData != null) {
			List thresholdData = AnalysisParameterTools.getThresholdFiles(elab, rawData);
			String ids = AnalysisParameterTools.getDetectorIds(rawData);
			String cpldfreqs = AnalysisParameterTools.getCpldFrequencies(elab, rawData);
			
			Collection channels = AnalysisParameterTools.getValidChannels(elab, rawData);
			//make a new copy because we're going to mess with this one
			request.setAttribute("validChannels", new HashSet(channels));
			//only set up channels after a submit was pressed
			if (request.getParameter("submit") != null) {
				for (int i = 1; i <= 4; i++) {
					String channel = String.valueOf(i);
					if (request.getParameter(channel) == null) {
						channels.remove(channel);
					}
				}
			}
			else {
				//otherwise set from analysis
				//now, this should be done nicer, with parameter processors instead of one-to-one
				//mapping between parameters and analysis parameters
				String achannels = (String) analysis.getParameter("singlechannel_channel");
				if (achannels != null && !"".equals(achannels)) {
					for (int i = 1; i <= 4; i++) {
						String channel = String.valueOf(i);
						if (achannels.indexOf(channel) == -1) {
							channels.remove(channel);
						}
					}
				}
			}
			//we must ensure the same iteration order, so singleChannels, singleChannelOuts, and
			//freqOuts have the channels in the same order
			Collection c = new TreeSet(channels);
			
			String singleChannels = ElabUtil.join(c, null, null, " ");
			String singleChannelOuts = ElabUtil.join(c, "singleOut", null, " ");
			String freqOuts = ElabUtil.join(c, "freqOut", null, " ");
			
			//<trdefault> is equivalent to analysis.setParameterDefault()
			//It indicates that these parameters are not user controlled and
			//should not be encoded in the param URLs for a subsequent run.
			%>
	        <e:trdefault name="thresholdAll" value="<%= thresholdData %>"/>
			<e:trdefault name="detector" value="<%= ids %>"/>	  
			<e:trdefault name="singlechannel_channel" value="<%= singleChannels %>"/>
			<e:trdefault name="singlechannelOut" value="<%= singleChannelOuts %>"/>
			<e:trdefault name="freqOut" value="<%= freqOuts %>"/>
			<e:trdefault name="cpldfreqs" value="<%= cpldfreqs %>"/>
			<%
		}
	%>
	<e:trdefault name="plot_outfile_param" value="plot_param"/>
	<e:trdefault name="plot_outfile_image" value="plot.png"/>
	<e:trdefault name="plot_outfile_image_thumbnail" value="plot_thm.png"/>
	<e:trdefault name="plot_thumbnail_height" value="150"/>
	<e:trdefault name="plot_plot_type" value="7"/>
	<e:trdefault name="plot_xlabel" value="Time over Threshold (nanosec)"/>
	<e:trdefault name="plot_ylabel" value="Number of PMT pulses"/>
	<e:trdefault name="freq_binType" value="1"/>
	<e:trdefault name="freq_col" value="5"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-performance/output.jsp&onError=../analysis-performance/analysis.jsp"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>
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
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<c:choose>
	<c:when test="${analysis.parameters.rawData != null}">
		<h1>Do you trust the detector? Analyze its performance before you use the data for other studies.</h1>
<div id="rationale">This analysis looks at the <a href="javascript:glossary('signal',150)">signals</a> generated when cosmic ray muons passes through a counter. The values are displayed in a histogram. </div>
<div id="rationale">Gain confidence by running a practice analysis.</div>
<hr>
		<table border="0" id="main">
			<tr>
				<td id="center">
					<p>
						<a href="../analysis-performance/tutorial.jsp">Understand the graph</a>
					</p>
					
					<jsp:include page="../data/analyzing-list.jsp"/>
					
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
