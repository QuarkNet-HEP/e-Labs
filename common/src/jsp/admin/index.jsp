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
						<td>&#8226; <a href="../notifications/remove-expired-notifications.jsp">Delete expired notifications</a></td>
						<td>Delete notifications with expiration dates older than 30 days ago.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../references/control.jsp">FAQs Add/Update</a></td>
						<td>Add, update FAQ items.</td>					
					</tr>					
					<tr>
						<td>&#8226; <a href="../posters/poster-tags.jsp">Poster Tags</a></td>
						<td>Add, delete, update poster tags per e-Lab.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../session/session-tracking.jsp">Session Tracking</a></td>
						<td>See the users whose sessions are still active.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../teacher/mark-teacher-status.jsp">Set group status</a></td>
						<td>Set teachers and their research groups to active/inactive.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../unit-testing/index.jsp">Unit Testing</a></td>
						<td>Run automated tests for written code grouped by functionality.</td>					
					</tr>
					<tr>
						<td>&#8226; <a href="../statistics">View e-Lab Statistics</a></td>
						<td>View ${elab.name} e-Lab statistics.</td>
					</tr>					
					<tr>
						<td>&#8226; <a href="../monitor">View Server Monitors</a></td>
						<td>View ${elab.name} file system, execution, load average and disk utilization.</td>
					</tr>					
					<c:if test='${elab.name == "cosmic" }'>
						<tr><th colspan="2" >Cosmic Admin Links</th><th></th></tr>
						<tr>
							<td>&#8226; <a href="../data/data-access-permission.jsp">Allow users to view all data</a></td>
							<td>Give rights to teachers to be able to access all cosmic data (blessed and unblessed).</td>						
						</tr>
						<tr>
							<td>&#8226; <a href="../data/create-threshold.jsp">Create Threshold Times files</a></td>
							<td>Create individual threshold times files if they failed to be created at upload time.</td>
						</tr>
						<tr>
							<td>&#8226; <a href="../analysis/list-all.jsp">View all analyses</a></td>
							<td>List of analyses by all users.</td>
						</tr>
						<!--  
						<tr>
							<td>&#8226; <a href="../analysis/cosmic-analysis-errors.jsp">Add, Update Cosmic Analysis Errors</a></td>
							<td>Enter cosmic common errors and suggestions on what to do, fix, etc.</td>
						</tr>
						<tr>
							<td>&#8226; <a href="../analysis/analysis-queue.jsp">View analysis queue</a></td>
							<td>View queued analyses and their statuses.</td>
						</tr>
						-->
						<tr>
							<td>&#8226; <a href="../analysis-blessing/benchmark-info.jsp">View upload plus benchmark information</a></td>
							<td>View split files and their blessed/unblessed status details.</td>
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