<%
	String prevPage = request.getParameter("prevPage");
	if (prevPage == null) {
		prevPage = elab.getProperties().getLoggedInHomePage();
	}
%>
<form method="post" action="<%= elab.getProperties().getLoginURL() %>">
	<table border="0">
		<tr>
			<td class="form-label">
				<label for="user">Username:</label>
			</td>
			<td class="form-control">
				<input type="text" name="user" size="16" tabindex="1">
			</td>
		</tr>
		<tr>
			<td class="form-label">
				<label for="pass">Password:</label>
			</td>
			<td class="form-control">
				<input type="password" name="pass" size="16" tabindex="2">
			</td>
		</tr>
		<tr>
			<td class="form-label">
			</td>
			<td class="form-control">
				<input class="login-button" type="submit" name="login" value="Login" tabindex="3">
			</td>
		</tr>
	</table>
	<input type="hidden" name="project" value="<%= elab.getName() %>">
	<input type="hidden" name="prevPage" value="<%= prevPage %>">
</form>
