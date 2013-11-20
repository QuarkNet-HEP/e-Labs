<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>

<%
	String id = request.getParameter("id");
	ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
	np.markAsDeleted(user, Integer.parseInt(id));
%>