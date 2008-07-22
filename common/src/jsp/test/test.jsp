<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.test.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Test</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/test.css"/>
	</head>

	<body id="test">
		<!-- entire page container -->
		<div id="container">
			<!-- only show header if included from teacher pages -->
			<c:if test="${param.studentid == '0'}">
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
						<div id="nav">
							<%@ include file="../include/nav-teacher.jsp" %>
						</div>
					</div>
				</div>
			</c:if>
			
			<div id="content">
			
<%
	String type = request.getParameter("type");
	if (type == null) {
	    throw new ElabJspException("Missing test type");
	}
	ElabTest test = elab.getTestProvider().getTest(type);
	request.setAttribute("test", test);
%>
			
<h1>Answer the following questions and click <b>Record Answers</b> to take ${test.type}.</h1>

<p>
	<strong>Don't guess!!</strong> "Do not know" is a perfectly good answer. 
	You will learn the answers to questions like these in your investigation.
</p>

<form name="test-form" method="post" action="record-answers.jsp">
	<ol id="test">
		<c:forEach items="${test.questions}" var="question">
			<li>
				<strong>${question.text}</strong>
				<input type="hidden" name="questionId${question.index}" value="${question.id}"/>
				<ul>
					<c:forEach items="${question.answers}" var="answer">
						<li>
							<input type="radio" name="response${question.index}" value="${answer.index}"/>${answer.text}
						</li>
					</c:forEach>
				</ul>
			 </li>
		</c:forEach>
	</ol>
	<c:if test="${param.studentid != null && param.studentid != '0'}">
		<p align="center"> 
			<input type="hidden" name="type" value="${test.type}"/>
			<input type="hidden" name="studentid" value="${param.studentid}"/>
			<input type="hidden" name="count" value="${test.questionCount}"/>
    		<input type="submit" name="Submit" value="Record Answers"/>
	    	<input type="reset" name="Reset" value="Reset Answers"/>
		</p>
	</c:if>
</form>
			
			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
			
