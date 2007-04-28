<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.ElabUser" %>
<%	
	if (ElabUser.isUserLoggedIn(session)) {
		ElabUser.setUser(session, null);
	}
	
	String prevPage = request.getParameter("prevPage");
	if(prevPage == null){
   		prevPage = elab.getProperties().getLoggedOutHomePage();
	}
		
	response.sendRedirect(prevPage);
%>
