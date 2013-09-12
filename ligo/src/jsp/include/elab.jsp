<%@ page import="gov.fnal.elab.Elab" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>

<%@ include file="../login/session-invalidator.jspf" %>

<%
	Elab elab = Elab.getElab(pageContext, "ligo");
	//EPeronja-09/11/2013: Added next line for notifications
	session.setAttribute("elab", elab);
	request.setAttribute("elab", elab);
	request.setAttribute("user", ElabGroup.getUser(session));
%>