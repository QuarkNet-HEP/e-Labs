<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%
	String id = request.getParameter("id");
	AnalysisRun results = null;
	if (id == null) {
	    //This should probably show a list of finished studies instead
   		throw new ElabJspException("Missing id parameter");
	}
	else {
		results = AnalysisManager.getAnalysisRun(elab, user, id);
		if (results == null) {
		    throw new ElabJspException("Invalid analysis id: " + id);
		}
		request.setAttribute("results", results);
		Integer nid = (Integer) results.getAttribute("notification-id");
		if (nid != null) {
		    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
		    np.markAsRead(user, nid);
		}
	}
%>