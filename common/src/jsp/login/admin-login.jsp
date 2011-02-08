<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.usermanagement.AuthenticationException" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%
	String adminUsername = request.getParameter("adminuser"); 
	String username = request.getParameter("user");
	String password = request.getParameter("adminpass");
	String message  = request.getParameter("message");
	if (message == null) {
		message = "Please log in to proceed";
	}
	
	AuthenticationException exception = null;
	boolean success = false;
	
	ElabGroup user = null;
	if (StringUtils.isNotBlank(username) && StringUtils.isNotBlank(password) && StringUtils.isNotBlank(adminUsername)) {
		adminUsername = adminUsername.trim(); 
		username = username.trim();
		
		try {
			user = elab.adminAuthenticateAsOther(adminUsername, password, username); 
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
                
        Cookie elabTLASessionCookie = new Cookie("JSESSIONID", session.getId());
        elabTLASessionCookie.setPath("/ligo/tla");
        response.addCookie(elabTLASessionCookie);
        
        if (!request.getParameterMap().isEmpty()) {
        	request.setAttribute("pmap", request.getParameterMap());
        	%>
        		<html>
        			<head>
        				<title>Log-in redirect page</title>
        			</head>
        			<body>
        				<form name="redirect" method="post" action="${param.prevPage}">
        					<c:forEach var="e" items="${pmap}">
        						<c:if test="${e.key != 'user' && e.key != 'pass' && e.key != 'login' && e.key != 'project' && e.key != 'prevPage'}">
        							<c:forEach var="v" items="${e.value}">
        								<input type="hidden" name="${e.key}" value="${v}" />
        							</c:forEach>
        						</c:if>
        					</c:forEach>
        					If you are not redirected automatically, please click the following button:
        					<input type="submit" name="loginredirsubmit" value="Redirect" />
        				</form>
        				<script language="JavaScript">
        					document.redirect.submit();
        				</script>
        			</body>
        		</html>
        	<%
        }
        else {
			response.sendRedirect(prevPage);
		}

        // Forum authentication the quick-N-dirty way.
        // To allow a teacher to seamlessly access the forums after
        // login do the following:
        //  1. verify it's a teacher login, and get teacher ID #
        //  2. From teacher table get "authenticator"
		//  3. Set cookie named "auth" with value of the authenticator
		//     with path "/" and expiration timestamp for end of session

        String authenticator = "-bogus-";
        if (user.isTeacher()) {
		    String x = user.getAuthenticator();
            if( x != null ) authenticator = x;

            if (password.length() < 6) { // Why not everybody? -EAM 10Jun2009 
            		                     // only teachers have access to the password change page
            	redirect = "small-password.jsp?prevPage=" + URLEncoder.encode(prevPage);
            }
        }  
        Cookie authenticationCookie = new Cookie("auth",  authenticator);
        authenticationCookie.setPath("/");
        response.addCookie(authenticationCookie);

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
					<%@ include file="admin-login-form.jsp" %>
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
