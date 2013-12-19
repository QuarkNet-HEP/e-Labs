<a href="#" id="notifications-link" onClick="javascript:displayNotifications();">
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
			<a href="../notifications/send-to-all.jsp">Send notifications</a>
			<br />
			<div class="hr"></div>
			<a href="../notifications/send-to-teachers.jsp">Send notifications to teachers only</a>
			<br />
			<div class="hr"></div>
			<a href="../notifications/manage.jsp">Manage NEWSBOX notifications</a>
		</c:when>
		<c:when test="${user.teacher}">
			<div class="hr"></div>
			<a href="../notifications/send-to-groups.jsp">Send notifications to your groups</a>
		</c:when>
	</c:choose>
</div>