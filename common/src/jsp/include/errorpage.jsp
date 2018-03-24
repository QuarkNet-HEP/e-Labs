<%@ page isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>

<c:if test="${!headerIncluded}">
	
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
			<title>An error has occurred</title>
			<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
			<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		</head>
		
		<body id="error-page" class="data">
			<!-- entire page container -->
			<div id="container">
				<div id="top">
					<div id="header">
						<%@ include file="../include/header.jsp" %>
					</div>
				</div>
				
				<div id="content">
</c:if>

<%-- Print to the console, which redirects to catalina.out: --%>
<%
	System.out.println("\n(----------------------------------------\n");
	System.out.println("Exception caught while rendering page: ");
	Throwable root = null;
	if (exception != null) {
		exception.printStackTrace();
		if (exception instanceof JspException) {
			root = ((JspException) exception).getRootCause();
			if (root != null) {
				System.out.println("Root cause: ");
				root.printStackTrace();
			}
		}
	}
	System.out.println("Request URL: " + request.getRequestURL());
	System.out.println("QueryString: " + request.getQueryString());
	System.out.println("Referer: " + request.getHeader("Referer"));
	System.out.println("Group: " + ElabGroup.getUser(session));
	System.out.println("\n)----------------------------------------\n");
	if (root instanceof ElabJspException) {
		exception = root;
	}
	request.setAttribute("exception", exception);
%>

<%-- Edited to remove stuff users don't really need to know - JG 23Mar2018 --%>
<div id="error-page-body" style="width: 790px; text-align: left;">
	<h1>An error has occurred during your request</h1>
	<p>
		If you've encountered a bug or need assistance, please submit a
		<a href="../teacher/forum/HelpDeskRequest.php">Help Desk Request</a>.
		The following information is provided to help you	and the e-Labs
		administrators identify the problem:
	</p>
	<table border="0" id="error-page-table" width="790px">
		<tr>		
			<% if (exception instanceof ElabJspException) { %>
				<span class="error"><c:out value="${exception.message}" /></span>
			<% } else { %>
				<td id="error-page-details" width="790px" style="text-align: left;">
					<h2>Request URL:</h2>
					<pre>${request.requestURL}</pre>
					<h2>Query String:</h2>
					<pre>${request.queryString}</pre>
					<% if (exception != null) { %>
						<h2>Exception</h2>
						<pre><%= ElabUtil.stripHTML(exception.toString()) %></pre>
						<% 
						if(exception instanceof JspException) {
								String rootCause = ((JspException) exception).getRootCauseMessage();
							  if (rootCause != null) {
						%>
									<h2>Root cause:</h2>
									<pre><c:out value="${rootCause}" /></pre>
						<%
							 }
						}
					} %>
				</td>
			<% } %>
		</tr>
	</table>
</div>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
