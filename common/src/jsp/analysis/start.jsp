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
		
		DateFormat df = new SimpleDateFormat("yyyy.MM.dd.HH.mm.ss.SSS.");
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
	    if (cont.indexOf('?') != -1) {
	        cont += "&id=" + run.getId();
	    }
	    else {
	        cont += "?id=" + run.getId();
	    }
	    String err = request.getParameter("onError");
	    if (err == null) {
	        err = cont;
	    }
	    run.setAttribute("continuation", cont);
	    run.setAttribute("onError", err);
	    
	    String workflowRunMode = request.getParameter("runMode");
		if (workflowRunMode != null) {
			run.setAttribute("runMode", workflowRunMode);
			analysis.setAttribute("runMode", workflowRunMode);
		}
	    
	    AnalysisManager.registerAnalysisRun(elab, user, run);
	    run.start();
	    %> 
	    	<jsp:include page="status.jsp">
	    		<jsp:param name="id" value="<%= run.getId() %>"/>
	    	</jsp:include> 
	    <%
	}
%>
