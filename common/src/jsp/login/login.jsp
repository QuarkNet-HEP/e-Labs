<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.usermanagement.AuthenticationException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.commons.codec.net.URLCodec" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%
// Set page-scoped variables and request Attributes from the request parameters
String username = request.getParameter("user");
String password = request.getParameter("pass");
String message  = request.getParameter("message");
String guestlogin = elab.getGuestLoginLinkSecure(request);
String prevPageSecure = elab.getSecureUrl(request.getParameter("prevPage"));
int loginCountPerUser = SessionListener.getUserLoginsCount(username);
request.setAttribute("username", username);
request.setAttribute("guestlogin", guestlogin);
%>
<%-- Set the email contact to be shown on the error page --%>
<c:set var="accountEmail"
			 value="<a href='mailto:e-labs@fnal.gov'>e-labs@fnal.gov</a>" />
<%-- Determine maxLogins and extraMessage based on whether login is "guest" or other user --%> 
<%-- These can be specified in elab.properties, but we provide defaults here if they aren't --%>
<c:choose>
		<c:when test="${param.user=='guest'}">
				<c:set var="maxLogins" scope="request"
							 value="#{elab.getProperty('guest_maxlogins')}" />
				<c:if test="${maxLogins==null} || ${maxLogins==''}">
						<c:set var="maxLogins" scope="request" value="${10}" />
				</c:if>
				<c:set var="extraMessage"
							 value="To request an e-Lab account, contact us at ${accountEmail}. If you already have an e-Lab account, please use it." />
		</c:when>
		<c:otherwise> <%-- when ${param.user != 'guest'} --%>
				<c:set var="maxLogins" scope="request"
							 value="#{elab.getProperty('username_maxlogins')}" />
				<c:if test="${maxLogins==null} || ${maxLogins==''}">
						<c:set var="maxLogins" scope="request" value="${5}" />
				</c:if>
				<c:set var="extraMessage"
							 value="If you think this message is in error, please contact us at ${accountEmail} with your name and the username of the account you're attempting to log into." />
		</c:otherwise>
</c:choose>
<%-- Check if the login exceeds maxLogins --%>
<c:set var="maxLoginsReached" value="false" />
<c:set var="message" value="" />
<c:if test="${loginCountPerUser > maxLogins}" >
		<c:set var="maxLoginsReached" value="true" />
		<c:set var="message"
					 value="This user has reached the maximum number of allowed simultaneous logins.<br /> ${extraMessage}" />
</c:if>
<%-- Set the message for the error page (below) to the Request scope --%>
<c:set var="message" value="${message}" scope="request" />

<%
AuthenticationException exception = null;
boolean success = false;
//Boolean maxLoginsReached = (Boolean) pageContext.getAttribute("maxLoginsReached");

// authentication and login logic
//if (!maxLoginsReached) {
// This is literally what you have to do to pass a boolean from JSTL > scriptlet
if(!(Boolean.parseBoolean((String)pageContext.getAttribute("maxLoginsReached")))) {
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
				session.setAttribute("user", user);
				String prevPage = request.getParameter("prevPage");
				if (username.equals("admin")) {
	          prevPage = "../admin/index.jsp";
				}
				
				//get these numbers now and save them to the session
	 			if (elab.getName().equals("cosmic")) {
						DataCatalogProvider dcp = elab.getDataCatalogProvider();
						int fileCount = dcp.getUniqueCategoryCount("split");
						int schoolCount = dcp.getUniqueCategoryCount("school");
						int stateCount = dcp.getUniqueCategoryCount("state");		
						session.setAttribute("cosmicFileCount", String.valueOf(fileCount));
						session.setAttribute("cosmicSchoolCount", String.valueOf(schoolCount));
						session.setAttribute("cosmicStateCount", String.valueOf(stateCount));
						ElabUserManagementProvider p = elab.getUserManagementProvider();
						CosmicElabUserManagementProvider cp = null;
						if (p instanceof CosmicElabUserManagementProvider) {
								cp = (CosmicElabUserManagementProvider) p;
						}
						else {
								throw new ElabJspException("The user management provider does not support management of DAQ IDs. " + 
										"Either this e-Lab does not use DAQs or it was improperly configured.");
						}
						Collection allDaqs = cp.getAllDetectorIds();
	      	  session.setAttribute("allDaqs", allDaqs);
				}
				
				//String redirect = prevPage;
				String redirect = prevPageSecure;
				if(prevPage == null) {
	    			prevPage = elab.getProperties().getLoggedInHomePage();
				}
				
				// By default, Tomcat sets a JSESSIONID cookie with the path of
				// the webapp, which for the e-Labs is "/elab/".
				// We want separate sessions for each e-Lab, though, which
				// means separate JSESSIONIDs and separate cookies with
				// path="/elab/{e-Lab name}/".
				//
				// session-invalidator.jspf, included here via elab.jsp,
				// deletes the path="/elab/" cookie. To replace it, we
				// now set a path="/elab/"+elab.getName() cookie, plus others.
				//  - JG 6Feb2018
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
				<form name="redirect" method="post" action="${page.prevPageSecure}">
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
				else { // if (request.getParameterMap().isEmpty)
						//response.sendRedirect(prevPage);
						// For https:
						response.sendRedirect(prevPageSecure);
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
	       					redirect = "small-password.jsp?prevPage=" + prevPage;
						}
				}  

				Cookie authenticationCookie = new Cookie("auth",  authenticator);
				authenticationCookie.setPath("/");
				response.addCookie(authenticationCookie);
				
				response.sendRedirect(redirect);
		} // end if(user != null)
		else { // if (user == null)
						%>		
						<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

						<%@page import="java.net.URLEncoder"%>
						<html xmlns="http://www.w3.org/1999/xhtml">
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
																				<div id="left"></div>
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
																										<a href="${fn:escapeXml(guestlogin)}">Login as guest</a>
																								</p>
																						</div>
																				</div>
																		</td>
																		<td>
																				<div id="right"></div>
																		</td>
																</tr>
														</table>
												</div>
												<!-- end content -->	
												
												<div id="footer"></div>
										</div>
										<!-- end container -->
								</body>
						</html>
						
	<%
	} // end else(user == null)
	} else { // if(maxLoginsReached)
	%>

	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	
	<html xmlns="http://www.w3.org/1999/xhtml">
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
									<h2>Need a student login?</h2>
									<p>Ask your teacher.</p>
									<h2>If you are a student and forgot your username/password:</h2>
									<p>Ask your teacher.</p>
									
									<%
									String subject = URLEncoder.encode(elab.getName() + " elab account request");
									String body = URLEncoder.encode("Please complete each of the fields below and send this email to be registered " 
											+ "as an e-Labs teacher. You will receive a response from the e-Labs team by the end of the business "
											+ "day.\n\n"
											+ "First Name:\n\n"
											+ "Last Name:\n\n"
											+ "City:\n\n"
											+ "State:\n\n"
											+ "School:\n");
									String mailURL = "mailto:e-labs@fnal.gov?Subject=" + subject + "&Body=" + body;
									%>
									<h2>Need a teacher login?</h2>
									<p>Contact 
											<a href="<%= mailURL %>">e-labs@fnal.gov</a>.
									</p>
									<h2>If you are a teacher and forgot your username/password:</h2>
									<p>
											<td colspan="2"><a href="../login/retrieve-username-password.jsp">Forgot username/password?</a></div>
									</p>	
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
