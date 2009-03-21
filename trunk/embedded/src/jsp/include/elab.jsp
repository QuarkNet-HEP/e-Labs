<%@ page import="gov.fnal.elab.Elab" %>

<%@ include file="../login/session-invalidator.jspf" %>

<%
	Elab elab = Elab.getElab(pageContext, "embedded");
	request.setAttribute("elab", elab);
%>