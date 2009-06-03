<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ include file="../analysis/results.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
<%@ page import="java.io.*" %>

<%
	
%>
	
<e:analysis name="analysis" type="I2U2.Cosmic::EventPlot">
	<%
		ElabAnalysis shower = results.getAnalysis();
		
		String eventNum = request.getParameter("eventNum");
		
		File ecFile = new File(results.getOutputDir(), (String) shower.getParameter("eventCandidates"));
		String ecPath = ecFile.getAbsolutePath();
		
		if (eventNum == null) {
			//find the "most interesting" event (one with highest event coincidence)
			BufferedReader br = new BufferedReader(new FileReader(ecFile));
			String line = br.readLine();
			
			while (line != null) {
				if (line.matches("^.*#.*")) {
	            	continue; //ignore comments in the file
				}
				String arr[] = line.split("\\s");
				eventNum = arr[0];
				break;
			}
		}
		//this is not right. Well, the whole two runs in one concept isn't. Anyway,
		//it does not deal properly with concurrency. If two users focus
		//on different events of the same shower run, and they both save
		//plots, one will be incorrect
		shower.setParameter("eventNum", eventNum);
		request.setAttribute("shower", shower);
	%>
		
		<e:trdefault name="eventNum" value="<%= eventNum %>"/>
		<e:trdefault name="eventCandidates" value="<%= ecPath %>"/>
	    <e:trdefault name="geoDir" value="${shower.parameters.geoDir}"/>
	    <e:trdefault name="geoFiles" value="${shower.parameters.geoFiles}"/>
	    <e:trdefault name="extraFun_out" value="${shower.parameters.extraFun_out}"/>
	    <e:trdefault name="plot_caption" value="${shower.parameters.plot_caption}"/>
	    <e:trdefault name="plot_title" value="${shower.parameters.plot_title}"/>
	    <e:trdefault name="plot_highX" value="${shower.parameters.plot_highX}"/>
	    <e:trdefault name="plot_highY" value="${shower.parameters.plot_highY}"/>
	    <e:trdefault name="plot_highZ" value="${shower.parameters.plot_highZ}"/>
	    <e:trdefault name="plot_lowX" value="${shower.parameters.plot_lowX}"/>
	    <e:trdefault name="plot_lowY" value="${shower.parameters.plot_lowY}"/>
	    <e:trdefault name="plot_lowZ" value="${shower.parameters.plot_lowZ}"/>
	    <e:trdefault name="plot_size" value="${shower.parameters.plot_size}"/>
	    <e:trdefault name="plot_thumbnail_height" value="${shower.parameters.plot_thumbnail_height}"/>
	    <e:trdefault name="plot_outfile_image_thumbnail" value="${shower.parameters.plot_outfile_image_thumbnail}"/>
	    <e:trdefault name="plot_outfile_image" value="${shower.parameters.plot_outfile_image}"/>
	    <e:trdefault name="plot_outfile_param" value="${shower.parameters.plot_outfile_param}"/>
	    <e:trdefault name="plot_xlabel" value="${shower.parameters.plot_xlabel}"/>
		<e:trdefault name="plot_ylabel" value="${shower.parameters.plot_ylabel}"/>
		<e:trdefault name="plot_zlabel" value="${shower.parameters.plot_zlabel}"/>
	    <e:trdefault name="plot_plot_type" value="${shower.parameters.plot_plot_type}"/>
	    <e:trdefault name="zeroZeroZeroID" value="${shower.parameters.zeroZeroZeroID}"/>
	<e:ifAnalysisIsOk>
		<jsp:include page="../analysis/start.jsp?continuation=../analysis-shower/output.jsp?showerId=${param.id}&onError=../analysis-shower/analysis.jsp"/>
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

		<c:if test="${!(empty analysis.invalidParameters)}">
	    	<h2>Error. Missing parameters:</h2>
	        <ul class="errors">
	            <c:forEach var="f" items="${analysis.invalidParameters}">
	                <li><c:out value="${f}"/></li>
	            </c:forEach>
	        </ul>
	    </c:if>
	    
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
