<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>

<e:analysis name="analysis" type="I2U2.Cosmic::LifetimeStudyAdvanced">
	<%
		//these need to always be set-up
		ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("analysis");
		Collection<String> rawData = analysis.getParameterValues("rawData");
		if(rawData != null) {
			List<String> thresholdData = AnalysisParameterTools.getThresholdFiles(elab, rawData);
			String ids = AnalysisParameterTools.getDetectorIds(rawData);
			List<String> wd = AnalysisParameterTools.getWireDelayFiles(elab, rawData);
			List<String> geo = AnalysisParameterTools.getGeometryFiles(elab, rawData);
			String cpldfreqs = AnalysisParameterTools.getCpldFrequencies(elab, rawData);
			String firmwareVersions = AnalysisParameterTools.getFirmwareVersions(elab, rawData);
			Collection muon_validChannelsRequire = AnalysisParameterTools.getValidChannels(elab, rawData);
			request.setAttribute("muon_validChannelsRequire", new HashSet(muon_validChannelsRequire));		
			Collection muon_validChannelsVeto = AnalysisParameterTools.getValidChannels(elab, rawData);
			request.setAttribute("muon_validChannelsVeto", new HashSet(muon_validChannelsVeto));		
			Collection electron_validChannelsRequire = AnalysisParameterTools.getValidChannels(elab, rawData);
			request.setAttribute("electron_validChannelsRequire", new HashSet(electron_validChannelsRequire));		
			Collection electron_validChannelsVeto = AnalysisParameterTools.getValidChannels(elab, rawData);
			request.setAttribute("electron_validChannelsVeto", new HashSet(electron_validChannelsVeto));		
			//only set up channels after a submit was pressed
			if (request.getParameter("submit") != null) {
				for (int i = 1; i <= 4; i++) {
					String channel = String.valueOf(i);
					if (request.getParameter("lifetime_muon_singleChannel_require"+channel) == null) {
						muon_validChannelsRequire.remove(channel);
					}
					if (request.getParameter("lifetime_muon_singleChannel_veto"+channel) == null) {
						muon_validChannelsVeto.remove(channel);
					}
					if (request.getParameter("lifetime_electron_singleChannel_require"+channel) == null) {
						electron_validChannelsRequire.remove(channel);
					}
					if (request.getParameter("lifetime_electron_singleChannel_veto"+channel) == null) {
						electron_validChannelsVeto.remove(channel);
					}
				}
			} else {
				String muon_channelsRequire = (String) analysis.getParameter("lifetime_muon_singleChannel_require");
				if (muon_channelsRequire != null) {
					for (int i = 1; i <= 4; i++) {
						String channel = String.valueOf(i);
						if (muon_channelsRequire.indexOf(channel) == -1) {
							muon_validChannelsRequire.remove(channel);
						}
					}
				}
				String muon_channelsVeto = (String) analysis.getParameter("lifetime_muon_singleChannel_veto");
				if (muon_channelsVeto != null) {
					for (int i = 1; i <= 4; i++) {
						String channel = String.valueOf(i);
						if (muon_channelsVeto.indexOf(channel) == -1) {
							muon_validChannelsVeto.remove(channel);
						}
					}
				}
				String electron_channelsRequire = (String) analysis.getParameter("lifetime_electron_singleChannel_require");
				if (electron_channelsRequire != null) {
					for (int i = 1; i <= 4; i++) {
						String channel = String.valueOf(i);
						if (electron_channelsRequire.indexOf(channel) == -1) {
							electron_validChannelsRequire.remove(channel);
						}
					}
				}
				String electron_channelsVeto = (String) analysis.getParameter("lifetime_electron_singleChannel_veto");
				if (electron_channelsVeto != null) {
					for (int i = 1; i <= 4; i++) {
						String channel = String.valueOf(i);
						if (electron_channelsVeto.indexOf(channel) == -1) {
							electron_validChannelsVeto.remove(channel);
						}
					}
				}

			}
			Collection mcr = new TreeSet(muon_validChannelsRequire);		
			String lifetime_muon_singleChannel_require = ElabUtil.join(mcr, null, null, " ");
			Collection mcv = new TreeSet(muon_validChannelsVeto);		
			String lifetime_muon_singleChannel_veto = ElabUtil.join(mcv, null, null, " ");
			Collection ecr = new TreeSet(electron_validChannelsRequire);		
			String lifetime_electron_singleChannel_require = ElabUtil.join(ecr, null, null, " ");
			Collection ecv = new TreeSet(electron_validChannelsVeto);		
			String lifetime_electron_singleChannel_veto = ElabUtil.join(ecv, null, null, " ");

			String valueHolder = "0";
			if (mcr.isEmpty()) {
				lifetime_muon_singleChannel_require = valueHolder;
			}
			if (mcv.isEmpty()) {
				lifetime_muon_singleChannel_veto = valueHolder;
			}
			if (ecr.isEmpty()) {
				lifetime_electron_singleChannel_require = valueHolder;
			}
			if (ecv.isEmpty()) {
				lifetime_electron_singleChannel_veto = valueHolder;
			}
			%>
	        <e:trdefault name="thresholdAll" value="<%= thresholdData %>"/>
	        <e:trdefault name="wireDelayData" value="<%= wd %>"/>
			<e:trdefault name="detector" value="<%= ids %>"/>
			<e:trdefault name="geoDir" value="${elab.properties['data.dir']}"/>
			<e:trdefault name="geoFiles" value="<%= geo %>"/>
			<e:trdefault name="cpldfreqs" value="<%= cpldfreqs %>"/>
			<e:trdefault name="firmwares" value="<%= firmwareVersions %>" />
			<e:trdefault name="lifetime_muon_singleChannel_require" value="<%= lifetime_muon_singleChannel_require %>"/>
			<e:trdefault name="lifetime_muon_singleChannel_veto" value="<%= lifetime_muon_singleChannel_veto %>"/>
			<e:trdefault name="lifetime_electron_singleChannel_require" value="<%= lifetime_electron_singleChannel_require %>"/>
			<e:trdefault name="lifetime_electron_singleChannel_veto" value="<%= lifetime_electron_singleChannel_veto %>"/>
			
			<%
		}
	%>	
	<e:trdefault name="feedback" value="feedback"/>
	<e:trdefault name="extraFun_rawFile" value="extraFun_rawFile"/>
	<e:trdefault name="extraFun_type" value="0"/>
	<e:trdefault name="freq_binType" value="0"/>
	<e:trdefault name="freq_col" value="3"/>
	<e:trdefault name="plot_outfile_param" value="plot_param"/>
	<e:trdefault name="plot_outfile_image" value="plot.png"/>
	<e:trdefault name="plot_outfile_image_thumbnail" value="plot_thm.png"/>
	<e:trdefault name="plot_thumbnail_height" value="150"/>
	<e:trdefault name="plot_plot_type" value="3"/>
	<e:trdefault name="plot_xlabel" value="Decay Length (microsec)"/>
	<e:trdefault name="plot_ylabel" value="Number of Decays"/>
	<e:trdefault name="sort_sortKey1" value="2"/>
	<e:trdefault name="sort_sortKey2" value="3"/>
	
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-lifetime-advanced/output.jsp&onError=../analysis-lifetime-advanced/analysis.jsp"/>
	</e:ifAnalysisIsOk>
	<e:ifAnalysisIsNotOk>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose advanced lifetime parameters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="lifetime-study-test" class="data">
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
		<h1>Calculate the advanced lifetime of muons that stop in the detector</h1>
<div id="rationale">This analysis determines the time difference between consecutive photomultiplier tube <a href="javascript:glossary('signal',350)">signals</a>. Two consecutive signals  might be one cosmic ray muon followed by another. Two signals may also come from a muon (the first signal) which then decays into an electron, a neutrino and an anti-neutrino. The electron will create a second signal. The routine displays a histogram of the signal separations that "pass" criteria you set in a the fields below.</div>
<div id="rationale">Gain confidence by running a practice analysis.</div>
<hr>
<table border="0" id="main">
			<tr>
				<td id="center">
					<p>
						<a href="../analysis-lifetime-advanced/tutorial.jsp">Understand the graph</a>
					</p>
					
					<jsp:include page="../data/analyzing-list.jsp"/>
					<p id="other-analyses">
						Analyze the same files in 
						<e:link href="../analysis-flux/analysis.jsp" rawData="${analysis.parameters.rawData}">flux</e:link>&nbsp;or&nbsp;
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
				    <%
				    Integer num_files = (Integer) session.getAttribute("num_files");
				    Integer file_count = 0;
				    if (num_files != null) {
					    file_count = Integer.valueOf(num_files);
				    }
				    if (file_count > 0) {
					%>
						<%@ include file="controls.jsp" %>					    
					<%
				    } else {
				    %>
				    	<p>There are no files available to run this analysis</p>
				    <%
				    }
					%>

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
