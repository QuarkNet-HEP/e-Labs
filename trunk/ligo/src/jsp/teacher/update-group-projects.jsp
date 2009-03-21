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
		<title>Update the e-Lab Assignment for your groups.</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="update-group-projects" class="teacher">
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
<h1>Update the e-Lab Assignment for your groups.</h1>
<%
	boolean done = false;   //set true when the database update is complete
	String groupName = request.getParameter("group");
	String[] projects = request.getParameterValues("projects");
	String submit = request.getParameter("submit");
	ElabGroup group = null;
	
	if ("Update e-Lab Assignments".equals(submit)) {
		group = user.getGroup(groupName);
		if (group == null) {
		    throw new ElabJspException("You are not the teacher for the specified group.");
		}
		
		elab.getUserManagementProvider().updateProjects(group, projects);

		out.write("<div class=\"results\">Successfully updated e-Labs for project \"" + groupName + "\".</div>");
		request.setAttribute("group", group);

	}
	else if ("Show Group Info".equals(submit)) {
		// Gather data for the user to modify.
		groupName = request.getParameter("chooseGroup");
		if (groupName != null && !groupName.equals("Choose Group")) {
		    group = user.getGroup(groupName);
			request.setAttribute("group", group);
		}
	}

%>
<form name="update-group-projects-form" method="post" action="">
	<p id="choose-group">
		<e:trselect name="chooseGroup" valueList="${user.groupNames}" labelList="${user.groupNames}"/>
		<input type="submit" name="submit" value="Show Group Info"/>
	</p>
	<c:if test="${not empty group}">
		<table id="group-projects-form" class="form">
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
					<label for="projects">e-Labs for ${group.name}:</label>
				</td>
				<td>
					<%
						Collection projectNames = elab.getUserManagementProvider().getProjectNames();
						Set groupProjects = new HashSet(elab.getUserManagementProvider().getProjectNames(group));
						Iterator i = projectNames.iterator();
						while (i.hasNext()) {
						    String project = (String) i.next();
						    if (groupProjects.contains(project)) {
						        out.write("<input type=\"checkbox\" name=\"projects\" value=\"" 
						                + project + "\" checked=\"true\">" + project + "</input>");
						    }
						    else {
						        out.write("<input type=\"checkbox\" name=\"projects\" value=\"" 
						                + project + "\">" + project + "</input>");
						    }
						}
					%>
				</td>
			</tr>
		</table>
	</c:if>
	<input type="submit" name="submit" value="Update e-Lab Assignments"/>
</form>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

