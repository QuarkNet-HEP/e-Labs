<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="gov.fnal.elab.SessionListener" %>
<%@ page import="gov.fnal.elab.Pair" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.util.*"%>
<%@ page import="org.apache.regexp.*" %>

<%
	int sessionCount = SessionListener.getTotalActiveSession();
	ArrayList activeSessions = SessionListener.getTotalSessionUsers();
	activeSessions.removeAll(Collections.singleton(null));
	int sessionUsers = 0;
	
	//now create the local TreeMap
	TreeMap<String, String> sessionDetails = new TreeMap<String, String>();
    	
	for (int i = 0; i < activeSessions.size(); i++) {
		HttpSession s = (HttpSession) activeSessions.get(i);
		StringBuilder sb = new StringBuilder();
	    //start building session details
	    //sb.append("<strong>Session ID:</strong> " + s.getId() + "<br />");
		//get user
		try {
			boolean validSession = false;
			Enumeration att_names = s.getAttributeNames();
			while (att_names.hasMoreElements()) {
				String attr = (String) att_names.nextElement();
				if (attr.equals("elab")) {
					validSession = true;
				}
			}
			if (validSession) {
				ElabGroup eu = (ElabGroup) s.getAttribute("elab.user");
				Elab e = (Elab) s.getAttribute("elab");
				if (eu != null && e != null) {
					sessionUsers++;
					sb.append("<strong>Username:</strong> "+ eu.getName() + "<br />");
					String school = eu.getSchool() != null ? eu.getSchool() : "";
					String city = eu.getCity() != null ? eu.getCity() : "";
					String state = eu.getState() != null ? eu.getState() : "";
					sb.append("<strong>Location:</strong> "+ school + ", " + city + " - " + state + "<br />");
					sb.append("<strong>Role:</strong> "+ eu.getRole() + "<br />");
					sb.append("<strong>Logged in to:</strong> "+ e.getName() + "<br />");
		            }
				String sessiontext = sb.toString();
				if (!sessiontext.equals("")) {
		    		sessionDetails.put("<strong>Session # " + String.valueOf(i), sessiontext + "</strong>");				
				}
			}//end of validSession
		} catch (Exception e) {
    		String message = "Exception in session-tracking.jsp: " + e.getMessage();			
		}
	}
	request.setAttribute("sessionCount",sessionCount);
	request.setAttribute("sessionUsers", sessionUsers);
	request.setAttribute("sessionDetails",sessionDetails);	

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Session Tracking</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="session-tracking" class="teacher">
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
				<h1>Session Tracking</h1>
				<h2>Total Users Logged In: ${sessionUsers}</h2>
				<h2>Total Active Sessions: ${sessionCount}</h2>
	    	   <table style="border: 1px solid black; cell-padding: 15px;">
	    	   		<tr>
	    	   			<th style="vertical-align: top; border: 1px dotted gray;">Details</th>
	    	   		</tr>
	    	   		<c:forEach items="${sessionDetails}" var="sessionDetails">
	    	   			<c:if test="${not empty sessionDetails.value}">
		    	   			<tr>
		    	   				<td style="vertical-align: top; border: 1px dotted gray;">${sessionDetails.value }</td>
	    		   			</tr>
	    		   		</c:if>
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