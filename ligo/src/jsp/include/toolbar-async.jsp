<%@ page import="gov.fnal.elab.*"
         import="gov.fnal.elab.notifications.*" 
%><%
	if (ElabGroup.isUserLoggedIn(session)) {
	    ElabGroup group = ElabGroup.getUser(session);
	    out.write("logged-in=" + group.getName());
	}
	else {
	    out.write("logged-in=");
	}
	
%>