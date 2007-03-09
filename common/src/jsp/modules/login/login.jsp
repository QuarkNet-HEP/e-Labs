<%@ include file="../../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabUser" %>
<%@ page import="gov.fnal.elab.usermanagement.AuthenticationException" %>
<%
	String username = request.getParameter("user");
	String password = request.getParameter("pass");
	String project  = request.getParameter("project");
	if (project == null) {
		project = elab.getName();
	}
	String message  = request.getParameter("message");
	if (message == null) {
		message = "Please log in to proceed";
	}
	
	AuthenticationException exception = null;
	boolean success = false;
	
	ElabUser user = null;
	if (username != null && password != null) {
		try {
			user = elab.authenticate(username, password, project);
		}
		catch (AuthenticationException e) {
			exception = e;
		}
	}
	if (user != null) {
		//login successful
		ElabUser.setUser(session, user);
		String prevPage = request.getParameter("prevPage");
		if(prevPage == null){
			/* This could be replaced by a property */
    		prevPage = elab.getProperties().getLoggedInHomePage();
		}
		
		// I finally found the solution to the double login problem, and it's this
        // one line.  :)  Please don't remove.
        response.addCookie(new Cookie("JSESSIONID", session.getId()));
		
		response.sendRedirect(prevPage);
	}
	else { %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Login to <%=elab.getProperties().getFormalName()%></title>
		<%= elab.css("/css/style2.css") %>
		<%= elab.css("/css/login.css") %>
	</head>
	
	<body id="login">
		<!-- entire page container -->
		<div id="container">
			<div id="top"
				<div id="header">
					<%@ include file="../../include/header.jsp" %>
				</div>
				<div id="nav">
					<!-- no nav here -->
				</div>
			</div>
			
			<div id="content">
				
<div id="content-header">
	<%= message %>
</div>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		<td>
			<div id="center">
				<% 	if (exception != null) { %>
						<span class="warning"><%= exception.getMessage() %></span>
				<%	} %>
				<div id="login-form-contents">
					<%@ include file="loginform.jsp" %>
				</div>
				<div id="login-form-text">
					<p>
						<a href="<%= elab.getGuestLoginLink(request) %>">Login as guest</a>
					</p>
				</div>
			</div>
		</td>
		<td>
			<div id="right">
			</div>
		</td>
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

<%
	}
%>