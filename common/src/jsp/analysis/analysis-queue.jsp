<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.concurrent.*" %>
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
Thread queueThread = AnalysisPriorityBlockingQueue.getInstance().getThread();
StringBuilder sb = new StringBuilder();
Map<Thread, StackTraceElement[]> st = queueThread.getAllStackTraces();

if (queueThread != null) {
	sb.append("Thread Name: " + queueThread.getName() + "<br />");
	sb.append("Thread State: " + queueThread.getState().toString() + "<br />");
	sb.append("Thread Alive: " + String.valueOf(queueThread.isAlive()) + "<br />");
	sb.append("Thread Interrupted: " + String.valueOf(queueThread.isInterrupted()) + "<br />");
	sb.append("Thread Priority: " + String.valueOf(queueThread.getPriority()) + "<br />");
	sb.append("Switch: " + String.valueOf(AnalysisPriorityBlockingQueue.getInstance().getSwitch()) + "<br />");
	sb.append("Exceptions: " + AnalysisPriorityBlockingQueue.getInstance().getExceptions() + "<br />");

}

AnalysisRun local = AnalysisPriorityBlockingQueue.getInstance().getCurrent("local");
AnalysisRun nodes = AnalysisPriorityBlockingQueue.getInstance().getCurrent("nodes");
AnalysisRun mixed = AnalysisPriorityBlockingQueue.getInstance().getCurrent("mixed");

PriorityBlockingQueue<AnalysisRun> arLocal = AnalysisPriorityBlockingQueue.getInstance().getQueueLocal();
PriorityBlockingQueue<AnalysisRun> arNodes = AnalysisPriorityBlockingQueue.getInstance().getQueueNodes();
PriorityBlockingQueue<AnalysisRun> arMixed = AnalysisPriorityBlockingQueue.getInstance().getQueueMixed();
request.setAttribute("local", local);
request.setAttribute("nodes", nodes);
request.setAttribute("mixed", mixed);

request.setAttribute("arLocal", arLocal);
request.setAttribute("arNodes", arNodes);
request.setAttribute("arMixed", arMixed);
request.setAttribute("threadDetails", sb.toString());
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
			<h1>Analysis Queue Information</h1>
			<h2>Analysis Queue Thread Details</h2>
			<p>${threadDetails }</p>
			<h2>List of analyses waiting in the queue (local)</h2>
			<c:if test="${arLocal != null }">
				<table id="analysis-table">
					<tr>
						<th>Id</th>
						<th>Owner</th>
						<th>Type</th>
						<th>Time Queued</th>
					</tr>
					<c:forEach items="${arLocal}" var="arLocal">
						<tr>
							<td>${arLocal.id }</td>
							<td>${arLocal.attributes.owner }</td>
							<td>${arLocal.attributes.type }</td>
							<td>${arLocal.attributes.queuedAt }</td>
						</tr>
					</c:forEach>
				</table>
			</c:if>					
			<h2>List of analyses waiting in the queue (i2u2)</h2>
			<c:if test="${arNodes != null }">
				<table id="analysis-table">
					<tr>
						<th>Id</th>
						<th>Owner</th>
						<th>Type</th>
						<th>Time Queued</th>
					</tr>
					<c:forEach items="${arNodes}" var="arNodes">
						<tr>
							<td>${arNodes.id }</td>
							<td>${arNodes.attributes.owner }</td>
							<td>${arNodes.attributes.type }</td>
							<td>${arNodes.attributes.queuedAt }</td>
						</tr>
					</c:forEach>
				</table>
			</c:if>					
			<h2>List of analyses waiting in the queue (mixed)</h2>
			<c:if test="${arMixed != null }">
				<table id="analysis-table">
					<tr>
						<th>Id</th>
						<th>Owner</th>
						<th>Type</th>
						<th>Time Queued</th>
					</tr>
					<c:forEach items="${arMixed}" var="arMixed">
						<tr>
							<td>${arMixed.id }</td>
							<td>${arMixed.attributes.owner }</td>
							<td>${arMixed.attributes.type }</td>
							<td>${arMixed.attributes.queuedAt }</td>
						</tr>
					</c:forEach>
				</table>
			</c:if>					
		 	</div>
		</div>
	</body>
</html>