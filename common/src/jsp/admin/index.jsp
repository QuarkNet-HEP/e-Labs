<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%
	//remove expired notifications right here
	String message = "";
	try {
		ElabNotificationsProvider nprovider = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
		List<Notification> en = nprovider.getExpiredNotifications();
		if (en != null) {
			for (Notification rm: en) {
				nprovider.removeNotification(user.getGroup(), rm.getId());
			}
		}
	} catch (Exception e) {
		message = e.getMessage();
	}
	ElabMemory em = new ElabMemory();
    em.refresh();
	String memory = "Total heap memory: "+ String.valueOf(em.getTotalMemory())+"MB<br />"+
			"Max heap memory: "+ String.valueOf(em.getMaxMemory())+"MB<br />"+
			"Used heap memory: "+ String.valueOf(em.getUsedMemory())+"MB<br />"+
			"Free heap memory: "+ String.valueOf(em.getFreeMemory())+"MB.";
	request.setAttribute("message", message);
	request.setAttribute("memory", memory);
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
            <td>&#8226; <a href="../reports/index.jsp">e-Lab Reports</a></td>
            <td>Reports for uploads, posters and plots.</td>
          </tr>
					<tr>
						<td>&#8226; <a href="../jsp/addGroup.jsp?role=teacher">Add Users</a></td>
						<td>Add e-Lab users.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../admin/add-group.jsp?role=teacher">Add Users NEW</a></td>
						<td>Add e-Lab users - NEW.</td>
					</tr>
					<tr>
						<td>&#8226; <a href="../references/control.jsp"> FAQs Add/Update</a></td>
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
<!-- 
					<tr>
						<td>&#8226; <a href="../unit-testing/index.jsp">Unit Testing</a></td>
						<td>Run automated tests for written code grouped by functionality.</td>					
					</tr>
 -->
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
							<td>&#8226; <a href="../jsp/editDescription.jsp">Edit TR Descriptions</a></td>
							<td>Access cosmic transformation descriptions.</td>						
						</tr>
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
						<tr>
							<td>&#8226; <a href="../reports/benchmark-info.jsp">View upload plus benchmark information</a></td>
							<td>View split files and their blessed/unblessed status details.</td>
						</tr>
						<tr>
							<td>&#8226; <a href="../reports/geometry-info.jsp">View splits with geometry problems.</a></td>
							<td>View split files where the geometry stacked metadata does not match the geometry.</td>
						</tr>
					</c:if>	
					<tr><td colspan="2"><br /><i>* Expired notifications are removed automatically when we browse this page.</i></td></tr>			
					<tr><td style="text-align: right;"><i>* Memory Details:</i></td>
						<td><i>${memory}</i></td>
					</tr>			
				</table>
			</div>
			<!-- end content -->	
			<c:if test="${not empty message }">
				<div>${message}</div>
			</c:if>
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>