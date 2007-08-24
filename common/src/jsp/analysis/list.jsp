<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
	request.setAttribute("runs", AnalysisManager.getAnalysisRuns(session));
%>

	<table id="analysis-table">
		<tr>
			<th>ID</th>
			<th>Type</th>
			<th>Status</th>
			<th>Results</th>
			<th>Continuation</th>
		</tr>
		<c:choose>
			<c:when test="${empty runs}">
				<tr id="nostudies"><td colspan="5"><h2>There are no studies in this session</h2></td></tr>
			</c:when>
			<c:otherwise>
				<c:forEach items="${runs}" var="entry">
					<c:set var="run" value="${entry.value}"/>
					<%
						AnalysisRun run = (AnalysisRun) pageContext.getAttribute("run");
						request.setAttribute("status", AnalysisTools.getStatusString(run));
						request.setAttribute("progress", String.valueOf(AnalysisTools.getProgress(run) * 99 + 1));
					%>
					<tr>
						<td>${run.id}</td>
						<td>${run.analysis.type}</td>
						<td>
							<table border="0">
								<tr>
									<td>
										<img id="imgstatus${run.id}" src="../graphics/${status}.png"/>
									</td>
									<td id="textstatus${run.id}">${status}</td>
									<c:if test="${status == 'Running'}">
										<td>
											<table id="progressbar${run.id}" style="border: solid black thin;" 
												width="100px" cellpadding="0" cellspacing="1">
												<tr>
													<td id="progress${run.id}" width="${progress}%" bgcolor="#5d89d9">&nbsp;</td>
													<td>&nbsp;</td>
												</tr>
											</table>
										</td>
									</c:if>
								</tr>
							</table>
						</td>
						<td>
							<c:choose>
								<c:when test="${status == 'Completed'}">
									<a href="status.jsp?id=${run.id}">See results</a>
								</c:when>
								<c:otherwise>
									<a id="results${run.id}" style="visibility: hidden; display: none" 
										href="status.jsp?id=${run.id}">See results</a>
								</c:otherwise>
							</c:choose>
						</td>
						<td>
							<c:if test="${status == 'Completed'}">
								${run.attributes.continuation}
							</c:if>
						</td>
					</tr>
				</c:forEach>
			</c:otherwise>
		</c:choose>
	</table>
	<%@ include file="async-update.jsp" %>
	<script language="JavaScript">
		registerUpdate("status-async.jsp?id=all", update);
							
		function update(data) {
			if (data["ids"] != null) {
				var ids = data["ids"].split(",");
				
				for (i in ids) {
					var id = ids[i];
					
					var status = data["status" + id];
					var progress = data["progress"+ id];
					var name = data["name" + id];
					
					if (status != null && progress != null && name != null) {
						var cstatus = status.charAt(0).toUpperCase() + status.substr(1);
						var imgstatus = document.getElementById("imgstatus" + id);
						if (imgstatus == null) {
							var nostudies = document.getElementById("nostudies")
							if (nostudies != null) {
								nostudies.style.visibility="hidden";
								nostudies.style.display="none";
							}
							var table = document.getElementById("wftable");
							var row = table.insertRow(table.rows.length);
							row.insertCell(0).innerHTML = "<td>" + id + "</td>";
							row.insertCell(1).innerHTML = name;
							var hstatus =  "<table border=\"0\"><tr><td>" +
								 "<img id=\"imgstatus" + id + "\" src=\"../graphics/" + status + ".png\"/></td>" +
								 "<td id=\"textstatus" + id + "\">" + cstatus + "</td>";
							
							if (status == "Running") {
								hstatus +="<td><table id=\"progressbar" + id + "\" style=\"border: solid black thin;\"" +
								"width=\"100px\" cellpadding=\"0\" cellspacing=\"1\">" +
									"<tr>" + 
									"<td id=\"progress" + id + "\" width=\"" + (progress*99 + 1) + "%\" bgcolor=\"#5d89d9\">&nbsp;</td>" + 
									"<td>&nbsp;</td>" + 
									"</tr></table></td>";
							}
							hstatus += "</tr></table>";
								
							row.insertCell(2).innerHTML = hstatus;
							var rescel;
							if (status == "Completed") {
								rescell = "<a href=\"status.jsp?id=" + id + "\">See results</a>";
							}
							else {
								rescell = "<a id=\"results" + id + "\" style=\"visibility: hidden; display: none\" href=\"status.jsp?id=" + id + "\">Details</a>";
							}
							row.insertCell(3).innerHTML = rescell;
						
							row.insertCell(4).innerHTML = "&nbsp;";
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
								var results = document.getElementById("results" + id);
								if (results != null) {
									results.style.visibility="visible";
									results.style.display="";
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