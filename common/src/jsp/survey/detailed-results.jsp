<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.survey.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Test Results</title>
		<%-- 
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		--%>
	</head>

	<body id="test-results">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
				<%--
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				--%>
				</div>
			</div>
			<div id="content">
			<table border="1" class="null">
			<%
			// Print header
			ElabSurvey es = elab.getSurveyProvider().getSurvey(user.getNewSurveyId());
			request.setAttribute("es", es);
			%>
				<tr>
					<th>PRETEST</th>
				</tr>
				<tr>
					<th>Student</th>
					<th>Time</th>	
					<th>Questions</th>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<th>&nbsp;</th>
					<c:forEach items="${es.questionsByNo}" var="question">
						<c:forEach var="i" begin="1" end="${question.numAnswers}">
							<th>
								<c:choose>
									<c:when test="${i == 1}">
										Q${question.number}
									</c:when>
									<c:otherwise>
										&nbsp;
									</c:otherwise>
								</c:choose>
							</th>
						</c:forEach> 
					</c:forEach>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<th>&nbsp;</th>
					<% 
					for (ElabSurveyQuestion esq: es.getQuestionsByNo()) {
						for (int i = 0; i < esq.getNumAnswers(); ++i) {
							%><th> <%= (char) ('A' + i) %></th> <%
						}
					}					
					%>
				</tr>
			<%			
			
			// Get pretest results
			try {
				Map<ElabGroup, Map<ElabStudent, List<ElabSurveyQuestion>>> results = elab.getSurveyProvider().getStudentResultsForTeacher("pre", user);
				request.setAttribute("results", results);
				%>
					<c:forEach items="${results}" var="groups">
						<c:forEach items="${groups.value}" var="result">
							<% pageContext.setAttribute("first", true); %>
							<tr>
								<td>${result.key.name}</td> <%-- Print student name --%>
								<c:forEach items="${result.value}" var="question">
									<c:if test="${first}">
										<td>${question.answeredTime}</td>
										<% pageContext.setAttribute("first", false); %> 
									</c:if>
									<c:forEach var="i" begin="1" end="${question.numAnswers}">
										<td>
											<c:choose>
												<c:when test="${i == question.givenAnswer.number}">
													<a href="show-question.jsp?type=${param.type}&id=${question.id}&answer=${question.givenAnswer.id}">1</a>
												</c:when>
												<c:otherwise>
													&nbsp;
												</c:otherwise>
											</c:choose>
										</td>
									</c:forEach>
								</c:forEach>
							</tr>
						</c:forEach> 
					</c:forEach>
				
				<%
			}
			catch (NullPointerException npe) {
				%>
				<h1>No Pre-Test Data Available</h1>
				<%
			}
			
			%>
			</table>
			<table border="1" class="null">
				<tr>
					<th>POSTTEST</th>
				</tr>
				<tr>
					<th>Student</th>
					<th>Time</th>	
					<th>Questions</th>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<th>&nbsp;</th>
					<c:forEach items="${es.questionsByNo}" var="question">
						<c:forEach var="i" begin="1" end="${question.numAnswers}">
							<th>
								<c:choose>
									<c:when test="${i == 1}">
										Q${question.number}
									</c:when>
									<c:otherwise>
										&nbsp;
									</c:otherwise>
								</c:choose>
							</th>
						</c:forEach> 
					</c:forEach>
				</tr>
				<tr>
					<th>&nbsp;</th>
					<th>&nbsp;</th>
					<% 
					for (ElabSurveyQuestion esq: es.getQuestionsByNo()) {
						for (int i = 0; i < esq.getNumAnswers(); ++i) {
							%><th> <%= (char) ('A' + i) %></th> <%
						}
					}					
					%>
				</tr>
			<%			
			
			// Get posttest results
			try {
				Map<ElabGroup, Map<ElabStudent, List<ElabSurveyQuestion>>> results = elab.getSurveyProvider().getStudentResultsForTeacher("post", user);
				request.setAttribute("results", results);
				%>
					<c:forEach items="${results}" var="groups">
						<c:forEach items="${groups.value}" var="result">
							<% pageContext.setAttribute("first", true); %>
							<tr>
								<td>${result.key.name}</td> <%-- Print student name --%>
								<c:forEach items="${result.value}" var="question">
									<c:if test="${first}">
										<td>${question.answeredTime}</td>
										<% pageContext.setAttribute("first", false); %> 
									</c:if>
									<c:forEach var="i" begin="1" end="${question.numAnswers}">
										<td>
											<c:choose>
												<c:when test="${i == question.givenAnswer.number}">
													1
												</c:when>
												<c:otherwise>
													&nbsp;
												</c:otherwise>
											</c:choose>
										</td>
									</c:forEach>
								</c:forEach>
							</tr>
						</c:forEach> 
					</c:forEach>
				
				<%
			}
			catch (NullPointerException npe) {
				%>
				<h1>No Pre-Test Data Available</h1>
				<%
			}
			%>
			</table>
			</div>
			<div id="footer">
			</div>
		</div>
	</body>
</html>
			