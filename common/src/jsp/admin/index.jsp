<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Administration Tasks</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="administration" class="teacher">
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
				<table id="main" cellpadding="10" cellspacing="10">
					<tr><th colspan="2" >Admin Links</th><th></th></tr>
					<tr>
						<td>&#8226; <a href="../jsp/addGroup.jsp?role=teacher">Add Users</a></td>
						<td>Add e-Lab users.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="remove-expired-notifications.jsp">Remove expired notifications</a></td>
						<td>Delete notifications with expiration dates older than 30 days ago.</td>					
					</tr>

					<tr>
						<td>&#8226; <a href="clean-guest.jsp">Delete guest user data</a></td>
						<td>Delete all files created by the guest user.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../posters/poster-tags.jsp">Poster Tags</a></td>
						<td>Add, delete, update poster tags per e-Lab.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../references/control.jsp">References/Glossary/FAQ/News</a></td>
						<td>Add, update References/Glossary/FAQ/News items.</td>					
					</tr>					
					<tr>
						<td>&#8226; <a href="mark-teacher-status.jsp">Set group status</a></td>
						<td>Set teachers and their research groups to active/inactive.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../statistics">View e-Lab Statistics</a></td>
						<td>View ${elab.name} e-Lab statistics.</td>
					</tr>					
					<c:if test='${elab.name == "cosmic" }'>
						<tr><th colspan="2" >Cosmic Admin Links</th><th></th></tr>
						<tr>
							<td>&#8226; <a href="data-access-permission.jsp">Allow users to view all data</a></td>
							<td>Give rights to teachers to be able to access all cosmic data (blessed and unblessed).</td>						
						</tr>
						<tr>
							<td>&#8226; <a href="../analysis/list-all.jsp">View all analyses</a></td>
							<td>List of analyses by all users.</td>
						</tr>
					</c:if>				
				</table>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>