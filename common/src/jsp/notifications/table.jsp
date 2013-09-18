<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>

<%
	if (ElabGroup.isUserLoggedIn(session) && session.getAttribute("elab") != null) {
	    ElabGroup group = ElabGroup.getUser(session);
	    request.setAttribute("username", group.getName());
	    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
	    List<Notification> n = np.getNotifications(group, 10, "true".equals(request.getParameter("unread")));
	    request.setAttribute("notifications", n);
	}
%>
<table border="0" id="notifications-table">
	<c:forEach var="n" items="${notifications}">
		<tr id="not${n.id}">
			<td>${n.message}</td>
			<td class="remove">
				<a href="javascript:markAsDeleted('not', ${n.id}, '${elab.name}')"><img src="../graphics/notification-remove.png" /></a>
			</td>
		</tr>
	</c:forEach>
</table>