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

	/* Logout of BOINC by clearing auth cookies */
	
	Cookie cookie1 = new Cookie("auth", "");
	cookie1.setPath("/");
	cookie1.setMaxAge(0);
	response.addCookie(cookie1);
	
	Cookie cookie2 = new Cookie("boinc_auth", "");
	cookie1.setPath("/");
	cookie2.setMaxAge(0);
	response.addCookie(cookie2);
	
	Cookie cookie3 = new Cookie("i2u2_auth", "");
	cookie1.setPath("/");
	cookie2.setMaxAge(0);
	response.addCookie(cookie3);

	response.sendRedirect(prevPage);
%>
