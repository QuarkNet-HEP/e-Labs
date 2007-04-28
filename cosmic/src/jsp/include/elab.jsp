<%@ page import="gov.fnal.elab.Elab" %>

<%
	Elab elab = Elab.getElab(pageContext, "cosmic");
	request.setAttribute("elab", elab);
%>