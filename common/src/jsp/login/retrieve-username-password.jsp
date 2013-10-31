<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.net.URLEncoder"%>

<%
String username = request.getParameter("username");
String email = request.getParameter("email");
request.setAttribute("username", username);
String message = "", to = "", subject = "", user_name = "", temp_password = "";
String submit = request.getParameter("submitButton");
boolean sendEmail = false;

if ("Reset Password".equals(submit)) {
	if (username != null && !username.equals("")) {
		String userEmail = elab.getUserManagementProvider().getEmail(username);
		//EPeronja: this is code is for testing purposes. Should the code stay, it needs to be moved to a class.
		if (userEmail != null && !userEmail.equals("")) {
			temp_password = elab.getUserManagementProvider().resetPassword(username);
		   	user_name = username;
			to = userEmail;
			subject = "Your password has been reset";
		} else {
			message = "There is no e-mail associated with this account. Please contact e-labs@fnal.gov to change your password.";
		}
	} else {
		message = "Username is blank.";
	}
}//end of checking password reset

if ("Retrieve Username".equals(submit)) {
   	if (email != null && !email.equals("")) {
   		String user = elab.getUserManagementProvider().getUsernameFromEmail(email);
		if (user != null && !user.equals("") && !user.equals("Multiple results")) {
		    temp_password = elab.getUserManagementProvider().resetPassword(user);
			user_name = user;
		    to = email;
			subject = "Your username and temporary password";
    } else {
    	message = "Email address is blank.";
    }
}//end of checking retrieve username
	
if (sendEmail) {
    String emailBody = "Temporary password for user: " +user_name + " " +
			   "is: "+temp_password+".\n"+
	   		   "Please, login and set a new password.\n\n" +
			   "Please do not reply to this message. Replies to this message go to an unmonitored mailbox.\n" +
	   		   "If you have any questions, send an e-mail to e-labs@fnal.gov.";
   	String result = elab.getUserManagementProvider().sendEmail(to, subject, emailBody);
	if (result != null && result.equals("")) {
	   	message = "Temporary password has been sent to: " + userEmail + ".\n" +
	       			 "If you are no longer using that e-mail address, please contact e-labs@fnal.gov.";
	} else {
		message = "Error: unable to send message. " + result;
	}	
}

request.setAttribute("message", message);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<title>Login to ${elab.properties.formalName}</title>
	<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
	<link rel="stylesheet" type="text/css" href="../css/login.css"/>
</head>

<body id="retrieve-username-password">
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
<c:choose>
<c:when test='${message == "" }'>
	<form id="retrieve-username-password-form" method="post">			
		<table border="0" id="retrieve">
			<tr><td><strong>Please fill out the username to reset your password or the email address to retrieve your username.</strong></td></tr>
			<tr>
				<td>Username: <input type="text" name="username" id="username"></input> <input type="submit" name="submitButton" value="Reset Password" /></td>
			</tr>
			<tr>
				<td>OR</td>
			</tr>
			<tr>
				<td>E-mail address: <input type="text" name="email" id="email"></input> <input type="submit" name="submitButton" value="Retrieve Username" /></td>
			</tr>
		</table>
	</form>
</c:when>
<c:otherwise>
	<p>${message}</p>
</c:otherwise>
</c:choose>
			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
