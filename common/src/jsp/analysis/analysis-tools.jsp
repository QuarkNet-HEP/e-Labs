<%@ page import="gov.fnal.elab.vdl2.*" %>

<%!
	public static String runStatusString(AnalysisRun run) {
		int status = run.getStatus();
			
		if (status == AnalysisRun.STATUS_COMPLETED) {
			return "completed";
		}
		else if (status == AnalysisRun.STATUS_FAILED) {
			return "failed";
		}
		else if (status == AnalysisRun.STATUS_RUNNING) {
			return "running";
		}
		else if (status == AnalysisRun.STATUS_CANCELED) {
			return "canceled";
		}
		else if (status == AnalysisRun.STATUS_NONE) {
			return "none";
		}
		else {
			return "unknown";
		}
	}
%>

<%!
	public static String runProgress(AnalysisRun run) {
		int status = run.getStatus();
			
		if (status == AnalysisRun.STATUS_COMPLETED) {
			return "1.0";
		}
		else if (status == AnalysisRun.STATUS_FAILED) {
			return "0.0";
		}
		else if (status == AnalysisRun.STATUS_RUNNING) {
			return String.valueOf(run.getProgress());
		}
		else if (status == AnalysisRun.STATUS_CANCELED) {
			return "0.0";
		}
		else if (status == AnalysisRun.STATUS_NONE) {
			return "0.0";
		}
		else {
			return "0.0";
		}
	}
%>
