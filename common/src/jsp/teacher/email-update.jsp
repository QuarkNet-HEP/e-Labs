<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/teacher-login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%

//save changes when submitting
String reqType = request.getParameter("submitButton");
if ("Save Changes".equals(reqType)){
	String newEmail = request.getParameter("newEmail");
	if (newEmail != null && !newEmail.equals("")) {
		user.setEmail(newEmail);
	}
}

String email = user.getEmail();
request.setAttribute("email", email);



%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Teacher e-mail</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
        <script type="text/javascript" src="../include/util-functions.js"></script>
        <script type="text/javascript" src="../include/clear-default-text.js"></script>
        <script>
        	function verifyEmail() {
        		var equalEmails = true;
        		var newEmail = document.getElementById("newEmail");
        		var confirmEmail = document.getElementById("confirmEmail");
    			var messages = document.getElementById("messages");
    			if (newEmail.value == '' || confirmEmail.value == '') {
        			messages.innerHTML = "<i>*One of the e-mail addresses entered is empty.</i>";
        			equalEmails = false;       			
        		}
        		if (newEmail.value != confirmEmail.value) {
        			messages.innerHTML = "<i>*The entered e-mail addresses must match.</i>";
        			equalEmails = false;
        		}
        		return equalEmails;
        	}
        </script>
	</head>
	
	<body id="register-students" class="teacher">
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

<h1>Teacher e-mail address</h1>		
<form name="emailUpdate">		
	<table>
		<tr>
			<td>Your e-mail on record:</td>
			<td>${email}</td>
		</tr>
		<tr>
			<td>Your new e-mail:</td>
			<td><input type="text" name="newEmail" id="newEmail"></input></td>
		</tr>
		<tr>
			<td>Confirm your new e-mail:</td>
			<td><input type="text" name="confirmEmail" id="confirmEmail"></input></td>
		</tr>	
		<tr>
			<td colspan="2"><div id="messages"></div></td>
		</tr>
		<tr>
			<td colspan="2"><input type="submit" name="submitButton" value="Save Changes" onclick="return verifyEmail();"></input></td>
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
