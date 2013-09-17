<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<%
	{
		ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
		List<Notification> n = np.getSystemNotifications(ElabNotificationsProvider.MAX_COUNT);
		request.setAttribute("notifications2", n);
	}
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>		
	</head>
	
	<body id="manage-notifications" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav-teacher.jsp" %>
					</div>
				</div>
			</div>
			
			<div id="content">
<h1>Notifications</h1>
<fmt:timeZone value="UTC">
	<table border="0" cellspacing="2" id="notifications-table-detailed">
		<c:choose>
			<c:when test="${!empty notifications2}">
				<tr>
					<th>Time</th><th>Expires</th><th>Group</th><th>Priority</th><th>Message</th><th></th>
				</tr>
				<c:forEach var="notifications" items="${notifications2}">
					<tr>
						<td><fmt:formatDate type="both" value="${notifications.timeAsDate}"/></td>
						<td><fmt:formatDate type="both" value="${notifications.expirationAsDate}"/></td>
						<td>${notifications.creatorGroupId}</td>
						<td>${notifications.type}</td>
						<td>${notifications.message}</td>
						<td width="2%">
							<a href="javascript:removeNotification('next', ${notifications.id}, '${elab.name}', true)"><img src="../graphics/notification-remove.png" /></a>
						</td>						
					</tr>
				</c:forEach>
			</c:when>
			<c:otherwise>
				<tr><td>There are no notifications</td></tr>
			</c:otherwise>
		</c:choose>
	</table>
</fmt:timeZone>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>