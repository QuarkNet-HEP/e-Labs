<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%
	if (session.getAttribute("session:valid") == null) {
		Cookie cookie = new Cookie("JSESSIONID", session.getId());
    	cookie.setPath("/elab");
	    response.addCookie(cookie);
	    session.setAttribute("session:valid", Boolean.TRUE);
	}
	ElabGroup user = (ElabGroup) session.getAttribute("user");
	if (user == null) {
		user = new ElabGroup(elab, null);
		user.setUserArea("userdata");
		session.setAttribute("user", user);
	}
%>