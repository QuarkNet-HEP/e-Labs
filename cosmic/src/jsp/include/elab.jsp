<%@ page import="gov.fnal.elab.Elab" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>

<%-- PINEBARREN --%>
<%-- <%@ include file="../login/session-invalidator.jspf" %> --%>

<%-- PINEBARREN --%>
<c:if test="${pageContext.request.getSession(false) != null}">
		<%
		Elab elab = Elab.getElab(pageContext, "cosmic");
		session.setAttribute("elab", elab);
		request.setAttribute("elab", elab);
		request.setAttribute("user", ElabGroup.getUser(session));
		session.setAttribute("environment", (String) elab.getProperty("environment"));
		%>
</c:if>
<%-- /PINEBARREN --%>
