<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
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
	    String userParam = (String) request.getParameter("user");
	    ElabGroup auser = user;
	    if (userParam != null) {
	        if (!user.isAdmin()) {
	        	throw new ElabJspException("You must be logged in as an administrator" 
	            	+ "to see the status of other users' analyses");
	        }
	        else {
	            auser = elab.getUserManagementProvider().getGroup(userParam);
	        }
	    }
	    
		AnalysisRun run = AnalysisManager.getAnalysisRun(elab, auser, id);
		
		if (run == null) {
			System.err.println("Invalid analysis id " + id);
			%> 
				The specified analysis ID (<%= id %>) is invalid. Please re-run the experiment.
			<%
		}
		else {
			request.setAttribute("run", run);
			int status = run.getStatus();
			if (status == AnalysisRun.STATUS_COMPLETED || status == AnalysisRun.STATUS_FAILED) {
			    Integer nid = (Integer) run.getAttribute("notification-id");
				if (nid != null) {
				    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
				    np.markAsRead(user, nid);
				}
			}
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
