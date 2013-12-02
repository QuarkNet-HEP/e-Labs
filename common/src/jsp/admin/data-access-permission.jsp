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
	String[] allowAccess = request.getParameterValues("allowAccess");
	request.setAttribute("allowAccess", allowAccess);
	if ("Update Permissions".equals(submit)) {
		if (allowAccess.length > 0) {
			try {
				Collection teachers = elab.getUserManagementProvider().getTeachers();
				request.setAttribute("t", teachers);
				elab.getUserManagementProvider().updateCosmicDataAccess(teachers, allowAccess);
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
		<title>Give teachers permission to see all data</title>
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
			<form id="dataAccessPermissions" method="post">
				<table cellpadding="10" cellspacing="10" border="1" align="center">
					<tr>
						<td><font size="-1"><b><u>Teacher</u></b></font></td>
						<td><font size="-1"><b><u>Allow to view all data</u></b></font></td>
					</tr>
					<c:forEach items="${elab.userManagementProvider.teachers}" var="teacher">
						<%
							ElabGroup teacher = (ElabGroup) pageContext.getAttribute("teacher");
							if (teacher.getActive()) {
						%>
						<tr>
							<td>${teacher.name}</td>
							<td style="text-align: center;">
								<c:choose>
								 <c:when test="${teacher.cosmicAllDataAccess == true }">
									<input type="checkbox" name="allowAccess" id="${teacher.name}" value="${teacher.teacherId}" checked></input>
								 </c:when>
								 <c:otherwise>
									<input type="checkbox" name="allowAccess" id="${teacher.name}" value="${teacher.teacherId}"></input>
								 </c:otherwise>
								</c:choose>
							</td>
						</tr>
						<% } %>
					</c:forEach>
				</table>
	
				<input type="submit" name="submit" value="Update Permissions"/>	
			</form>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>