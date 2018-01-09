<%@ page import="gov.fnal.elab.Elab" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %><%-- PINEBARREN --%>

<%-- PINEBARREN --%>
<%-- <%@ include file="../login/session-invalidator.jspf" %> --%>

<%-- PINEBARREN --%>
<%
if(session != null) {
		Elab elab = Elab.getElab(pageContext, "cosmic");
		session.setAttribute("elab", elab);
		request.setAttribute("elab", elab);
		request.setAttribute("user", ElabGroup.getUser(session));
		session.setAttribute("environment", (String) elab.getProperty("environment"));
}
%>
<%-- /PINEBARREN --%>
