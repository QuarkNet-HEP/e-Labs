<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>

<%@ include file="../analysis/analysis-tools.jsp" %>

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
		
		Collection ids = AnalysisManager.getAnalysisRunIDs(session);
		Iterator i = ids.iterator();
		while(i.hasNext()) {
			String id = (String) i.next();
			
			listb.append(id);
			if (i.hasNext()) {
				listb.append(",");
			}
			
			AnalysisRun run = AnalysisManager.getAnalysisRun(session, id);
			
			if (run != null) {
			
				String status = runStatusString(run);
				String progress = runProgress(run);
			
				statusb.append("&status" + id + "=" + status + "&progress" + id + "=" + progress);
				statusb.append("&name" + id + "=" + run.getAnalysis().getType());
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
		AnalysisRun run = AnalysisManager.getAnalysisRun(session, pid);
		
		if (run == null) {
			r = "&error=Invalid analysis: " + pid + "&";
		}
		else {
			String status = runStatusString(run);
			String progress = runProgress(run);
			
			r = "&status=" + status + "&progress=" + progress + "&";
		}
	}
	out.write(r);
%>