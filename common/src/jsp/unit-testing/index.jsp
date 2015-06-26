<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.junit.runner.JUnitCore" %>
<%@ page import="org.junit.runner.Result" %>
<%@ page import="org.junit.runner.notification.Failure" %>
<%@ page import="gov.fnal.elab.unittest.*" %>
<%@ page import="gov.fnal.elab.cosmic.unittest.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Unit Testing</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="unit-testing" class="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			<div id="content">
				<table>
					<tr>
						<td><a href="benchmark-test.jsp">Benchmark Tests</a></td>
					</tr>
					<tr>
						<td><a href="notifications-test.jsp">Notifications Tests</a></td>
					</tr>
					<tr>
						<td><a href="session-test.jsp">Session Tests</a></td>
					</tr>
					<tr>
						<td><a href="logbook-test.jsp">Logbook Tests</a></td>
					</tr>
					<tr>
						<td><a href="timeofflight-test.jsp">Time Of Flight Tests</a></td>
					</tr>
					<tr>
						<td><a href="shower-test.jsp">Shower Tests</a></td>
					</tr>										
					<tr>
						<td><a href="addgroup-test.jsp">Add Group Tests</a></td>
					</tr>										
				</table>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>