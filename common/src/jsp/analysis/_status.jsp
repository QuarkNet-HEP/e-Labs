<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.notifications.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="gov.fnal.elab.debug.WriteLogFile" %>

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
	    if (userParam == null) {
	    	userParam = (String) session.getAttribute("userParam");
	    }
	    session.setAttribute("userParam", userParam);
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
		    WriteLogFile uploadLog = new WriteLogFile(elab, id+"-"+user.getName()+"-"+String.valueOf(status)+".log", "upload-log");  
	    	if (uploadLog.canAppend()) {
	    		uploadLog.appendLines("Status:"+String.valueOf(status)+"\n");
	    	}
		    if (status == AnalysisRun.STATUS_COMPLETED || status == AnalysisRun.STATUS_FAILED) {
			    Integer nid = (Integer) run.getAttribute("notification-id");
			    if (nid != null) {
				    ElabNotificationsProvider np = ElabFactory.getNotificationsProvider(elab);
				    //np.markAsRead(user, nid);
				}
			}
			if (status == AnalysisRun.STATUS_COMPLETED && showStatus == null) {
				String cont = (String) run.getAttribute("continuation");
				System.out.println("Initial continuation: " + cont);
		    	if (uploadLog.canAppend()) {
		    		uploadLog.appendLines("User:"+user.getName()+" Id:"+id+" Status:"+String.valueOf(status)+" Continuation:"+cont+".\n");
		    		uploadLog.cleanup();
		    	}
				if (cont != null) {
					response.sendRedirect(cont);
				}
				else {
			    	if (uploadLog.canAppend()) {
			    		uploadLog.appendLines("User:"+user.getName()+" Id:"+id+" Status:"+String.valueOf(status)+" No Continuation.\n");
			    		uploadLog.cleanup();
			    	}
					throw new RuntimeException("No continuation");
				}
			}
			else {
					%><%@ include file="_status-info.jsp" %><%
			}
		}
	}
%>
