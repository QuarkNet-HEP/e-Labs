<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.util.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Update your groups</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="update-groups" class="teacher">
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
<h1>Update your groups</h1>
<%
	String groupName = request.getParameter("group");
	String ay = request.getParameter("ay");
	String role = request.getParameter("role");
	String survey = request.getParameter("survey");
	String detectorString = request.getParameter("detectorString");
	String passwd1 = request.getParameter("passwd1");
	String passwd2 = request.getParameter("passwd2");
	String submit = request.getParameter("submit");
	String prevPage = request.getParameter("prevPage");
	String[] studentsToDelete = request.getParameterValues("deleteStudents");
	
	if ("Update Group Information".equals(submit)) {
		if (groupName != null && ay != null && role != null 
		        && survey != null) {
		    if (passwd1 != null && !passwd1.equals(passwd2) && passwd1.length() < 6) {
				%>
					<div class="error">Passwords do not match or are too short (must be at least six characters long)</div>
				<%		        
		    }
		    else {
				//add the new registration information to research_group
				ElabGroup group = user.getGroup(groupName);
				int newSurveyId = -1; 
				boolean inSurvey = "yes".equals(survey);
				if (group == null) {
				    throw new ElabJspException("You are not the teacher for the specified group.");
				}
				group.setRole(role);
				group.setYear(ay);
				
				if (group.getSurvey()) { // legacy handler, let the teacher remove them or do nothing. 
					group.setSurvey(inSurvey); 
				}
				else if (inSurvey) { // anyone who is not in a survey but will be gets tossed to the new survey handler
					group.setSurvey(false);
					group.setNewSurvey(true);
					if (user.getNewSurveyId() == null) { 
						if (elab.getId().equals("1")) {
							newSurveyId = Integer.parseInt(elab.getProperty("cosmic.newsurvey"));
							user.setNewSurveyId(newSurveyId);
						}
						// set handlers for everything else. 
					}
					else {
						newSurveyId = user.getNewSurveyId().intValue();
					}
					group.setNewSurveyId(newSurveyId);
				}
				else { // Not in any survey (legacy or otherwise)
					group.setSurvey(false);
					group.setNewSurvey(false);
				}
				
				elab.getUserManagementProvider().updateGroup(group, passwd1);
				if (studentsToDelete != null && studentsToDelete.length != 0) {
					for (int j = 0; j < studentsToDelete.length; j++) {
						elab.getUserManagementProvider().deleteStudent(group, studentsToDelete[j]);
					}
				}
				out.write("<div class=\"results\">" + groupName + "'s information was successfully updated. ");
				if (prevPage != null && !prevPage.isEmpty()) {
					out.write("<a href=\"" + java.net.URLDecoder.decode(prevPage) + "\">Click here to continue onto the e-lab</a>");
				}
				out.write("</div>");
				request.setAttribute("group", group);
		    }
		}
	}
	else if ("Show Group Info".equals(submit)) {
		// Gather data for the user to modify.
		groupName = request.getParameter("chooseGroup");
		if (groupName != null && !groupName.equals("Choose Group")) {
			request.setAttribute("group", user.getGroup(groupName));
		}
		request.setAttribute("projects", elab.getUserManagementProvider().getProjectNames());
	}

%>
<form name="update-group-form" method="post" action="">
	<input type="hidden" name="prevPage" value="<%=prevPage%>"/>
	<p>
		<e:trselect name="chooseGroup" valueList="${user.groupNames}" labelList="${user.groupNames}"/>
		<input type="submit" name="submit" value="Show Group Info"/>
	</p>
	<c:if test="${not empty group}">
		<table id="group-form" class="form">
			<tr>
				<td>
					<label for="group">Group Name:</label>
				</td>
				<td>
					${group.name}
					<input type="hidden" name="group" value="${group.name}"/>
				</td>
			</tr>
			<tr>
				<td>
					<label for="ay">Academic Year:</label>
				</td>
				<td>
					<e:trselect name="ay" valueList="AY2004, AY2005, AY2006, AY2007, AY2008"
						labelList="2004-2005, 2005-2006, 2006-2007, 2007-2008, 2008-2009"
						value="${group.year}"/>
				</td>
			</tr>
			<tr>
				<td>
					<label for="role">Role:</label>
				</td>
				<td>
					<e:trselect name="role" valueList="user, upload, teacher"
						labelList="user, upload, teacher" value="${group.role}"/>
				</td>
			</tr>
			<tr>
				<td>
					<label for="survey">In survey:</label>
				</td>
				<td>
					<c:choose>
						<c:when test="${group.survey || group.newSurvey }">
							<input type="radio" name="survey" value="no">No</input>
							<input type="radio" name="survey" value="yes" checked>Yes</input>
						</c:when>
						<c:otherwise>
							<input type="radio" name="survey" value="no" checked>No</input>
							<input type="radio" name="survey" value="yes">Yes</input>
						</c:otherwise>
					</c:choose>
				</td>
			</tr>
			<tr>
				<td>
					<label for="passwd1">Password:</label>
				</td>
				<td>
					<input type="password" name="passwd1" size="10" maxlength="10"/>
				</td>
			</tr>
			<tr>
				<td>
					<label for="passwd2">Verify Password:</label>
				</td>
				<td>
					<input type="password" name="passwd2" size="10" maxlength="10"/>
				</td>
			</tr>
			<c:if test="${not empty group.students}">
				<tr>
					<td>
						<label for="deleteStudents">Students to delete from "${group.name}":</label>
					</td>
					<td>
						<ul id="delete-students">
							<c:forEach items="${group.students}" var="student">
								<input type="checkbox" name="deleteStudents" value="${student.id}">${student.name}</input>
							</c:forEach>
						</ul>
					</td>
				</tr>
			</c:if>
		</table>
	</c:if>
	<input type="submit" name="submit" value="Update Group Information"/>
</form>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

