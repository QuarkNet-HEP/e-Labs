<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.SessionListener" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.*"%>
<%
	int count = SessionListener.getTotalActiveSession();
	TreeMap<String, HttpSession> activeSessions = SessionListener.getTotalSessionUsers();
	TreeMap<String, ElabGroup> activeUsers = new TreeMap<String, ElabGroup>();
	
	for (Map.Entry<String, HttpSession> entry: activeSessions.entrySet()) {
		String key = entry.getKey();
		HttpSession value = entry.getValue();
		ElabGroup eu = (ElabGroup) value.getAttribute("elab.user");
		if (eu != null) {
			activeUsers.put(key, eu);
		}
	}
	request.setAttribute("activeUsers",activeUsers);	

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Users logged In</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/admin.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
    <body>	
    		<!-- entire page container -->
		<div id="container">		
			<div id="content">
				<h1>Users Logged In</h1>
	    	   <table>
	    	   		<tr>
	    	   			<th>Session Id</th>
	    	   			<th>Group Name</th>
	    	   		</tr>
	    	   		<c:forEach items="${activeUsers}" var="activeUsers">
	    	   			<tr>
	    	   				<td>${activeUsers.key }</td>
	    	   				<td>${activeUsers.value}</td>
	    	   			</tr>
	    	   		</c:forEach>
	    	   </table>
			</div>
		</div>
	</body>

<html>
