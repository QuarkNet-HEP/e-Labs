<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.test.*" %>

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

<h1>Results for ${param.type} for students of ${user.name}</h1>

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

<table id="test-results-table" class="shaded">
	<tr>
		<th>Student Name</th>
		<th>Correct/Total</th>
		<th>Answers</th>
	</tr>
	<c:forEach items="${results}" var="result">
		<tr>
			<td>${result.key.name}</td>
			<%
				List l = (List) ((Map.Entry) pageContext.getAttribute("result")).getValue();
				
				if (l.isEmpty()) {
				    request.setAttribute("correct", "N/A");
				}
				else {
				    int correct = 0;
					Iterator i = l.iterator();
					while (i.hasNext()) {
					    ElabTestQuestion q = (ElabTestQuestion) i.next();
				    	if (q.isCorrectAnswerGiven()) {
				    	    correct++;
				    	}
					}
					request.setAttribute("correct", correct + "/" + l.size());
				}
			%>
			<td>${correct}</td>
			<td>
				<c:choose>
					<c:when test="${param.color == 'no'}">
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}+</a>
								</c:when>
								<c:otherwise>
									<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}-</a>
								</c:otherwise>
							</c:choose>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<c:forEach items="${result.value}" var="question">
							<c:choose>
								<c:when test="${question.correctAnswerGiven}">
									<span style="background-color: #60ff40;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}</a>
									</span>
								</c:when>
								<c:otherwise>
									<span style="background-color: #ffa060;">
										<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.index}">Q${question.id}</a>
									</span>
								</c:otherwise>
							</c:choose>
							&nbsp;
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
			
	