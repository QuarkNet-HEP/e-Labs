<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%
	if (ElabGroup.isUserLoggedIn(session)) {
		ElabGroup.setUser(session, null);
	}
	
	String prevPage = request.getParameter("prevPage");
	if (prevPage == null) {
   		prevPage = elab.getProperties().getLoggedOutHomePage();
	}
		
	response.sendRedirect(prevPage);
%>
