<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.analysis.queue.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.vds.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.swift.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.shell.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
			
<%
List<AnalysisRun> ar = AnalysisQueue.getInstance().getQueue();
request.setAttribute("ar", ar);
%>			

<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis Queue</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-queue" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
	
			<div id="content">
			<h1>List of analyses waiting in the queue</h1>
			<c:if test="${ar != null }">
				<table id="analysis-table">
					<tr>
						<th>Id</th>
						<th>Owner</th>
						<th>Type</th>
						<th>RunMode</th>
						<th>Time Queued</th>
					</tr>
					<c:forEach items="${ar}" var="ar">
						<tr>
							<td>${ar.id }</td>
							<td>${ar.attributes.owner }</td>
							<td>${ar.attributes.type }</td>
							<td>${ar.attributes.runMode }</td>
							<td>${ar.attributes.queuedAt }</td>
						</tr>
					</c:forEach>
				</table>
			</c:if>					
		 	</div>
		</div>
	</body>
</html>