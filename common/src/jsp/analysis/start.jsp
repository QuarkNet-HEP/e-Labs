<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.vds.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.swift.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.shell.*" %>
<%@ page import="gov.fnal.elab.analysis.pqueue.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%
	ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("elab:analysis");
	if (analysis == null) {
	    throw new ElabJspException("No analysis to start");
	}
	else {
		String runWith = request.getParameter("provider");
		AnalysisExecutor ex;
		
		if ("vds".equals(runWith)) {
	ex = new VDSAnalysisExecutor();
		}
		else if ("swift".equals(runWith)) {
	ex = new SwiftAnalysisExecutor();
		}
		else if ("shell".equals(runWith)) {
	ex = new ShellAnalysisExecutor();
		}
		else {
	ex = elab.getAnalysisExecutor();
		}
		
		DateFormat df = new SimpleDateFormat("MMM dd yyyy HH:mm:ss:SSS.");
		String outputBase = user.getDir("scratch");
		new File(outputBase).mkdirs();
       	File tmp = File.createTempFile(df.format(new Date()), "", new File(outputBase));
        tmp.delete();
        tmp.mkdirs();
        String runDir = outputBase + File.separator + tmp.getName();
		
	    AnalysisRun run = ex.createRun(analysis, elab, runDir);
	    String runDirURL = user.getDirURL("scratch") + '/' + tmp.getName();
	    run.setOutputDirURL(runDirURL);
	    
	    String cont = request.getParameter("continuation");
	    if (cont == null) {
	        throw new ElabJspException("No continuation specified");
	    }
	    String outputType = request.getParameter("outputType");
	    if (outputType == null) {
	    	outputType = "output.jsp";
	    }
	    if (cont.indexOf('?') != -1) {
	        cont += "&id=" + run.getId()+"&outputType="+outputType;
	    }
	    else {
	        cont += "?id=" + run.getId()+"&outputType="+outputType;
	    }
	    String err = request.getParameter("onError");
	    if (err == null) {
	        err = cont;
	    }
	    String mFilter = request.getParameter("mFilter");
	    if (mFilter == null) {
	    	mFilter = "0";
	    }
 	    run.setAttribute("continuation", cont);
	    run.setAttribute("onError", err);
	    run.setAttribute("type", analysis.getName());
	    run.setAttribute("owner", user.getName());
	    run.setAttribute("queuedAt", df.format(new Date()));
	    
	    boolean skip = false;
	    if (run.getAttribute("type").equals("ProcessUpload") ||	run.getAttribute("type").equals("EventPlot") || run.getAttribute("type").equals("RawAnalyzeStudy")) {
	    	skip = true;
	    }
	    if (!skip) {
		    run.setAttribute("inputfiles", analysis.getParameterValues("rawData"));
	    }	    
	    String detectorid = request.getParameter("detectorid");
	    if (detectorid == null) {
			detectorid = "";
	    }
    	run.setAttribute("detectorid", detectorid);
    	//Edit Peronja: May 31, 2018:
    	//	Added delta T code    	
    	String[] deltaTIDs = request.getParameterValues("deltaTIDs");
    	if (deltaTIDs != null) {
            run.setAttribute("deltaTIDs", deltaTIDs);
	    	analysis.setAttribute("deltaTIDs", deltaTIDs);
        }
      	analysis.setAttribute("detectorid", detectorid);
    	analysis.setAttribute("id", run.getId());
    	analysis.setAttribute("mFilter", mFilter);

    	String workflowRunMode = request.getParameter("runMode");
		if (workflowRunMode != null) {
			run.setAttribute("runMode", workflowRunMode);
			analysis.setAttribute("runMode", workflowRunMode);
		}
		
		String notifier = request.getParameter("notifier");
		if (notifier == null || notifier.length() == 0) {
		    notifier = "default";
		}
	    
	    AnalysisManager.registerAnalysisRun(elab, user, run);
	    AnalysisNotifier n = AnalysisNotifierFactory.newNotifier(notifier);
	    n.setRun(run);
	    run.setListener(n);
	    //EPeronja-04/25/2014: Added this code to complete the upload process after the split is done.
	    if (run.getAttribute("type").equals("ProcessUpload")) {
	    	run.setAttribute("uploadtime", analysis.getParameter("uploadtime"));
	    	run.setAttribute("runMode", "local");
	    	final ElabAnalysis ea = analysis;
	    	final AnalysisRun ar = run;
	    	ar.setDelayedCompletion(true);
			run.setListener(new AnalysisRunListener() {
				public void runStatusChanged(int status) {
					if (status == AnalysisRun.STATUS_DELAYED) {
						CosmicPostUploadTasks cput = new CosmicPostUploadTasks(ea);
						cput.runTasks();
						ar.setDelayedCompletion(false);
					    ar.setEndTime(new Date());
						ar.setStatus(AnalysisRun.STATUS_COMPLETED);
					}
				}
			});
	    }
	    //remember to set this up in elab.properties as cosmic.analysis = queue
	    String runType = elab.getProperty(elab.getName() + ".analysis");
	    if (runType != null && runType.equals("queue")) {
		    if (run.getAttribute("type").equals("ProcessUpload") ||
		    	run.getAttribute("type").equals("EventPlot") ||
		    	run.getAttribute("type").equals("RawAnalyzeStudy") ||
		    	run.getAttribute("type").equals("PerformanceStudy")) {
		    	run.start();
		    } else {
		    	AnalysisQueues.getQueue((String) run.getAttribute("runMode")).add(run);
		    }
	    } else {
	    	run.start();
	    }
%>
	    	<jsp:include page="status.jsp">
	    		<jsp:param name="id" value="<%= run.getId() %>"/>
	    		<jsp:param name="mFilter" value="<%= mFilter %>"/>
	    	</jsp:include>
	    <%
	}
%>
