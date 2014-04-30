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

<%@ page import="com.opensymphony.clickstream.Clickstream" %>
<%
	int sessionCount = SessionListener.getTotalActiveSession();
	ArrayList activeSessions = SessionListener.getTotalSessionUsers();
	
	//now create the local TreeMap
	TreeMap<String, String> sessionDetails = new TreeMap<String, String>();
    final Map clickstreams = (Map) application.getAttribute("clickstreams");
	RE re = new RE("(analysis|posters|plots|uploadImage|data|library|site-index|assessment|teacher)");
    	
	for (int i = 0; i < activeSessions.size(); i++) {
		HttpSession s = (HttpSession) activeSessions.get(i);
		StringBuilder sb = new StringBuilder();
	    //start building session details
	    sb.append("<strong>Session ID:</strong> " + s.getId() + "<br />");
		//get user
	    ElabGroup eu = (ElabGroup) s.getAttribute("elab.user");
		Elab e = (Elab) s.getAttribute("elab");
		if (eu != null && e != null) {		
			sb.append("<strong>Username:</strong> "+ eu.getName() + "<br />");
			String school = eu.getSchool() != null ? eu.getSchool() : "";
			String city = eu.getCity() != null ? eu.getCity() : "";
			String state = eu.getState() != null ? eu.getState() : "";
			sb.append("<strong>Location:</strong> "+ school + ", " + city + " - " + state + "<br />");
			sb.append("<strong>Role:</strong> "+ eu.getRole() + "<br />");
			sb.append("<strong>Logged in to:</strong> "+ e.getName() + "<br />");
            synchronized(clickstreams) {
                Iterator it = clickstreams.keySet().iterator();
                while (it.hasNext())
                {
                    String streamkey = (String)it.next();
                    if (streamkey.equals(s.getId())) {
	                    Clickstream stream = (Clickstream)clickstreams.get(s.getId());
	                    sb.append("<strong>Time Started:</strong> "+String.valueOf(stream.getStart())+ "<br />");
	                    sb.append("<strong>Last Request:</strong> "+String.valueOf(stream.getLastRequest())+ "<br />");
	                    long streamLength = stream.getLastRequest().getTime() - stream.getStart().getTime();
	                    sb.append("<strong>Session Length:</strong> "+String.valueOf((streamLength > 3600000 ?
				        		" " + (streamLength / 3600000) + " hours" : "") +
				        	(streamLength > 60000 ?
				        		" " + ((streamLength / 60000) % 60) + " minutes" : "") +
				        	(streamLength > 1000 ?
				        		" " + ((streamLength / 1000) % 60) + " seconds" : ""))+ "<br />");
					   sb.append("<strong># of Requests:</strong> "+String.valueOf(stream.getStream().size())+ "<br />");
					    synchronized(stream) {
				            Iterator clickstreamIt = stream.getStream().iterator();						
				            int x = 1;
				            while (clickstreamIt.hasNext())
				            {
				                String click = clickstreamIt.next().toString();
				                if (re.match(click)) {
				                	sb.append("<strong>Visited # "+String.valueOf(x)+":</strong> "+String.valueOf(click)+ "<br />");
				                	x++;
				                }
						    }
						 }
					}
				}
			}//end of first synchronized							            		
		}	    
		sessionDetails.put("<strong>Session # " + String.valueOf(i), sb.toString() + "</strong>");
	}
	request.setAttribute("sessionCount",sessionCount);
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
				<h2>Total Active Sessions: ${sessionCount}</h2>
	    	   <table style="border: 1px solid black; cell-padding: 15px;">
	    	   		<tr>
	    	   			<th style="vertical-align: top; border: 1px dotted gray;">Session Id</th>
	    	   			<th style="vertical-align: top; border: 1px dotted gray;">Details</th>
	    	   		</tr>
	    	   		<c:forEach items="${sessionDetails}" var="sessionDetails">
	    	   			<tr>
	    	   				<td style="vertical-align: top; border: 1px dotted gray;">${sessionDetails.key }</td>
	    	   				<td style="vertical-align: top; border: 1px dotted gray;">${sessionDetails.value }</td>
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