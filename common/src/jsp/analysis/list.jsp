<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

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
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Analysis list</h1>

<%
	request.setAttribute("runs", AnalysisManager.getAnalysisRuns(elab, user));
%>
<form action="../analysis/remove.jsp">
	<table id="analysis-table">
		<tr>
			<th>
			</th>
			<th>ID</th>
			<th>Analysis</th>
			<th>Start Time</th>
			<th>End Time</th>
			<th>Status</th>
		</tr>
		<c:choose>
			<c:when test="${empty runs}">
				<tr id="nostudies"><td colspan="6"><h3>There are no studies in the list</h3></td></tr>
			</c:when>
			<c:otherwise>
				<c:forEach items="${runs}" var="entry">
					<c:set var="run" value="${entry.value}"/>
					<%
						AnalysisRun run = (AnalysisRun) pageContext.getAttribute("run");
						request.setAttribute("status", AnalysisTools.getStatusString(run));
						request.setAttribute("progress", String.valueOf(run.getProgress() * 99 + 1));
					%>
					<tr>
						<td>
							<input type="checkbox" name="id" value="${run.id}"/>
						</td>
						<td>${run.id}</td>
						<td>
							<a href="status.jsp?id=${run.id}">${run.analysis.type}</a>
						</td>
						<td>
							${run.startTime == null ? 'N/A' : run.startTime}
						</td>
						<td>
							${run.endTime == null ? 'N/A' : run.endTime}
						</td>
						<td>
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
			</c:otherwise>
		</c:choose>
	</table>
	<input type="submit" name="remove" value="Remove Selected" />
</form>
	<%@ include file="async-update.jsp" %>
	<script language="JavaScript" type="text/javascript">
		registerUpdate("status-async.jsp?id=all", update);
							
		function update(data) {
			if (data["ids"] != null) {
				var ids = data["ids"].split(",");
				
				for (i in ids) {
					var id = ids[i];
					
					var status = data["status" + id];
					var progress = data["progress"+ id];
					var name = data["name" + id];
					var startTime = data["startTime" + id];
					var endTime = data["endTime" + id];
					if (!startTime) {
						startTime = "N/A";
					}
					if (!endTime) {
						endTime = "N/A";
					}
					
					if (status != null && progress != null && name != null) {
						var cstatus = status.charAt(0).toUpperCase() + status.substr(1);
						var imgstatus = document.getElementById("imgstatus" + id);
						if (imgstatus == null) {
							var nostudies = document.getElementById("nostudies")
							if (nostudies != null) {
								nostudies.style.visibility="hidden";
								nostudies.style.display="none";
							}
							var table = document.getElementById("analysis-table");
							var row = table.insertRow(table.rows.length);
							row.insertCell(0).innerHTML = "<td>" + id + "</td>";
							row.insertCell(1).innerHTML = "<td><input type=\"checkbox\" name=\"id\" value=\"" + id + "\"/></td>";
							row.insertCell(2).innerHTML = "<a href=\"status.jsp?id=" + id + "\">" + name + "</a>";
							row.insertCell(3).innerHTML = "<td>" + startTime + "</td>";
							row.insertCell(4).innerHTML = "<td id=\"endTime" + id + "\">" + endTime + "</td>";
							
							var hstatus =  "<table border=\"0\"><tr><td>" +
								 "<img id=\"imgstatus" + id + "\" src=\"../graphics/" + status + ".png\"/></td>" +
								 "<td id=\"textstatus" + id + "\">" + cstatus + "</td>";
							
							if (status == "Running") {
								hstatus +="<td><table class=\"list-progress\" id=\"progressbar" + id + "\" " +
								"width=\"100px\" cellpadding=\"0\" cellspacing=\"1\">" +
									"<tr>" + 
									"<td class=\"list-progress-indicator\" id=\"progress" + id + "\" width=\"" + (progress*99 + 1) + "%\">&nbsp;</td>" + 
									"<td>&nbsp;</td>" + 
									"</tr></table></td>";
							}
							hstatus += "</tr></table>";
								
							row.insertCell(5).innerHTML = hstatus;
							var rescel;
							if (status == "Completed") {
								rescell = "<a href=\"status.jsp?id=" + id + "\">See results</a>";
							}
							else {
								rescell = "<a id=\"results" + id + "\" style=\"visibility: hidden; display: none\" href=\"status.jsp?id=" + id + "\">Details</a>";
							}
						}
						else {
							imgstatus.src = "../graphics/" + status + ".png";
							
							var textstatus = document.getElementById("textstatus" + id);
							textstatus.innerHTML = cstatus;
						
							var tdprogress = document.getElementById("progress" + id);
							if (tdprogress != null) {
								tdprogress.width = (progress*99+1) + "%";
							}
							if (status == "Completed") {
								var et = document.getElementById("endTime" + id);
								if (et != null) {
									et.innerHTML = endTime;
								}
								var progressbar = document.getElementById("progressbar" + id);
								if (progressbar != null) {
									progressbar.style.visibility = "hidden";
								}
							}
						}
					}
				}
			}
		}
	</script>
		 	</div>
		</div>
	</body>
</html>