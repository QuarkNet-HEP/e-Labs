<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%
	String id = request.getParameter("id");
	AnalysisRun results = null;
	if (id == null) {
	    //This should probably show a list of finished studies instead
   		throw new ElabJspException("Missing id parameter");
	}
	else {
		// ugly, ugly hack while I figure out how the real cause of this problem. 
		id = id.replace("?", "");
		
		results = AnalysisManager.getAnalysisRun(elab, user, id);
		if (results == null) {
		    throw new ElabJspException("Invalid analysis id: " + id);
		}
		request.setAttribute("results", results);
	}
%>