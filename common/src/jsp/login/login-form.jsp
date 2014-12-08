<%
	String prevPage = request.getParameter("prevPage");
	if (prevPage == null) {
		prevPage = elab.getProperties().getLoggedInHomePage();
	}
	String login_as = request.getParameter("login_as");
	request.setAttribute("login_as", login_as);
	request.setAttribute("prevPage", prevPage);
%>
<form method="post" action="<%= elab.secure("login/login.jsp") %>">
	<table>
		<tr>
			<td class="form-label">
				<label for="user">Username:</label>
			</td>
			<td class="form-control">
				<input type="text" id="user" name="user" size="16" tabindex="1" />
				<script type="text/javascript">
					document.getElementById("user").focus();
				</script>
			</td>
		</tr>
		<tr>
			<td class="form-label">
				<label for="pass">Password:</label>
			</td>
			<td class="form-control">
				<input type="password" id="pass" name="pass" size="16" tabindex="2" />
			</td>
		</tr>
		<tr>
			<td class="form-label">
			</td>
			<td class="form-control">
				<input class="login-button" type="submit" name="login" value="Login" tabindex="3" />
			</td>
		</tr>
		<% if (login_as != null && login_as.equals("teacher")) { %>
			<tr>
				<td colspan="2"><a href="../login/retrieve-username-password.jsp">Forgot username/password?</a></div>
			</tr>
		<% } %>
	</table>
	<input type="hidden" name="project" value="${elab.name}" />
	<input type="hidden" name="prevPage" value="${prevPage}" />
	<c:forEach var="e" items="${postParams}">
		<c:forEach var="v" items="${e.value}">
			<input type="hidden" name="${e.key}" value="${v}" />
		</c:forEach>
	</c:forEach>
	<%
		session.removeAttribute("postParams");
	%>
</form>