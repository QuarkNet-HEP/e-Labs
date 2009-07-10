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
	
    /* Nuke e-Lab cookies */ 
    Cookie elabSessionCookie = new Cookie("JSESSIONID", "");
    elabSessionCookie.setPath("/elab/" + elab.getName());
    elabSessionCookie.setMaxAge(0);
    response.addCookie(elabSessionCookie);
    
    Cookie elabDWRSessionCookie = new Cookie("JSESSIONID", "");
    elabDWRSessionCookie.setPath("/elab/dwr");
    elabDWRSessionCookie.setMaxAge(0);
    response.addCookie(elabDWRSessionCookie);

	/* Logout of BOINC by clearing auth cookies */
	Cookie authCookie = new Cookie("auth", "");
	authCookie.setPath("/");
	authCookie.setMaxAge(0);
	response.addCookie(authCookie);
	
	Cookie forumAuthCookie = new Cookie("boinc_auth", "");
	forumAuthCookie.setPath("/");
	forumAuthCookie.setMaxAge(0);
	response.addCookie(forumAuthCookie);
	
	Cookie i2u2AuthCookie = new Cookie("i2u2_auth", "");
	i2u2AuthCookie.setPath("/");
	i2u2AuthCookie.setMaxAge(0);
	
	/* Invalidate the session */
    session.invalidate();
	
	response.addCookie(i2u2AuthCookie);
	response.sendRedirect(prevPage);
%>