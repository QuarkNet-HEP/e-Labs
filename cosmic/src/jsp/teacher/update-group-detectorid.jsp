<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.util.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Update group detector IDs</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="update-group-detectorid" class="teacher">
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
	boolean done = false;   //set true when the database update is complete
	String groupName = request.getParameter("group");
	String ids = request.getParameter("detectorids");
	String submit = request.getParameter("submit");
	ElabGroup group = null;
	
	ElabUserManagementProvider p = elab.getUserManagementProvider();
	CosmicElabUserManagementProvider cp = null;
	if (p instanceof CosmicElabUserManagementProvider) {
		cp = (CosmicElabUserManagementProvider) p;
	}
	else {
		throw new ElabJspException("The user management provider does not support management of DAQ IDs. " + 
			"Either this e-Lab does not use DAQs or it was improperly configured.");
	}
	
	if ("Update Group Detector IDs".equals(submit)) {
		group = user.getGroup(groupName);
		if (group == null) {
		    throw new ElabJspException("You are not the teacher for the specified group.");
		}
		cp.setDetectorIds(group, Arrays.asList(ids.split("[,\\s]+")));
		out.write("<div class=\"results\">Successfully updated DAQ ID(s) for group \"" + groupName + "\".</div>");
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
	if (group != null) {
	    Collection cids = cp.getDetectorIds(group);
	    request.setAttribute("detectorids", ElabUtil.join(cids, ", "));
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
					<label for="detectorids">Detector ID(s) for ${group.name} (comma or space separated):</label>
				</td>
				<td>
					<input type="text" name="detectorids" value="${detectorids}"/>
				</td>
			</tr>
		</table>
	</c:if>
	<input type="submit" name="submit" value="Update Group Detector IDs"/>
</form>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

