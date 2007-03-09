<%@ page import="gov.fnal.elab.ElabUser" %>
<div id="header-image">
	<img src="<%= "/elab/cosmic/graphics/blast.jpg" %>" alt="Cosmic Ray Blast">
</div>
<div id="header-title">Cosmic Ray e-Lab</div>
<%
	if (ElabUser.isUserLoggedIn(session)) {
		%>
			<div id="header-current-user">
				Logged in as group: 
					<a href="<%= elab.page("modules/login/userinfo.jsp") %>"><%= ElabUser.getUser(session).getName() %></a>				
			</div>
			<div id="header-logout">
				<a href="<%= elab.page("modules/login/logout.jsp") %>">Logout</a>
			</div>
			<div id="header-logbook">
				<a href="<%= "javascript:openPopup('" + elab.page("modules/logbook/.jsp") + "','log',800,600)" %>">My Logbook</a>
			</div>
		<%
	}
%>