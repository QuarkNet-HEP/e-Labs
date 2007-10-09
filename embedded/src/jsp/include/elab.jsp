<%@ page import="gov.fnal.elab.Elab" %>

<%
	Elab elab = Elab.getElab(pageContext, "embedded");
	request.setAttribute("elab", elab);
%>