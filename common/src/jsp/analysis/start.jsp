<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>

<%
	ElabAnalysis analysis = (ElabAnalysis) request.getAttribute("elab:analysis");
	if (analysis == null) {
	    throw new ElabJspException("No analysis to start");
	}
	else {
	    AnalysisRun run = elab.getAnalysisExecutor().start(analysis, elab, user);
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
	    AnalysisManager.registerAnalysisRun(session, run);
	    %> 
	    	<jsp:include page="status.jsp">
	    		<jsp:param name="id" value="<%= run.getId() %>"/>
	    	</jsp:include> 
	    <%
	}
%>
