<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.survey.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Test Results</title>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/style2.css"/>
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
	//this is the group id of the teacher group, not the teacher id
	String id = request.getParameter("id");
	if (id == null) {
		throw new ElabJspException("Missing group id for teacher");
	}
	try {
		ElabGroup teacher = elab.getUserManagementProvider().getGroupById(id);
		Map results = elab.getSurveyProvider().getStudentResultsForTeacher(type, teacher);
		String testName = elab.getSurveyProvider().getSurvey(teacher.getNewSurveyId().intValue()).getName();
		request.setAttribute("results", results);
		request.setAttribute("testName", testName);
		request.setAttribute("teacher", teacher);
		request.setAttribute("data", true);
	}
	catch (NullPointerException npe) {
		request.setAttribute("data", false); 
	}
	
%>

<c:choose>
	<c:when test="${data}"> 
		<h1>Student ${param.type}test results for the ${testName}</h1>
	
		<p>
			Students' answers are listed under each question. Click on the answer to see the 
			question and answers.
			<c:choose>
				<c:when test="${param.color == 'no'}">
					Correct answers are marked with a plus sign (+); incorrect
					answers are marked with a minus sign (-).
				</c:when>
				<c:otherwise>
			 		Correct answers are displayed in green; incorrect answers 
					are displayed in red.
				</c:otherwise>
			</c:choose>
			 The black and white version uses + and - signs so that correct 
			 answers can be seen when printed on a black and white printer.
		</p>
		
		<%@ include file="../survey/results-table.jsp" %>
		
		<c:if test="${param.color != 'no'}">
			<a href="results-for-teacher.jsp?id=${param.id}&type=${param.type}&color=no" target="_">Printable version</a> (opens in new window)
		</c:if>
	</c:when>
	<c:otherwise>
		<h1>No data available</h1>
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
			
	