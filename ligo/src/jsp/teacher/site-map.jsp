<%@ include file="../include/elab.jsp" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>e-Lab Teacher Site Map</title>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="/elab/cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="site-map">
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


<h1>LIGO e-Lab Teacher Site Index</h1>

<%
	// Check if the teacher is in the study
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	boolean newSurvey = false;  
	
	if (user != null) {
		if (user.getRole().equalsIgnoreCase("teacher")) {
			newSurvey = elab.getSurveyProvider().hasTeacherAssignedSurvey(user.getId());
		}
		request.setAttribute("userId", user.getId());
	}
	request.setAttribute("newSurvey", newSurvey);
%>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<h2>Teacher Pages</h2>
				<ul class="simple">
					<li><a href="index.jsp"><b>Home</b></a></li>
					<ul class="simple">
						<li><a href="web-guide.jsp">Website Features</a></li>
						<li>Rubrics - <A HREF="../assessment/rubric-ci.html">Content & Investigation</A>,
							<a href="../assessment/rubric-r.html">Process</a>, <a href="../assessment/rubric-t.html">Computing</a>,
							<a href="../assessment/rubric-wla.html">Literacy</a> and <a href="../assessment/rubric-p.html">Poster</a></li>
					</ul>
					<li><a href="community.jsp"><b>Community</b></a> - Sharing Ideas: I2U2 Blog and Facebook Users Group
					<li><a href="standards.jsp"><b>Standards</b></a></li>
					<li><a href="site-map.jsp"><b>Site Index</b></a></li>
					<e:restricted role="teacher">
						<li><b>Registration</b></li>
						<ul class="simple">
							<li><a href="registration.jsp">General Registration</a></li>
							<li><a href="register-students.jsp">Student Research Group Registration</a></li>
		                    <li><a href="mass-registration.jsp">Mass Registration (Spreadsheet)</a></li>
		                    <li><a href="update-groups.jsp">Update student research groups.</a></li>
		                    <li><a href="update-group-projects.jsp">Update e-Lab assignments for groups.</a></li>
                   		</ul>
					</e:restricted>
					<e:restricted role="admin">
						<li><a href="../test/show-teachers.jsp">Show Student Test Results for all Teachers</a></li>
					</e:restricted>
					<e:restricted role="teacher">
					<li><a href="#" onclick="javascript:window.open('\/elab\/ligo\/teacher\/forum\/HelpDeskRequest.php', 'helpdesk', 'width=800,height=600, resizable=1, scrollbars=1');return false;">Helpdesk</a>
					</e:restricted>
					
					
					
				</ul>
				
			</div>
		</td>
		
		<td>
			<div id="center">
			</div>
		</td>
		<td>
			<div id="right">
				<h2>Student Pages</h2>
				<ul class="simple">
					<li><a href="../home/">Home</a></li>
					<li><a href="../site-index/">Site Index</a></li>
				</ul>
				<e:restricted role="teacher">
					<h2>Test results</h2>
					<b>For research groups created after Summer 2009</b>
					<ul class="simple">
						<li><a href="../survey/survey.jsp?type=pre&studentid=0&id=1">Pre-test</a> and <a href="../survey/survey.jsp?type=post&studentid=0&id=1">Post-test</a>.</li>
						<c:if test="${newSurvey == true }">
							<li>Student Results for the <a href="../survey/results.jsp?type=pre">pre-test</a> and the <a href="../survey/results.jsp?type=post">post-test</a>.</li>
						</c:if>
					</ul>
				</e:restricted>
			</div>
		</td>
	</tr>
</table>

			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>
