<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.survey.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="org.apache.commons.lang.StringUtils"%><html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Show Question</title>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="show-question">
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
	int questionId = Integer.parseInt(request.getParameter("id"));
	int responseId = Integer.parseInt(request.getParameter("answer"));
	int surveyId; 
	
	try { 
		if (StringUtils.isNotBlank(request.getParameter("surveyId"))) {
			surveyId = Integer.parseInt(request.getParameter("surveyId"));
		}
		else {
			surveyId = user.getNewSurveyId().intValue(); 
		}
	}
	catch (Exception e) {
		throw new ElabJspException(e);
	}
	
	ElabSurveyQuestion question = elab.getSurveyProvider().getSurveyQuestion(surveyId, questionId, responseId);
	request.setAttribute("question", question);
%>

<h1>Details for question ${question.number} in ${param.type}test</h1>

<strong>${question.text}</strong>
<input type="hidden" name="questionId${question.number}" value="${question.id}"/>
<ol type="a">
	<c:forEach items="${question.answers}" var="answer">
		<li>
			${answer.text}
		</li>
	</c:forEach>
</ol>
<p>
	Correct answer: ${question.correctAnswer.text}.
</p>
<p>
	Answer given: ${question.givenAnswer.text}.
</p>

			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
	