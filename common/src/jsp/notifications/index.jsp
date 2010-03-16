<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<%
	{
		ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
		request.setAttribute("notifications", np.getNotifications(user, ElabNotificationsProvider.MAX_COUNT, true));
	}
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/home.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="notifications" class="home">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">
<h1>Notifications</h1>
<fmt:timeZone value="UTC">
	<table border="0" cellspacing="2" id="notifications-table-detailed">
		<c:choose>
			<c:when test="${!empty notifications}">
				<c:forEach var="n" items="${notifications}">
					<tr id="next${n.id}">
						<td width="24%">
							<fmt:formatDate type="both" value="${n.timeAsDate}"/>
						</td>
						<td>
							${n.message}
						</td>
						<td width="2%">
							<c:if test="${n.groupId != -1}">
								<a href="javascript:markAsDeleted('next', ${n.id}, '${elab.name}')"><img src="../graphics/notification-remove.png" /></a>
							</c:if>
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