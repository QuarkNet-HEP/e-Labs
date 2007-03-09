<%@ page import="gov.fnal.elab.vdl2.*" %>

<%!
	public static String workflowStatusString(Workflow wf) {
		int status = wf.getStatus();
			
		if (status == Workflow.STATUS_COMPLETED) {
			return "completed";
		}
		else if (status == Workflow.STATUS_FAILED) {
			return "failed";
		}
		else if (status == Workflow.STATUS_RUNNING) {
			return "running";
		}
		else if (status == Workflow.STATUS_CANCELED) {
			return "canceled";
		}
		else if (status == Workflow.STATUS_NONE) {
			return "none";
		}
		else {
			return "unknown";
		}
	}
%>

<%!
	public static String workflowProgress(Workflow wf) {
		int status = wf.getStatus();
			
		if (status == Workflow.STATUS_COMPLETED) {
			return "1.0";
		}
		else if (status == Workflow.STATUS_FAILED) {
			return "0.0";
		}
		else if (status == Workflow.STATUS_RUNNING) {
			return String.valueOf(wf.getProgress());
		}
		else if (status == Workflow.STATUS_CANCELED) {
			return "0.0";
		}
		else if (status == Workflow.STATUS_NONE) {
			return "0.0";
		}
		else {
			return "0.0";
		}
	}
%>
