<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.statistics.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Statistics</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/admin.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="statistics-summary" class="admin">
	<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-admin.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<jsp:useBean id="stats" class="gov.fnal.elab.statistics.Statistics"/>
<jsp:setProperty name="stats" property="elab" value="${elab}"/>
<jsp:useBean id="astats" class="gov.fnal.elab.statistics.AnalysisStats"/>

			
<h1>User statistics</h1>

<table border="0" id="main">
	<tr>
		<td>
<h2>Overall statistics</h2>

<table border="0" cellspacing="10" class="lefty">
	<tr>
		<th width="160px">Teacher accounts</th>
		<jsp:setProperty name="stats" property="role" value="teacher"/>
		<td>${stats.groupCount}</td>
	</tr>
	<tr>
		<th>User accounts (RGs)</th>
		<jsp:setProperty name="stats" property="role" value="user"/>
		<td>${stats.groupCount}</td>
	</tr>
	<tr>
		<th>Schools</th>
		<td>${stats.schoolCount}</td>
	</tr>
	<tr>
		<th>Pre-tests taken</th>
		<jsp:setProperty name="stats" property="type" value="pre"/>
		<td>${stats.testsTaken}</td>
	</tr>
	<tr>
		<th>Post-tests taken</th>
		<jsp:setProperty name="stats" property="type" value="post"/>
		<td>${stats.schoolCount}</td>
	</tr>
	<tr>
		<th><a href="/usage-apache">Site statistics</a></th>
		<td>-</td>
	</tr>
</table>

		</td>
	</tr>
</table>

<h2>Periodic</h2>
<table border="0" cellspacing="10" class="lefty">
	<tr>
		<th width="160px"></th>
		<th width="100px">Ever</th>
		<th width="100px">Last 365 days</th>
		<th width="100px">Last 31 days</th>
	</tr>
	<tr>
		<th><a href="login-charts.jsp">Log-ins</a></th>
		<jsp:setProperty name="stats" property="span" value="999999"/>
		<td>${stats.logIns}</td>
		<jsp:setProperty name="stats" property="span" value="365"/>
		<td>${stats.logIns}</td>
		<jsp:setProperty name="stats" property="span" value="31"/>
		<td>${stats.logIns}</td>
	</tr>
	<tr>
		<th><a href="analysis-charts.jsp">Analysis runs</a></th>
		<jsp:setProperty name="astats" property="span" value="999999"/>
		<td>${astats.analysisRuns}</td>
		<jsp:setProperty name="astats" property="span" value="365"/>
		<td>${astats.analysisRuns}</td>
		<jsp:setProperty name="astats" property="span" value="31"/>
		<td>${astats.analysisRuns}</td>
	</tr>
	<% out.flush(); %>
	<tr>
		<th><a href="data-charts.jsp?type=split">Data uploaded</a></th>
		<jsp:setProperty name="stats" property="type" value="split"/>
		<jsp:setProperty name="stats" property="span" value="999999"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="365"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="31"/>
		<td>${stats.VDCEntryCount}</td>
	</tr>
	<% out.flush(); %>
	<tr>
		<th><a href="data-charts.jsp?type=poster">Posters created</a></th>
		<jsp:setProperty name="stats" property="type" value="poster"/>
		<jsp:setProperty name="stats" property="span" value="999999"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="365"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="31"/>
		<td>${stats.VDCEntryCount}</td>
	</tr>
	<% out.flush(); %>
	<tr>
		<th><a href="data-charts.jsp?type=plot">Plots created</a></th>
		<jsp:setProperty name="stats" property="type" value="plot"/>
		<jsp:setProperty name="stats" property="span" value="999999"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="365"/>
		<td>${stats.VDCEntryCount}</td>
		<jsp:setProperty name="stats" property="span" value="31"/>
		<td>${stats.VDCEntryCount}</td>
	</tr>
</table>

			</div>
		</div>
	</body>
</html>
