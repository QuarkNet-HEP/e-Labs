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
		try {
		    cp.setDetectorIds(group, Arrays.asList(ids.split("[,\\s]+")));
		    out.write("<div class=\"results\">Successfully updated DAQ ID(s) for group \"" + groupName + "\".</div>");
		}
		catch (ElabException e) {
		    // Bob feels that the normal error page is rather too unfriendly for this sort of issue
		    // so I'm injecting things in.
		    out.write("<h2>Oops!</h2><p>Did you type the detector IDs correctly?</p><ul>" +
		            "<li>If your DAQ's serial number starts with 10870, please enter only the last four digits starting with the 5.</li>" +
		            "<li>If your DAQ's serial number starts with 6, please enter only the first four digits starting with the 6.</li>" +
		            "<li>Otherwise, type in the 1-3 digit serial number.</li></ul>" + 
		            "<p>We've found problems with these detector IDs. Please check and re-enter them: " + e.getMessage() + 
		            "</p><h2>Try Again?</h2>");
		}
		finally {
		    request.setAttribute("group", group);
		}
	}

	if ("Show Group Info".equals(submit)) {
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
<p>Every <a HREF="javascript:glossary('DAQ',130)">DAQ</a> board has a detector id (DAQ number) based on the serial number on the board. Students select it when they upload
data. To find it, type "SN" when connected with your detector.</p>
<form name="update-group-projects-form" method="post" action="">
	<p id="choose-group">
		<c:choose>
			<c:when test="${not empty group}">
				<e:trselect name="chooseGroup" valueList="${user.groupNames}" labelList="${user.groupNames}" default="${group.name}" />
			</c:when>    
			<c:otherwise>
				<e:trselect name="chooseGroup" valueList="${user.groupNames}" labelList="${user.groupNames}" default="${group.name}" />
			</c:otherwise>
        </c:choose>
        <input type="submit" name="submit" value="Show Group Info"/>
	</p>
</form>
	<c:if test="${not empty group}">
		<form name="update-group-projects-form" method="post" action="">
			<table id="group-projects-form" class="form">
				<tr>
					<td align="right">
						<label for="group">Group Name:</label>
					</td>
					<td>
						${group.name}
						<input type="hidden" name="group" value="${group.name}"/>
					</td>
				</tr>
				<tr>
					<td align="right">
						<label for="detectorids">Detector ID(s) for ${group.name} <br /> (comma or space separated):</label>
					</td>
					<td>
						<input type="text" name="detectorids" value="${detectorids}"/>
					</td>
				</tr>
				<tr>
					<td>&nbsp;</td>
					<td>
						<input type="submit" name="submit" value="Update Group Detector IDs"/>
					</td>
				</tr>
			</table>
		</form>
		</form>
	</c:if>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

