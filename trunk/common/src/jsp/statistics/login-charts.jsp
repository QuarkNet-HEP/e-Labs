<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.statistics.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Statistics</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/admin.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
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
<c:set var="start" value="${param.start != null ? param.start : '02/01/2005'}"/>
<jsp:useBean id="nowd" class="java.util.Date"/>
<c:set var="now">
	<fmt:formatDate pattern="MM/dd/yyyy" value="${nowd}"/>
</c:set>
<c:set var="end" value="${param.end != null ? param.end : now}"/>

<jsp:useBean id="stats" class="gov.fnal.elab.statistics.Statistics"/>
<jsp:setProperty name="stats" property="elab" value="${elab}"/>
<jsp:setProperty name="stats" property="start" value="${start}"/>
<jsp:setProperty name="stats" property="end" value="${end}"/>
<c:set var="yearly" value="${stats.yearlyLoginCounts}"/> 

<h1>Logins to ${elab.name} elab from ${start} to ${end}</h1>

<h2>Interval </h2>
<table border="0" width="100%">
	<tr>
		<td>
<form>
	<input type="text" name="start" maxlength="10" size="10" value="${start}" />
	to
	<input type="text" name="end" maxlength="10" size="10" value="${end}" />
	<input type="hidden" name="type" value="${type}" />
	<input type="submit" value="Update" />
</form>
		</td>
		<td style="text-align: right;">
			<jsp:include page="preset-intervals.jsp">
				<jsp:param name="extra" value="&type=${type}"/>
			</jsp:include>
		</td>
	</tr>
</table>

<table border="0" id="main">
	<tr>
		<td id="left">

<h2>Per year</h2>


<table border="0" id="yearly" cellspacing="10px" class="lefty small">
	<tr>
		<th width="100px" style="vertical-align: bottom;">
			<div style="padding: 2px; background-color: #c0ff90;">Guest log-ins</div>
			<div style="padding: 2px; background-color: #a0ff00;">Non-guest log-ins</div>
		</th>
		<c:forEach var="e" items="${yearly}">
			<td style="vertical-align: bottom;">
				${e.count}
				<table border="0" cellpadding="0" cellspacing="0" 
					style="background-color: #a0ff00; width: 40px; height: ${e.relativeSize * 100}px;">
					<tr style="background-color: #c0ff90;" height="${e.guestPercentage}%"><td></td></tr>
					<tr><td></td></tr>
				</table>
			</td>
		</c:forEach>
	</tr>
	<tr>
		<th>Year</th>
		<c:forEach var="e" items="${yearly}">
			<td>${e.key}</td>
		</c:forEach>
	</tr> 
</table>

<h2>Most active users</h2>

<table border="0" id="active" class="lefty small">
	<tr>
		<th>Group name</th>
		<th colspan="2">
			Log-ins
		</th>
	</tr>
	<c:forEach var="e" items="${stats.mostActiveLoginUsers}" varStatus="li">
		<tr style="background-color: ${li.count % 2 == 0 ? '#ffffff' : '#e0e0e0' }">
			<td>${e.key}</td>
			<td>${e.count}</td>
			<td style="vertical-align: middle; text-align: left;">
				<div style="background-color: #40a0ff; height: 10px; width: ${e.relativeSize * 200}px; margin-left: 0px;"></div>
			</td>
		</tr>
	</c:forEach>
</table>

		</td>
		<td id="right">

<h2>Per month</h2>
<table border="0" id="monthly" class="lefty small">
	<tr>
		<th>Month/Year</th>
		<th>
			Log-ins
		</th>
		<th>
			<span style="padding: 2px; background-color: #ffaf00;">Non-guest log-ins</span>
			<span style="padding: 2px; background-color: #ffdfb0;">Guest log-ins</span>
		</th>
	</tr>
	<c:forEach var="e" items="${stats.monthlyLoginCounts}" varStatus="li">
		<tr style="background-color: ${li.count % 2 == 0 ? '#ffffff' : '#e0e0e0' }">
			<td>${e.key}</td>
			<td>${e.count}</td>
			<td style="vertical-align: middle; text-align: left;">
				<table border="0" cellpadding="0" cellspacing="0"
					style="background-color: #ffaf00; width: ${e.relativeSize * 200}px; margin-left: 0px;">
					<tr>
						<td height="10px" width="${100 - e.guestPercentage}%"></td>
						<td style="background-color: #ffdfb0;"></td>
					</tr>
				</table>
			</td>
		</tr>
	</c:forEach> 
</table>
		</td>
	</tr>
</table>

			</div>
		</div>
	</body>
</html>
