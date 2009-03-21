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
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
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


<h1>Cosmic Site Map</h1>

<%
	// Check if the teacher is in the survey
	ElabGroup user = (ElabGroup) request.getAttribute("user");
	boolean newSurvey = user.isNewSurvey();

%>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
				<h2>Teacher Pages</h2>
				<ul class="simple">
					<li><a href="index.jsp">Teacher Page</a></li>
					<li><a href="notes.jsp">Classroom Notes</a></li>
					<li><a href="web-guide.jsp">Research Guidance</a></li>
					<li><a href="activities.jsp">Sample Classroom Activities</a></li>
					<li><a href="strategy.jsp">Teaching Strategies</a></li>
					<li><a href="standards.jsp">Alignment with Standards</a></li>
					<e:restricted role="teacher">
						<li><a href="../test/test.jsp?type=presurvey&studentid=0">Pre-test</a> and <a href="../test/test.jsp?type=postsurvey&studentid=0">Post-test</a>.</li>
						<li>Student Results for the <a href="../test/results.jsp?type=presurvey">pre-test</a> and the <a href="../test/results.jsp?type=postsurvey">post-test</a>.</li>
					</e:restricted>
					<e:restricted role="admin">
						<li><a href="../test/show-teachers.jsp">Show Student Test Results for all Teachers</a></li>
					</e:restricted>
					<li><a href="registration.jsp">General Registration</a></li>
					<li><a href="register-students.jsp">Student Research Group Registration</a></li>
                    <li><a href="mass-registration.jsp">Mass Registration (Spreadsheet)</a></li>
                    <li><a href="update-groups.jsp">Update Student Research Groups</a></li>
                    <li><a href="update-group-projects.jsp">Update e-Lab Assignments for Groups</a></li>
					<li><a href="site-map.jsp">Site Map</a></li>
				</ul>
				
			</div>
		</td>
		
		<td>
			<div id="center">
			</div>
		</td>
		<td>
			<div id="right">
				<c:choose>
					<c:when test="${newSurvey == true }">
						<h2>New Survey Tools</h2>
					</c:when>
				</c:choose>
				<h2>Student Pages</h2>
				<ul class="simple">
					<li><a href="../home/">Home</a></li>
					<li><a href="../site-index/">Site Index</a></li>
				</ul>
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
