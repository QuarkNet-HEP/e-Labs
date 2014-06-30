<%
 //save changes when submitting
String reqType = request.getParameter("submitButton");
if ("Save Changes".equals(reqType)){
	String newEmail = request.getParameter("newEmail");
	if (newEmail != null && !newEmail.equals("")) {
		user.setEmail(newEmail);
  	    elab.getUserManagementProvider().updateEmail(user.getName(), newEmail);
	}
}

String email = user.getEmail();
request.setAttribute("email", email);

%>
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
