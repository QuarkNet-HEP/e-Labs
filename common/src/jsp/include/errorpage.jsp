<%@ page isErrorPage="true" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Cosmic Data Interface</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"/>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
				</div>
			</div>
			
			<div id="content">
				
<%
	System.out.println("Exception caught while rendering page: ");
	if (exception != null) {
	    exception.printStackTrace();
	}
%>
<h1>An error has occurred during your request</h1>

<table border="0" id="main">
	<tr>
		<% request.setAttribute("exception", exception); %>		
		<% if (exception instanceof ElabJspException) { %>
			<span class="error">${exception.message}</span>
		<% } else { %>
			<td id="center">
				<h2>Request URL:</h2>
				<pre>${request.requestURL}</pre>
				<h2>Query String:</h2>
				<pre>${request.queryString}</pre>
				<h2>User:</h2>
				<% ElabGroup user = ElabGroup.getUser(session); %>
				<pre><%= user %></pre>
				<% if (exception != null) { %>
					<h2>Exception</h2>
					<pre><%= exception.toString() %></pre>
					<h2>Stack trace:</h2>
					<pre><% exception.printStackTrace(new java.io.PrintWriter(out)); %></pre>
					<% 
						if(exception instanceof JspException) {
						    Throwable root = ((JspException) exception).getRootCause();
						    if (root != null) {
							    %> <h2>Root cause:</h2>
							       <pre> <%
								root.printStackTrace(new java.io.PrintWriter(out));
							    %> </pre> <%
						    }
						}
				} %>
			</td>
		<% } %>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>