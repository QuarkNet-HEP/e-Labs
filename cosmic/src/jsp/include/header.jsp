<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>


<div id="header-image">
	<img src="<%= "/elab/cosmic/graphics/blast.jpg" %>" alt="Cosmic Ray Blast">
</div>
<div id="header-title">Cosmic Ray e-Lab</div>
<%
	if (ElabGroup.isUserLoggedIn(session)) {
		%>
			<div id="header-current-user">
				Logged in as group: 
					<a href="../login/user-info.jsp"><%= ElabGroup.getUser(session).getName() %></a>				
			</div>
			<div id="header-logout">
				<a href="../login/logout.jsp">Logout</a>
			</div>
			<div id="header-logbook">
				<e:popup href="../logbook/index.jsp" target="log" width="800" height="600">My Logbook</e:popup>
			</div>
		<%
	}
	request.setAttribute("headerIncluded", Boolean.TRUE);
%>
