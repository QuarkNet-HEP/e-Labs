<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="gov.fnal.elab.ElabGroup" %>
<%
	{//avoid duplicate variables
		ElabGroup user = new ElabGroup(elab, null);
		user.setName("none");
		user.setUserArea("default");
		ElabGroup.setUser(session, user);
	}
%>