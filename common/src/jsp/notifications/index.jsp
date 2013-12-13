<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page import="java.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%
	{
		ElabNotificationsProvider np = ElabFactory.getNotificationsProvider((Elab) session.getAttribute("elab"));
		List<Notification> n = np.getNotifications(user, ElabNotificationsProvider.MAX_COUNT, true);
		List<Integer> unreadIds = new ArrayList<Integer>();
		List<Integer> allIds = new ArrayList<Integer>();
		for (Notification x: n) {
			allIds.add(x.getId());
			if (!x.isRead()) {
				unreadIds.add(x.getId());
			}
		}
		request.setAttribute("isAdmin", user.isAdmin());
		request.setAttribute("allIds", allIds);
		request.setAttribute("newNotifications", unreadIds);
		request.setAttribute("notification", n);
	}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>${elab.properties.formalName} e-Lab Home</title>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../../cosmic/css/teacher.css"/>
		<script type="text/javascript" src="../include/notifications.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-1.4.3.min.js"></script>	
		<script type="text/javascript" src="../include/jquery/js/jquery.tablesorter.min.js"></script>
		<link type="text/css" rel="stylesheet" href="../include/jquery/css/blue/style.css" />
	</head>
	
	<body id="notifications" class="home">
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
<ul>
	<li>Click New to indicate you have read the message</li>
</ul>

<div style="width: 100%; text-align: right;">
	<c:choose>
		<c:when test="${not empty newNotifications }">
		<a href="javascript:markAllAsRead(${newNotifications})" style="text-decoration:none;">Mark All as Read</a>
		<br />
		</c:when>
	</c:choose>
	<c:choose>
		<c:when test="${not empty allIds}">
			<c:choose>
				<c:when test="${isAdmin == true}">
					<a href="javascript:removeAllNotification(${allIds}, '${elab.name}')" style="text-decoration:none;">Delete All</a>
				</c:when>  
				<c:otherwise>
					<a href="javascript:markAllAsDeleted(${allIds}, '${elab.name}')" style="text-decoration:none;">Delete All</a>
				</c:otherwise>
			</c:choose>
		</c:when>
	</c:choose>
</div>

	<table border="0" cellspacing="2" id="notifications-table-detailed">
		<thead>
			<tr>
				<th>Time</th>
				<th>Expires</th>
				<th>Sender</th>
				<c:choose>
					<c:when test="${isAdmin == true}">	
						<th>To</th>
					</c:when>
				</c:choose>			
				<th>Message</th>
				<th>Status</th>
				<th>Remove</th>
			</tr>
		</thead>
		<tbody>
			<c:choose>
				<c:when test="${!empty notification}">
					<c:forEach var="n" items="${notification}">
						<tr id="next${n.id}">
							<td width="22%"><fmt:formatDate type="both" value="${n.timeAsDate}"/></td>
							<td width="22%"><fmt:formatDate type="both" value="${n.expirationAsDate}"/></td>
							<td>${n.sender}</td>
							<c:choose>
								<c:when test="${isAdmin == true}">	
									<td>${n.addressee}</td>
								</c:when>
							</c:choose>
							<td>${n.message}</td>
							<td style="text-align: center;">
								<div id="status${n.id}" >
									<c:choose>
										<c:when test="${n.deleted == true}">
											Deleted
										</c:when>
										<c:otherwise>
											<c:choose>
												<c:when test="${n.read == true }">
													Read
												</c:when>
												<c:otherwise>
													<c:choose>
														<c:when test="${n.read == false }">
															<a href="javascript:markAsRead('status', ${n.id})" style="text-decoration:none;">New</a>
														</c:when>
														<c:otherwise>
															N/A
														</c:otherwise>
													</c:choose>
												</c:otherwise>
											</c:choose>
										</c:otherwise>
									</c:choose>								
								</div>
							</td>
							<td style="text-align: center;">
								<c:choose>
									<c:when test="${isAdmin == true}">
										<a href="javascript:removeNotification('next', ${n.id}, '${elab.name}')"><img src="../graphics/notification-remove.png" /></a>
									</c:when>  
									<c:otherwise>
										<a href="javascript:markAsDeleted('next', ${n.id}, '${elab.name}')"><img src="../graphics/notification-remove.png" /></a>
									</c:otherwise>
								</c:choose>
							</td>
						
						</tr>
					</c:forEach>
				</c:when>
				<c:otherwise>
					<tr><td>There are no notifications</td></tr>
				</c:otherwise>
			</c:choose>
		</tbody>
	</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>