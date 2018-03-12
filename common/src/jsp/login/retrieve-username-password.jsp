<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="java.net.URLEncoder"%>

<%
/* CAPTCHA removed 12Mar2018. If restoring it, refer to SVN rev 9958 - JG */

//EPeronja-577:Allow teachers to reset their passwords and/or retrieve usernames by providing an e-mail address.
String userid = request.getParameter("userid");
String email = request.getParameter("email");
String message = "", to = "", subject = "", user_name = "", temp_password = "";
String emailBody = "";
String submit = request.getParameter("submitButton");
String pageMessage = "";
boolean sendEmail = false;

// Predefine some message Strings:
// password reset request (teacher)
String rptSubject = "Your password has been reset";
String rptBodyBegin = "Someone used the webform at "+
					  "\'https://www.i2u2.org/elab/cosmic/login/retrieve-username-password.jsp\' to reset "+
					  "the e-Lab password for the account: replaceAccount.\n\n" + 
					  "The temporary password is: replacePassword.\n\n";
String rptUIMsg = "We have sent a temporary password to the e-mail associated with this account.<br />Please check that account for a message from e-labs-NOREPLY@nd.edu.";
String rptInstructions = "You must login in and create a new password using the following steps:\n"+
	  					 "1. Login\n"; 
//password reset request (not a teacher)
String rpoSubject = "Reset password attempt";
String rpoBodyBegin = "One of your e-Lab groups: replaceGroup sent a request to reset their password." +
					   " Only the teacher that created the account can do that. Here\'s how:\n\n";
String rpoInstructions = "1. Login to the teacher account that set up the replaceGroup account\n";
String rpoUIMsg = "We have sent directions on how to change this password for you to the e-mail associated with this account.<br />" +
				   "Please check that account for a message from e-labs-NOREPLY@nd.edu.<br />";
String instructions =   "2. Go to the registration page\n"+
						"3. Select \'Update your research groups including passwords\'\n"+
						"4. Choose your username from the dropdown and click on the \'Show Info\' button\n"+
						"5. Enter your new password and click \'Save\'\n\n";
String instructionsEnd = "\nPlease send any questions to e-labs@fnal.gov.";
String rpoError = "There is no e-mail associated with the username you entered.<br /> "+
		  		  "We cannot reset the password at the moment.<br />";
//retrieve username request
String runSubject = "Your username";
String runBodyBegin = "We have found the following username(s) associated with the e-mail address: replaceEmail\n\n";
String runUIMsg = "We have sent a list of e-Lab logins associated with the e-mail address you provided."+
				  "<br />Please check that account for a message from e-labs-NOREPLY@nd.edu.<br />";
String runError = "There are no usernames associated with the e-mail address: ";
String footerMessage = "<br />Questions? Please contact <a href=\'mailto:e-labs@fnal.gov\'>e-labs@fnal.gov</a>.<br />" +
		  "<a href=\'../teacher/index.jsp\'>Log in</a>";		

// If they want to reset password
if ("Reset Password".equals(submit)) {
	if (userid != null && !userid.equals("")) {
		// test if the username entered is a teacher...
		String userRole = elab.getUserManagementProvider().getUserRole(userid);
		String userEmail = elab.getUserManagementProvider().getEmail(userid);
		// if the entered email address exists
		if (userEmail != null && !userEmail.equals("")) {
			// check user role
			if (userRole.equals("teacher")) {
				// go ahead and reset password
				temp_password = elab.getUserManagementProvider().resetPassword(userid);
			  user_name = userid;
				to = userEmail;
				subject = rptSubject;
				rptBodyBegin = rptBodyBegin.replace("replaceAccount", user_name);
				rptBodyBegin = rptBodyBegin.replace("replacePassword", temp_password);
			    emailBody = rptBodyBegin +
			    			rptInstructions +
				   		    instructions +
				   		    instructionsEnd;
			    rptUIMsg = rptUIMsg.replace("replaceEmail", to);
				pageMessage = rptUIMsg;
			} else {
			   	user_name = userid;
				to = userEmail;
				subject = rpoSubject;
				rpoBodyBegin = rpoBodyBegin.replace("replaceGroup", user_name);
				rpoInstructions = rpoInstructions.replace("replaceGroup", user_name);
			    emailBody = rpoBodyBegin +
			    		   rpoInstructions + 
						   instructions +
						   instructionsEnd;
			    rpoUIMsg = rpoUIMsg.replace("replaceEmail", to);
				pageMessage = rpoUIMsg;				
			}
			sendEmail = true;
		} else {
			message = rpoError;
		}
	} else {
			// I think the original line here was a C&P error.  JG 28Mar2016
	    //if (userid != null && !userid.equals("")) {
      if (userid != null && userid.equals("")) {
		message = "Username is blank.<br />";
	    }
	}
} // end of checking password reset

// If they just want to retrieve username
if ("Retrieve Username".equals(submit)) {
   	if (email != null && !email.equals("")) {
   		String[] user = elab.getUserManagementProvider().getUsernameFromEmail(email);
		if (user != null) {
			user_name = "\n";
			for (int i = 0; i < user.length; i++) {
				user_name = user[i] + "\n";				
			}
		  to = email;
			subject = runSubject;
			runBodyBegin = runBodyBegin.replace("replaceEmail",to);
		  emailBody = runBodyBegin + 
		    			user_name +
		    			instructionsEnd;
		  runUIMsg = runUIMsg.replace("replaceEmail", to);
			pageMessage = runUIMsg; 
			sendEmail = true;
		} else {
			message = runError + email;
		}
    } else {
      // I think the original line here was a C&P error.  JG 28Mar2016
      //if (email != null && !email.equals("")) {
    	if (email != null && email.equals("")) {
					message = "Email address is blank.<br />";
    	}
    }
} // end of checking retrieve username	
if (sendEmail) {
   	String result = elab.getUserManagementProvider().sendEmail(to, subject, emailBody);
	if (result != null && result.equals("")) {
	   	message = pageMessage;
	} else {
		message = "Error: unable to send message. " + result + "<br />";
	}	
}
if (!message.equals("")) {
	message = message + footerMessage;	
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
	<script>
	 	window.onload = function() {
			$("retrieve-username-password-form").Show();
		};
	</script>
</head>

<body id="retrieve-username-password" >
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
	<p>${message}</p>
	
	<form id="retrieve-username-password-form" method="post">	
	<h1>Please fill out the username to reset your password or the email address to retrieve your username.</h1>		
	<ul>
		<li>This tool is for resetting the passwords of teachers.</li>
		<li>To change or reset the passwords associated with student research groups, log in and go to the Registration page.</li>
	</ul>
		<table border="0" id="main">
			<tr>
				<td><br />Username: <input type="text" name="userid" id="userid"></input> <input type="submit" name="submitButton" value="Reset Password" /></td>
			</tr>
			<tr>
				<td><br />OR</td>
			</tr>			
			<tr>
				<td><br />E-mail address: <input type="text" name="email" id="email"></input> <input type="submit" name="submitButton" value="Retrieve Username" /></td>
			</tr>		
		</table>
	</form>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
