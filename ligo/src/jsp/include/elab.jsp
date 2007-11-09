<%@ page import="gov.fnal.elab.Elab" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>

<%
	Elab elab = Elab.getElab(pageContext, "ligo");
	request.setAttribute("elab", elab);
	request.setAttribute("user", ElabGroup.getUser(session));
%>