<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>

<%-- PINEBARREN --%>
<c:if test="${pageContext.request.getSession(false) != null}">
		<%
		if (ElabGroup.isUserLoggedIn(session) && session.getAttribute("elab") != null) {
				ElabGroup group = ElabGroup.getUser(session);
				request.setAttribute("username", group.getName());
				ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
				//added library path to avoid conflicts
				java.util.List<Notification> n = np.getNotifications(group, -1, "true".equals(request.getParameter("unread")));
				request.setAttribute("notifications", n);
		}
		%>
</c:if>
<%-- /PINEBARREN --%>
<div id="notification-wrapper" style="height: 200px; overflow: auto;">
	<table border="0" id="notifications-table">
		<c:forEach var="n" items="${notifications}">
				<tr id="not${n.id}">
					<td>${n.message}</td>
					<td class="remove" style="text-align: center;">
						<a href="javascript:markAsRead('not', ${n.id})">New</a>
					</td>
				</tr>
		</c:forEach>
	</table>
</div>
