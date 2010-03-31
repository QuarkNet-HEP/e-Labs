<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
    List<Notification> l = np.getSystemNotifications();
    List<Notification> nl = new ArrayList<Notification>();
    for (Notification n : l) {
        if (n.getPriority() == Notification.PRIORITY_SYSTEM_MESSAGE) {
            nl.add(n);
        }
    }
    request.setAttribute("notifications", nl);
%>

<c:if test="${!empty notifications}">
	<div id="news-box">
		<c:forEach var="n" items="${notifications}">
			<div id="news-box-header">News Alert</div>
			<div id="news-box-contents">${n.message}</div>
			<div id="news-box-footer">${n.timeAsDate}</div>
		</c:forEach>
	</div>
</c:if>
	