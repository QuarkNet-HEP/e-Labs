<%@ page language="java" import="java.util.*,gov.fnal.elab.vdl2.*,java.io.*" %>

<%@ include file="workflowutil.jsp" %>

<%
	response.setHeader("Cache-Control", "no-cache");
	String workflowID = request.getParameter("workflowID");

	String r = null;

	if (workflowID == null) {
		r = "&error=No such workflow: " + workflowID+"&";
	}
	else if (workflowID.equals("all")) {
		StringBuffer listb = new StringBuffer();
		listb.append("&ids=");
		
		StringBuffer statusb = new StringBuffer();
		
		Collection ids = Workflows.getWorkflowIDS(session);
		Iterator i = ids.iterator();
		while(i.hasNext()) {
			String id = (String) i.next();
			
			listb.append(id);
			if (i.hasNext()) {
				listb.append(",");
			}
			
			Workflow wf = Workflows.getWorkflow(session, id);
			
			if (wf != null) {
			
				String status = workflowStatusString(wf);
				String progress = workflowProgress(wf);
			
				statusb.append("&status" + id + "=" + status + "&progress" + id + "=" + progress);
				statusb.append("&name" + id + "=" + wf.getName());
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
		Workflow workflow = Workflows.getWorkflow(session, workflowID);
		
		if (workflow == null) {
			r = "&error=Invalid workflow: " + workflowID+"&";
		}
		else {
			String status = workflowStatusString(workflow);
			String progress = workflowProgress(workflow);
			
			r = "&status=" + status + "&progress=" + progress + "&";
		}
	}
	out.write(r);
%>