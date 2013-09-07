<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map.Entry" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Groups</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
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
<h1>Groups</h1>
<ul>
	<li><a href="register-students.jsp">Register</a> student groups.</li>
	<li><a href="update-groups.jsp">Update</a> existing groups.</li>
</ul>
	
<%
Collection groupNames = user.getGroupNames();
Iterator i = groupNames.iterator(); 
TreeMap<String, Collection> groups = new TreeMap<String, Collection>();

while (i.hasNext()) {
	String groupName = (String) i.next();
	if (user.getGroup(groupName).getActive()) {
	    Collection studentNames = user.getGroup(groupName).getStudents();
    	groups.put(groupName, studentNames);
	}
}

request.setAttribute("groups", groups);

%>
	<table style="padding: 10px;">
		<tr>
			<th width="150px" style="border: 1px solid gray;">Research Group</th>
			<th width="450px" style="border: 1px solid gray;">Students</th>
		</tr>
		<c:forEach items="${groups}" var="group">
			<tr>
				<td style="border: 1px solid lightgray;">${group.key}</td>
				<td style="border: 1px solid lightgray;">
					<c:forEach items="${group.value}" var="student">
					  ${student.name} &nbsp; 
					</c:forEach>
				</td>
			</tr>
		</c:forEach>
	</table>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

