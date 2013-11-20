<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>

<%
	if (ElabGroup.isUserLoggedIn(session) && session.getAttribute("elab") != null) {
	    ElabGroup group = ElabGroup.getUser(session);
	    request.setAttribute("username", group.getName());
	    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
	    //added library path to avoid conflicts
	    java.util.List<Notification> n = np.getNotifications(group, 10, "true".equals(request.getParameter("unread")));
	    request.setAttribute("notifications", n);
	}
%>
<table border="0" id="notifications-table">
	<th></th><th>Read?</th>
	<c:forEach var="n" items="${notifications}">
		<tr id="not${n.id}">
			<td>${n.message}</td>
			<td class="remove" style="text-align: center;">
				<a href="javascript:markAsDeleted('not', ${n.id}, '${elab.name}')"> &#10004;</a>
			</td>
		</tr>
	</c:forEach>
</table>