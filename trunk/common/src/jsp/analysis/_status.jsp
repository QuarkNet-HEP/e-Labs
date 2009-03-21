<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%
	String id = request.getParameter("id");
	String showStatus = request.getParameter("showStatus");
	
	if (id == null) {
		id = (String) request.getAttribute("foregroundAnalysisID");
	}

	if (id == null) {
		%><jsp:forward page="../analysis/list.jsp"/><%
	}
	else {
		AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, id);
		
		if (run == null) {
			System.err.println("Invalid analysis id " + id);
			%> 
				The specified analysis ID (<%= id %>) is invalid. Please re-run the experiment.
			<%
		}
		else {
			request.setAttribute("run", run);
			int status = run.getStatus();
			if (status == AnalysisRun.STATUS_COMPLETED && showStatus == null) {
				String cont = (String) run.getAttribute("continuation");
				System.out.println("Initial continuation: " + cont);
				if (cont != null) {
					response.sendRedirect(cont);
				}
				else {
					throw new RuntimeException("No continuation");
				}
			}
			else {
					%><%@ include file="_status-info.jsp" %><%
			}
		}
	}
%>
