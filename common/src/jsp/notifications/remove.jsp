<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>

<%
    String id = request.getParameter("id");
	ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
	boolean hard = "true".equals(request.getParameter("hard"));
	if (hard) {
		np.removeNotification(user, Integer.parseInt(id));
	}
	else {
		np.markAsDeleted(user, Integer.parseInt(id));
	}
%>