<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.junit.runner.JUnitCore" %>
<%@ page import="org.junit.runner.Result" %>
<%@ page import="org.junit.internal.TextListener" %>
<%@ page import="org.junit.runner.notification.Failure" %>
<%@ page import="gov.fnal.elab.unittest.*" %>
<%@ page import="gov.fnal.elab.cosmic.unittest.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%

	String submit = request.getParameter("submit");
	StringBuilder sb = new StringBuilder();
	
	Result result = JUnitCore.runClasses(BlessRegisterTest.class);
	sb.append("<strong>Testing BlessRegister:</strong><br />");
	sb.append("RunCount: " + result.getRunCount() + "<br />");
	sb.append("RunTime: " + result.getRunTime() + "ms <br />");
	sb.append("FailureCount: " + result.getFailureCount() + "<br />");
	for (Failure failure : result.getFailures()) {
		sb.append(failure.toString() + "<br />");
	}
	sb.append("IgnoreCount: " + result.getIgnoreCount() + "<br />");

  	result = JUnitCore.runClasses(BenchmarkTest.class);
	sb.append("<strong>Testing Benchmark:</strong><br />");
	sb.append("RunCount: " + result.getRunCount() + "<br />");
	sb.append("RunTime: " + result.getRunTime() + "ms <br />");
	sb.append("FailureCount: " + result.getFailureCount() + "<br />");
	for (Failure failure : result.getFailures()) {
		sb.append(failure.toString() + "<br />");
	}
	sb.append("IgnoreCount: " + result.getIgnoreCount() + "<br />");

  	result = JUnitCore.runClasses(BenchmarkProcessTest.class);
	sb.append("<strong>Testing BenchmarkProcess:</strong><br />");
	sb.append("RunCount: " + result.getRunCount() + "<br />");
	sb.append("RunTime: " + result.getRunTime() + "ms <br />");
	sb.append("FailureCount: " + result.getFailureCount() + "<br />");
	for (Failure failure : result.getFailures()) {
		sb.append(failure.toString() + "<br />");
	}
	sb.append("IgnoreCount: " + result.getIgnoreCount() + "<br />");

	
	request.setAttribute("message", sb.toString());

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Benchmark Tests</title>
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
				<div id="msg">${message}</div>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>