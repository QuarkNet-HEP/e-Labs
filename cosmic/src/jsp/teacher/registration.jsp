<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Registration</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
	</head>

	<body id="registration">
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

<h1>e-Lab Registration</h1>

<table border="0" id="registration-links-table">
	<%--
	<tr>
		<td valign="top" width="40%">
			<a href="mass-registration.jsp">Register student research groups with a spreadsheet.</a>
		</td>
		<td valign="top">
			Using an existing spreadsheet with your class lists is the easiest way to register groups. 
			The spreadsheet must contain the first and last names of each student in the project and 
			the name of each research group. Decide what role you want the research group to 
			have--user or upload. If your students will be taking the pre- and post-tests for assessment, 
			select <strong>Yes</strong> for the column <strong>In survey</strong>. A template on the 
			next page will get you started.
		</td>
	</tr>
	 --%>
	<tr>
		<td  valign="top" width="40%">
			<a href="register-students.jsp">Register student research groups.</a>
		</td>
		<td valign="top">
			Use this page to register less than ten students. You can link new students to existing 
			research groups or you can create new research groups for students.
		</td>
	</tr>
	<tr>
		<td  valign="top">
			<a href="update-groups.jsp">Update your previously created groups.</a>
		</td>
		<td valign="top">
			Update your research groups.
		</td>
	</tr>
	<tr>
		<td  valign="top">
			<a href="update-group-projects.jsp">Assign your research groups to new e-Labs.</a>
		</td>
		<td valign="top">
			When you register a group, they are registered for the current e-Lab. 
			If you want to register them for new e-Labs as more become available, you need to use this page.
		</td>
	</tr>
	<tr>
		<td  valign="top">
			<a href="update-group-detectorid.jsp">Update detector IDs for your group.</a>
		</td>
		<td valign="top">
			When you analyze data in the Cosmic Ray Elab, most of the analyses need to know information 
			about your detector. This page allows you to assign detector IDs to your group.
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

