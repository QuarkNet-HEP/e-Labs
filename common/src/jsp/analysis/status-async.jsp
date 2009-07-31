<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>

<%!
	public void add(StringBuffer sb, String name, String id, String value) {
		sb.append('&');
		sb.append(name);
		if (id != null) {
			sb.append(id);
		}
		sb.append('=');
		sb.append(value);
	} 
%>

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
		
		DateFormat df = new SimpleDateFormat("MM/dd/yy HH:mm:ss");
		df.setTimeZone(TimeZone.getTimeZone("UTC"));
		
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
			
				add(statusb, "status", id, status);
				add(statusb, "progress", id, progress);
				if (run.getAnalysis() != null) {
					add(statusb, "name", id, run.getAnalysis().getName());
				}
				add(statusb, "mode", id, (String) run.getAttribute("runMode"));
				if (run.getStartTime() != null) {
					add(statusb, "startTime", id, df.format(run.getStartTime()));
				}
				add(statusb, "elapsedTime", id, run.getFormattedRunTime());
				add(statusb, "estimatedTime", id, run.getFormattedEstimatedRunTime()); 
				if (run.getEndTime() != null) {
					add(statusb, "endTime", id, df.format(run.getEndTime()));
				}
			}
			else {
				add(statusb, "status", id, "unknown");
				add(statusb, "progress", id, "0.0");
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
			r = "&status=" + status + "&progress=" + progress + "&estimatedTime=" + 
				run.getFormattedEstimatedRunTime() + "&elapsedTime=" + 
				run.getFormattedRunTime() + "&";
		}
	}
	out.write(r);
%>