<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis status</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-action" class="data">
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

<%
	String id = request.getParameter("id");
	
	if (id == null) {
		id = (String) request.getAttribute("foregroundWorkflowID");
	}

	if (id == null) {
		%> <jsp:forward page="list.jsp"/> <%
	}
	else {
		AnalysisRun run = AnalysisManager.getAnalysisRun(session, id);
		
		if (run == null) {
			%> 
				The specified analysis ID (<%= id %>) is invalid. Please re-run the experiment.
			<%
		}
		else {
			if (request.getParameter("cancel") != null) {
				run.cancel();
				%> <h1>The analysis was canceled</h1> <%
			}
			else if (request.getParameter("background") != null) {
				%> 
					<h1>The analysis has been added to the <a href="list.jsp">analysis list</a> and continues to run</h1>
				<%
			}
		}
	}
%>
		 	</div>
		</div>
	</body>
</html>