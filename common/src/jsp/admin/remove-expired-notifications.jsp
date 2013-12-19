<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%
	String submit = request.getParameter("submit");
	String messages = "";
	int totalExpiredNotifications = 0;
	ElabNotificationsProvider nprovider = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
	List<Notification> en = nprovider.getExpiredNotifications();
	if (en != null) {
		totalExpiredNotifications = en.size();
	}
	if ("Remove All".equals(submit)) {
		for (Notification rm: en) {
			nprovider.removeNotification(user.getGroup(), rm.getId());
		}
	}//end of submit
	
	if (totalExpiredNotifications == 0) {
		messages = "There are NO expired notifications.<br />";
	}
	request.setAttribute("messages", messages);
	request.setAttribute("expiredNotifications", en);
	
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Remove expired notifications</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<link rel="stylesheet" type="text/css" href="../css/teacher.css"/>
	</head>
	
	<body id="removeExpiredNotifications" class="teacher">
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
			<c:choose>
				<c:when test="${empty expiredNotifications}">
					<div style="width: 100%; text-align:center;">${messages}</div>
				</c:when>
				<c:otherwise>
					<form id="removeExpiredNotifications-form" method="post">
					<table>
						<tr><th>Time</th><th>Expires</th><th>Sender</th><th>Message</th><th>Remove</th></tr>
						<c:forEach var="n" items="${expiredNotifications}">
						<tr id="next${n.id}">
							<td width="22%"><fmt:formatDate type="both" value="${n.timeAsDate}"/></td>
							<td width="22%"><fmt:formatDate type="both" value="${n.expirationAsDate}"/></td>
							<td>${n.sender}</td>
							<td>${n.message}</td>
							<td><a href="javascript:removeNotification('next', ${n.id}, '${elab.name}')"><img src="../graphics/notification-remove.png" /></a></td>
						</tr>
						</c:forEach>
					</table>
					<div style="width: 100%; text-align:center;"><input type="submit" name="submit" value="Remove All"/></div>
					</form>
				</c:otherwise>
			</c:choose>
			</div>
			<!-- end content -->			
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>