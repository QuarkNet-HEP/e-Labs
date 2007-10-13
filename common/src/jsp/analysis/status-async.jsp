<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>

<%
	response.setHeader("Cache-Control", "no-cache");
	String pid = request.getParameter("id");

	String r = null;

	if (pid == null) {
		r = "&error=No such analysis: " + pid + "&";
	}
	else if (pid.equals("all")) {
		StringBuffer listb = new StringBuffer();
		listb.append("&ids=");
		
		StringBuffer statusb = new StringBuffer();
		
		Collection ids = AnalysisManager.getAnalysisRunIDs(elab, user);
		Iterator i = ids.iterator();
		while(i.hasNext()) {
			String id = (String) i.next();
			
			listb.append(id);
			if (i.hasNext()) {
				listb.append(",");
			}
			
			AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, id);
			
			if (run != null) {
			
				String status = AnalysisTools.getStatusString(run);
				String progress = String.valueOf(AnalysisTools.getProgress(run));
			
				statusb.append("&status" + id + "=" + status + "&progress" + id + "=" + progress);
				statusb.append("&name" + id + "=" + run.getAnalysis().getType());
				statusb.append("&startTime" + id + "=" + run.getStartTime());
				if (run.getEndTime() != null) {
					statusb.append("&endTime" + id + "=" + run.getEndTime());
				}
			}
			else {
				statusb.append("&status" + id + "=unknown&progress" + id + "=0.0");
			}
		}
		statusb.append("&");
		listb.append(statusb);
		r = listb.toString();
	}
	else {
		AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, pid);
		
		if (run == null) {
			r = "&error=Invalid analysis: " + pid + "&";
		}
		else {
			String status = AnalysisTools.getStatusString(run);
			String progress = String.valueOf(AnalysisTools.getProgress(run));
			
			r = "&status=" + status + "&progress=" + progress + "&";
		}
	}
	out.write(r);
%>