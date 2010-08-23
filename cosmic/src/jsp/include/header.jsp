<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>

<%
	boolean loggedIn = ElabGroup.isUserLoggedIn(session);
	request.setAttribute("loggedin", loggedIn);
	if (loggedIn) {
	    ElabGroup group = ElabGroup.getUser(session);
	    request.setAttribute("username", group.getName());
	}
%>
<div id="header-image">
	<img src="<%= "/elab/cosmic/graphics/blast.jpg" %>" alt="Cosmic Ray Blast" />
</div>
<div id="header-title">Cosmic Ray e-Lab</div>
<c:choose>
	<c:when test="${loggedin}">
		<div id="header-toolbar">
			<c:choose>
				<c:when test="${user.teacher}">
					<e:popup href="/elab/cosmic/teacher/forum/HelpDeskRequest.php" target="helpdesk" width="800" height="600"><img title="Helpdesk" src="../graphics/helpdesk.png" /></e:popup>
					<e:popup href="../jsp/showLogbookT.jsp" target="log" width="800" height="600"><img title="Logbook" src="../graphics/logbook.png" /></e:popup>
				</c:when>
				<c:otherwise>
					<e:popup href="../jsp/showLogbook.jsp" target="log" width="800" height="600"><img title="Logbook" src="../graphics/logbook.png" /></e:popup>
				</c:otherwise>
			</c:choose>
			
			<%-- Temporarily disable notifications while I work on this
			<a href="#" onClick="javascript:displayNotifications();">
				<img id="notifications-icon" title="Notifications" src="../notifications/icon.jsp?elab=${elab.name}" />
			</a>
			
			<script type="text/javascript" src="../include/notifications.js"></script>
			<div id="notifications-popup" style="display: none">
				<h1>Notifications</h1>
				<div class="hr"></div>
				<div id="notifications-table-container">
					<%@ include file="../notifications/table.jsp" %>
				</div>
				<div class="hr"></div>
				<a href="../notifications/index.jsp">See all notifications</a>
				<c:choose>
					<c:when test="${user.admin}">
						<div class="hr"></div>
						<a href="../notifications/send-to-all.jsp">Send system notifications</a>
						<br />
						<a href="../notifications/manage.jsp">Manage system notifications</a>
					</c:when>
					<c:when test="${user.teacher}">
						<div class="hr"></div>
						<a href="../notifications/send-to-groups.jsp">Send notifications to your groups</a>
					</c:when>
				</c:choose>
			</div>
			 --%>
			<a id="username" href="../login/user-info.jsp"><span class="toolbar-text-link">${username}</span></a>
			<a href="../login/logout.jsp"><span id="logout" class="toolbar-text-link">Log out</span></a>
		</div>
		<span id="toolbar-error-text"></span>
		<c:set var="headerIncluded" value="true" scope="request"/>
		<% out.flush(); %>
		
		<%@ include file="../analysis/async-update.jsp" %>
		<script language="JavaScript" type="text/javascript">
			registerUpdate("../include/toolbar-async.jsp", 
					function(data, error) {
						updateHeader(data, error, '${elab.name}');
					}, 5000, 5000);
		</script>
	</c:when>
</c:choose>