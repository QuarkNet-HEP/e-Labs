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


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Shower Study Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower-study-output" class="data, analysis-output">
		<!-- entire page container -->
		<div id="container">
<%
	ElabAnalysis analysis = results.getAnalysis();
	request.setAttribute("analysis", analysis);
	
	String showerId = request.getParameter("showerId");
	AnalysisRun showerResults = AnalysisManager.getAnalysisRun(elab, user, showerId);
	request.setAttribute("showerResults", showerResults);

    //EPeronja-03/15/2013: Bug466- Save Event Candidates file with saved plot
	String eventDir = request.getParameter("eventDir");
	request.setAttribute("eventDir", eventDir);
	
%>

<img src="${results.outputDirURL}/plot.png" />

<p>
	Show <e:popup href="../analysis/show-dir.jsp?id=${results.id}" target="analysisdir" 
		width="800" height="600" toolbar="true">analysis directory</e:popup>
</p>

<%@ include file="events-table.jspf" %>

<%@ include file="save-form.jspf" %>


			</div>
			<!-- end content -->	
		</div>
		<!-- end container -->
	</body>
</html>
