<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.usermanagement.AuthenticationException" %>
<%
	String username = request.getParameter("user");
	String password = request.getParameter("pass");
	String message  = request.getParameter("message");
	if (message == null) {
		message = "Please log in to proceed";
	}
	
	AuthenticationException exception = null;
	boolean success = false;
	
	ElabGroup user = null;
	if (username != null && password != null) {
		username = username.trim();
		password = password.trim();
		try {
			user = elab.authenticate(username, password);
		}
		catch (AuthenticationException e) {
		    request.setAttribute("exception", e);
			e.printStackTrace();
		}
	}
	if (user != null) {
		//login successful
		ElabGroup.setUser(session, user);
		String prevPage = request.getParameter("prevPage");
		String redirect = prevPage; 
		if(prevPage == null) {
    		prevPage = elab.getProperties().getLoggedInHomePage();
		}
		
		// I finally found the solution to the double login problem, and it's this
        // one line.  :)  Please don't remove.
        //
        // [Mihael] Seems like it depends where this page is included from
        // The servlet API docs state: "The cookie is visible to all the pages 
        // in the directory you specify [figured by Tomcat based on the page setting
        // the cookie. N.M.], and all the pages in that directory's subdirectories."
        //
        // Consequently the path could be "/elab", which would make the session
        // (and the login) persistent across elabs, or "/elab/"+elab.getName()
        // which would restrict it to the current elab
        //
        // At this point the user object contains information initialized from
        // the elab, so in order for certain things to work properly (user directories)
        // that object needs to be re-created for each elab.
        
        Cookie elabSessionCookie = new Cookie("JSESSIONID", session.getId());
        elabSessionCookie.setPath("/elab/" + elab.getName());
        response.addCookie(elabSessionCookie);
        
        Cookie elabDWRSessionCookie = new Cookie("JSESSIONID", session.getId());
        elabDWRSessionCookie.setPath("/elab/dwr");
        response.addCookie(elabDWRSessionCookie);
        

        // Forum authentication the quick-N-dirty way.
        // To allow a teacher to seamlessly access the forums after
        // login do the following:
        //  1. verify it's a teacher login, and get teacher ID #
        //  2. From teacher table get "authenticator"
 		//  3. Set cookie named "auth" with value of the authenticator
		//     with path "/" and expiration timestamp for end of session
        if (user.getRole().equals(ElabGroup.ROLE_TEACHER)) {
        	String authenticator = user.getAuthenticator();
        	Cookie authenticationCookie = new Cookie("auth",  authenticator);
        	authenticationCookie.setPath("/");
            response.addCookie(authenticationCookie);
            if (password.length() < 6) {
            	redirect = "small-password.jsp?prevPage=" + URLEncoder.encode(prevPage);
            }
        }  
       	response.sendRedirect(redirect);
	}
	else {
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@page import="java.net.URLEncoder"%><html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Login to ${elab.properties.formalName}</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/login.css"/>
	</head>
	
	<body id="login">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<!-- no nav here -->
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1><%= message %></h1>

<table border="0" id="main">
	<tr>
		<td>
			<div id="left">
			</div>
		</td>
		<td>
			<div id="center">
				<c:if test="${exception != null}">
					<span class="warning">${exception.message}</span>
				</c:if>
				<div id="login-form-contents">
					<%@ include file="login-form.jsp" %>
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
