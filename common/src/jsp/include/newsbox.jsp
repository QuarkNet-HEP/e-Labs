<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.CatalogEntry" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.ParseException" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%-- Included in Teacher Home index.jsp pages --%>
<%-- This file appears to contain two attempts to enable a Newsbox on the Teacher Home page, which I'll call the 'Notifications' and 'Catalog' approaches.  Each has a scriptlet block and a JSP block.  The 'Notifications' approach appears not to have been functionally completed, though both its scriptlet and JSP blocks are enabled.  - JG 31Mar2021 --%>

<%
/// 'Notifications' scriptlet
ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
List<Notification> l = np.getSystemNotifications();
List<Notification> nl = new ArrayList<Notification>();
for (Notification n : l) {
    //    if (n.getPriority() == Notification.PRIORITY_SYSTEM_MESSAGE) {
    nl.add(n);
    //    }
}
request.setAttribute("notifications", nl);

/// 'Catalog' scriptlet
//old newsbox until I get notifications to work - EP
CatalogEntry e = elab.getDataCatalogProvider().getEntry("News_" + elab.getName() + "_status");
if (e != null) {
    request.setAttribute("e", e.getTupleMap());
    SimpleDateFormat sdf = new SimpleDateFormat("MMMM dd, yyyy 'at' hh:mm:ss aaa");
		sdf.setTimeZone(TimeZone.getTimeZone("America/Chicago"));
		request.setAttribute("now", new Date());
		if (e.getTupleValue("time") != null) {
				request.setAttribute("start", sdf.parse((String) e.getTupleValue("time")));
		}
		if (e.getTupleValue("expire") != null) {
				request.setAttribute("end", sdf.parse((String) e.getTupleValue("expire")));
		}
}

%>

<%-- 'Notifications' JSP.  If the "notifications" request attribute is not set by the 'Notifications' scriptlet, this will not be executed. --%>
<c:if test="${!empty notifications}">
	<div id="news-box">
		<div id="news-box-header">News Alert</div>
		<c:forEach var="n" items="${notifications}">
			<div id="news-box-contents">${n.message}</div>
			<div id="news-box-footer">${n.timeAsDate}</div>
		</c:forEach>
	</div>
</c:if>

<%-- 'Catalog' JSP.  This is what's currently active in the e-Labs, I think --%>
<c:if test="${(now > start) && (now < end)}">
	<div id="news-box">
		<div id="news-box-header">
			News Alert
		</div>
		<div id="news-box-contents">
			${e.description}
		</div>
		<div id="news-box-footer">
			Published ${start} 
		</div>
	</div>
</c:if>
