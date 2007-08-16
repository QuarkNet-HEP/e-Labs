<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Test Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="test-results">
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

<%
	String type = request.getParameter("type");
	Map results = elab.getTestProvider().getStudentResultsForTeacher(type, user);
	request.setAttribute("results", results);
%>

<h1>Results for ${param.type}test for students of ${user.name}</h1>

<table id="test-results-table">
	<tr>
		<th>Student Name</th>
		<th>Total Correct</th>
	</tr>
	<c:forEach items="${results}" var="result">
		<tr>
			<td>${result.key.name}</td>
			<td>
				<c:choose>
					<c:when test="${param.color == 'no'}">
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.answerGiven.id}">Q${question.id}+</a>&nbsp;
								</c:when>
								<c:otherwise>
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.answerGiven.id}">Q${question.id}-</a>&nbsp;
								</c:otherwise>
							</c:choose>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<span style="background-color: green;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.answerGiven.id}">Q${question.id}</a>
									</span>
								</c:when>
								<c:otherwise>
									<span style="background-color: red;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.answerGiven.id}">Q${question.id}</a>
									</span>
								</c:otherwise>
							</c:choose>
						</c:forEach>
					</c:otherwise>
				</c:choose>
			</td>
		</tr>
	</c:forEach>
</table>

<c:if test="${param.color != 'no'}">
	<a href="results.jsp?type=${param.type}&color=no" target="_">Printable version</a> (opens in new window)
</c:if>


			
			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
	