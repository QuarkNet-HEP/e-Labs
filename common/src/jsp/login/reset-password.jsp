<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.net.URLEncoder"%>
<%@ page import="java.io.*,java.util.*,javax.mail.*"%>
<%@ page import="javax.mail.internet.*,javax.activation.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%
	String username = request.getParameter("username");
	request.setAttribute("username", username);
	String message = "";
	String submit = request.getParameter("submitButton");
	if ("Reset".equals(submit)) {
	    try {
			String userEmail = elab.getUserManagementProvider().getEmail(username);
			if (userEmail != null && !userEmail.equals("")) {
				//String newPassword = elab.getUserManagementProvider().resetPassword(username);
				String newPassword ="it works";
			   	//Recipient's email
			   	String to = userEmail;
				//Sender's email ID 
			   	//String from = "e-labs@fnal.gov";
				final String from = "edit.peronja@gmail.com";
				final String password = "0693edit";
				String host = "localhost";
			    //Get system properties object
			    Properties properties = System.getProperties();
			    //Setup mail server
			    properties.put("mail.smtp.host", "smtp.gmail.com");
			    properties.put("mail.smtp.port", "587");
			    properties.put("mail.smtp.auth", "true");
			    properties.put("mail.smtp.starttls.enable", "true");			    
			    //Get the default Session object.
			    //Session mailSession = Session.getDefaultInstance(properties);
			   	Session mailSession = Session.getInstance(properties, new javax.mail.Authenticator() {
			   		protected PasswordAuthentication getPasswordAuthentication() {
			   			return new PasswordAuthentication(from, password );
			   		}
			   	});
			    try{
			       //Create a default MimeMessage object.
			       MimeMessage msg = new MimeMessage(mailSession);
			       //Set From: header field of the header.
			       msg.setFrom(new InternetAddress(from));
			       //Set To: header field of the header.
			       msg.addRecipient(Message.RecipientType.TO,
			                               new InternetAddress(to));
			       // Set Subject: header field
			       msg.setSubject("Your password has been reset");
			       // Now set the actual message
			       String emailBody = "Temporary password for user: " +username + " " +
			       					  "is: "+newPassword+".\n"+
			    		   			  "Please, login and set a new password.\n";
			       msg.setText(emailBody);
			       //Send message
			       Transport.send(msg);
			       message = "Temporary password has been sent to: " + userEmail;
			   }catch (MessagingException mex) {
			      mex.printStackTrace();
			      message = "Error: unable to send message. " + mex.toString();
			   }				
			} else {
				message = "There is no e-mail associated with this account. Please contact e-labs@fnal.gov to change your password.";
			}
		} catch (Exception e) {
			message = e.toString();
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
<c:choose>
<c:when test='${message == "" }'>
	<form id="reset-password" method="post">			
		<table border="0" id="main">
			<tr>
				<td>Username: ${username}</td>
			</tr>
			<tr>
				<td><input type="submit" name="submitButton" value="Reset" /></td>
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
