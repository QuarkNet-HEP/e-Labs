<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ include file="../login/teacher-login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Registration</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>

	<body id="teacher">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
				</div>
				<div id="nav">
					<%@ include file="../include/nav-teacher.jsp" %>
				</div>
			</div>
			
			<div id="content">

<center>
<TABLE WIDTH=804>
<TR><TD>
	<TABLE WIDTH=800 CELLPADDING=4>
	<TR><TD  bgcolor=black>
	<FONT FACE=ARIAL COLOR=white SIZE=+1>
	<B>e-Lab Registration</B>
	</TD></TR></table>

</td></tr>

<P>
	
<tr><td>
	<table cellpadding="4" cellspacing="4" border="0">
	<tr><td  valign="top" width="350"><FONT FACE=ARIAL><A HREF="massRegistration.jsp">Register student research groups with a spreadsheet.</A></font></td><td valign="top"><FONT FACE=ARIAL SIZE=-1>
	Using an existing spreadsheet with your class lists is the easiest way to register groups. The spreadsheet must contain the first and last names of each student in the project and the name of each research group. Decide what role you want the research group to have--user or upload. If your students will be taking the pre- and post-tests for assessment, select <b>Yes</b> for the column <b>In survey</b>. A template on the next page will get you started.</FONT></td></tr>
	
	<tr><td  valign="top"><FONT FACE=ARIAL><A HREF="registerStudents.jsp">Register student research groups.</A></font></td><td valign="top"><FONT FACE=ARIAL SIZE=-1>
	Use this page to register less than ten students. You can link new students to existing research groups or you can create new research groups for students.</FONT></td></tr>

	<tr><td  valign="top">
	<FONT FACE=ARIAL>
	<a href="updateGroups.jsp">Update your previously created groups.</FONT></a></td><td valign="top"><FONT FACE=ARIAL  SIZE=-1>Update your research groups.</FONT></td></tr>

	<tr><td  valign="top">
	<FONT FACE=ARIAL>
	<a href="updateGroupProjects.jsp">
	Assign your research groups to new e-Labs.</FONT></a></td><td valign="top"><FONT FACE=ARIAL  SIZE=-1>When you register a group, they are registered for the current e-Lab.  If you want to register them for new e-Labs as more become available, you need to use this page.</FONT></td></tr>

	</table>

</td></tr>


</center>

			</div>
			<!-- end content -->

			<div id="footer">
			</div>
		
		</div>
		<!-- end container -->
	</body>
</html>

