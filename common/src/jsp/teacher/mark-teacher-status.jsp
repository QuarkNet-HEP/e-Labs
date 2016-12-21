<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%
	String submit = request.getParameter("submit");
	String[] activeIds = request.getParameterValues("status");
	request.setAttribute("status", activeIds);
	if ("Update Status".equals(submit)) {
		if (activeIds.length > 0) {
			try {
				Collection teachers = elab.getUserManagementProvider().getTeachers();
		    	Object[] teacher = teachers.toArray();
				elab.getUserManagementProvider().updateGroupStatus(activeIds);
			} catch (ElabException e) {
				String message = e.toString();
			}
		}
	}//end of submit
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Mark teachers and their research groups as active/inactive</title>
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
			<p>New code.</p>
			<form id="updateStatus" method="post">
				<table cellpadding="10" cellspacing="10" border="1" align="center">
					<tr>
						<td><font size="-1"><b><u>Teacher</u></b></font></td>
						<td><font size="-1"><b><u>Active/Inactive?</u></b></font></td>
						<td><font size="-1"><b><u>School</u></b></font></td>
						<td><font size="-1"><b><u>City</u></b></font></td>
						<td><font size="-1"><b><u>State</u></b></font></td>
						<td><font size="-1"><b><u>Groups</u></b></font></td>
					</tr>
					<c:forEach items="${elab.userManagementProvider.teachers}" var="teacher">
						<tr>
							<td valign=top>${teacher.name}</td>
							<td valign=top style="text-align: center;">
								<c:choose>
								 <c:when test="${teacher.active == true }">
									<input type="checkbox" name="status" id="${teacher.name}" value="${teacher.teacherId}" checked></input>
								 </c:when>
								 <c:otherwise>
									<input type="checkbox" name="status" id="${teacher.name}" value="${teacher.teacherId}"></input>
								 </c:otherwise>
								</c:choose>
							</td>
							<td valign=top>${teacher.group.school}</td>
							<td valign=top>${teacher.group.city}</td>
							<td valign=top>${teacher.group.state}</td>
							<td>
								<c:forEach items="${teacher.groups}" var="group">
									${group.name} - 
								<!--	${group.teacher_id}-->
								<br>
								</c:forEach>
							</td>
						</tr>
					</c:forEach>
				</table>
	
				<div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Update Status"/></div>
			</form>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
