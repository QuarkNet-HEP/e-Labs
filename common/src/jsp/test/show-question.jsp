<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.test.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Show Question</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
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
	String type = request.getParameter("type");
	String questionId = request.getParameter("id");
	
	ElabTestQuestion question = elab.getTestProvider().getTestQuestion(type, questionId);
	request.setAttribute("question", question);
%>

<h1>Details for question ${param.id} in ${param.type}</h1>

<strong>${question.text}</strong>
<input type="hidden" name="questionId${question.index}" value="${question.id}"/>
<ol>
	<c:forEach items="${question.answers}" var="answer">
		<li>
			<input type="radio" name="response${question.index}" value="${answer.index}"/>${answer.text}
		</li>
	</c:forEach>
</ol>
<p>
	Correct answer: ${question.correctAnswer.index}. Answer given: ${param.answer}
</p>

			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
	