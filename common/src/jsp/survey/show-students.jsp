<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>

<%
	Map students; 
	try {
		String id = user.getNewSurveyId().toString();
		request.setAttribute("id", id); 
		String type =  request.getParameter("type"); //pre for pretest and post for posttest.
		if (StringUtils.isBlank(type)) {
		    type = "pre";
		}
		request.setAttribute("type", type);
		students = elab.getSurveyProvider().getStudentSurveyStatus(type, user);
		request.setAttribute("students", students);
	}
	catch (NullPointerException npe) {
		students = null; // Discard data. 
	}
	
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="org.apache.commons.lang.StringUtils"%><html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Show Students</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="show-students">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<c:if test="${empty students}">
						<div id="nav">
							<%@ include file="../include/nav.jsp" %>
						</div>
					</c:if>
				</div>
			</div>
			
			<div id="content">

<h1>Students in research group ${user.name} who need to take the ${type}test.</h1>

<c:choose>
	<c:when test="${not empty  students}">
		<table id="student-test-table">
			<tr>
				<th>Student</th>
			</tr>
			<c:forEach items="${students}" var="i">
				<tr>
					<td>
						${i.key.name}
					</td>
					<td>
						<c:choose>
							<c:when test="${!i.value}">
								<a href="../survey/survey.jsp?studentid=${i.key.id}&type=${type}&id=${id}">Take ${type}test</a>
							</c:when>
							<c:otherwise>
								Completed ${type}test
							</c:otherwise>
						</c:choose>
					</td>
				</tr>
			</c:forEach>
			<tr><td colspan="2"><a href="../home/">Continue onto the e-Lab</a></td></tr>
		</table>
	</c:when>
	<c:otherwise>
		<p>
			No students need to take the test or there is no test for this e-Lab.
		</p>
	</c:otherwise>
</c:choose>
			
			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
	