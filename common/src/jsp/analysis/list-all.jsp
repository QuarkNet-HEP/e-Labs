<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis List</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<%
	request.setAttribute("users", AnalysisManager.getAnalysisRuns(elab));
%>

<table id="analysis-table">
	<tr>
		<th>User</th>
		<th>ID</th>
		<th>Analysis</th>
		<th>Run Mode</th>
		<th>Start Time</th>
		<th>End Time</th>
		<th>Time (Actual/Est.)</th>
		<th>Status</th>
	</tr>
	<c:choose>
		<c:when test="${empty users}">
			<tr id="nostudies"><td colspan="8"><h3>There are no analyses</h3></td></tr>
		</c:when>
		<c:otherwise>
			<fmt:setTimeZone value="UTC"/>
			<c:forEach items="${users}" var="uentry">
				<c:forEach items="${uentry.value}" var="entry">
					<c:set var="run" value="${entry.value}"/>
					<%
						AnalysisRun run = (AnalysisRun) pageContext.getAttribute("run");
						request.setAttribute("status", AnalysisTools.getStatusString(run));
						request.setAttribute("progress", String.valueOf(run.getProgress() * 99 + 1));
					%>
					<tr>
						<td>${uentry.key}</td>
						<td>${run.id}</td>
						<td>
							<a href="status.jsp?id=${run.id}&user=${uentry.key}">${run.analysis.name}</a>
						</td>
						<td>
							${run.attributes.runMode}
						</td>
						<td>
							<c:choose>
								<c:when test="${run.startTime == null}">
									N/A
								</c:when>
								<c:otherwise>
									<fmt:formatDate pattern="MM/dd/yy'&nbsp;'HH:mm:ss" value="${run.startTime}"/>
								</c:otherwise>
							</c:choose>
						</td>
						<td>
							<c:choose>
								<c:when test="${run.endTime == null}">
									N/A
								</c:when>
								<c:otherwise>
									<fmt:formatDate pattern="MM/dd/yy'&nbsp;'HH:mm:ss" value="${run.endTime}"/>
								</c:otherwise>
							</c:choose>
						</td>
						<td align="center">
							${run.formattedRunTime}&nbsp;/&nbsp;${run.formattedEstimatedRunTime}
						</td>
						<td width="148px">
							<table border="0">
								<tr>
									<td>
										<img id="imgstatus${run.id}" src="../graphics/${status}.png"/>
									</td>
									<td id="textstatus${run.id}">${status}</td>
									<c:if test="${status == 'Running'}">
										<td>
											<table class="list-progress" id="progressbar${run.id}" cellpadding="0" cellspacing="1">
												<tr>
													<td class="list-progress-indicator" id="progress${run.id}" width="${progress}%">&nbsp;</td>
													<td>&nbsp;</td>
												</tr>
											</table>
										</td>
									</c:if>
								</tr>
							</table>
						</td>
					</tr>
				</c:forEach>
			</c:forEach>
		</c:otherwise>
	</c:choose>
</table>
		 	</div>
		</div>
	</body>
</html>