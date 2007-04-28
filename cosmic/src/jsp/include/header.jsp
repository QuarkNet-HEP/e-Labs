<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
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
					<a href="../login/user-info.jsp"><%= ElabUser.getUser(session).getName() %></a>				
			</div>
			<div id="header-logout">
				<a href="../login/logout.jsp">Logout</a>
			</div>
			<div id="header-logbook">
				<e:popup href="../logbook/index.jsp" target="log" width="800" height="600">My Logbook</e:popup>
			</div>
		<%
	}
%>