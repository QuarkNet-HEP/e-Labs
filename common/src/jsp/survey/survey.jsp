<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.survey.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Test</title>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/test.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
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
	int id = -1;
	String type; 
	
	try { // Hardcoded surveys are default 
		id = Integer.parseInt(request.getParameter("id"));
	}
	catch (NumberFormatException nfe) {
		try {
			if (user.getNewSurveyId() != null) { // Check user-defined test 
				id = user.getNewSurveyId().intValue();
			}
			else {
				id = Integer.parseInt(elab.getProperty(elab.getName() + ".newsurvey"));
			}
		}
		catch(Exception exn) {
			throw new ElabJspException("Missing test id"); 
		}
	}
	type = request.getParameter("type");
	if (type == null || !(type.equalsIgnoreCase("pre") || type.equalsIgnoreCase("post"))) {
	    throw new ElabJspException("Missing or malformed test type");
	}
	ElabSurvey survey = elab.getSurveyProvider().getSurvey(id);
	request.setAttribute("survey", survey);
	
	boolean valid = survey != null && survey.getQuestionCount() > 0; 
	request.setAttribute("valid", valid);
	
%>
			

<c:choose>
	<c:when test="${valid}">
		<h1>Answer the following questions and click <b>Record Answers</b> to take the ${survey.name}.</h1>
		<p>
			<strong>Don't guess!!</strong> "Do not know" is a perfectly good answer. 
			You will learn the answers to questions like these in your investigation.
		</p>
		<form name="test-form" method="post" action="record-answers.jsp">
			<ol id="test">
				<c:forEach items="${survey.questions}" var="question">
					<li>
						<strong>${question.text}</strong>
						<ol type="a">
							<c:forEach items="${question.answers}" var="answer">
								<li>
									<input type="radio" name="response${question.id}" value="${answer.id}"/>${answer.text}
								</li>
							</c:forEach>
						</ol>
					 </li>
				</c:forEach>
			</ol>
			<c:if test="${param.studentid != null && param.studentid != '0'}">
				<p align="center"> 
					<input type="hidden" name="type" value="${param.type}"/>
					<input type="hidden" name="testId" value="${param.id}" /> 
					<input type="hidden" name="studentid" value="${param.studentid}"/>
					<input type="hidden" name="count" value="${survey.questionCount}"/>
		    		<input type="submit" name="Submit" value="Record Answers"/>
			    	<input type="reset" name="Reset" value="Reset Answers"/>
				</p>
			</c:if>
		</form>
	</c:when>
	<c:otherwise>
		No test found. 
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
			
