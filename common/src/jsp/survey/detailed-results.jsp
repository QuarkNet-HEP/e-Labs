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
			try {
				Map results = elab.getSurveyProvider().getStudentResultsForTeacher("pre", user);
				%>
				<table border="1">
					<c:forEach items="${results}" var="groups">
						<c:forEach items="${groups.value}" var="result">
							<tr>
								<td>${result.key.name}</td> <%-- Print student name --%>
								<c:forEach items="${result.value}" var="question">
									<c:forEach var="i" begin="1" end="${result.numAnswers}">
										<td>
											<c:choose>
												<c:when test="${i} == ${question.number}">
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
				</table>
				
				<%
			}
			catch (NullPointerException npe) {
				%>
				<h1>No Test Data Available</h1>
				<%
			}
			%>
			</div>
			<div id="footer">
			</div>
		</div>
	</body>
</html>
			