<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>

<%
	/*
	 * There are many options here on how an analysis would be re-run.
	 * I suppose the idea is to be able to go through the parameters
	 * again. This would be straightforward if the parameters page could
	 * be build automatically from the TR. Unfortunately the TR is not
	 * rich enough to be able to produce the analysis pages currently 
	 * in cosmic, so it's going to stay custom at this time.
	 * You can change this to reflect the way analyses are set up in
	 * your particular case.
	 */
	 
	 String study = request.getParameter("study");
	 if (study == null) {
	   	throw new ElabJspException("Missing study");
	 }
	 request.setAttribute("study", study);
	 ElabAnalysis analysis;
	 String dvName = request.getParameter("dvName");
	 if (dvName != null) {
	 	analysis = elab.getAnalysisCatalogProvider().getAnalysis(dvName);
	 	if (analysis == null) {
	 		throw new ElabJspException("The specified analysis (" + dvName + ") was not found in the database");
	 	}
	 }
	 else { 
	 	analysis = (ElabAnalysis) session.getAttribute("analysisToRerun");
	 	if (analysis == null) {
	 		String id = request.getParameter("id");
			if (id == null) {
	    		throw new ElabJspException("Missing all of dvName parameter, analysisToRerun session attribute, and id parameter");
			}
			else {
				AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, id); 
				if (run == null) {
		    		throw new ElabJspException("Invalid analysis id: " + id);
				}
				analysis = run.getAnalysis();
			}
	 	}
	 }
	 request.setAttribute(gov.fnal.elab.tags.Analysis.ATTR_ANALYSIS, analysis);
	 request.setAttribute("analysis", analysis);
%>

<c:choose>
	<c:when test="${analysis != null}">
		<jsp:include page="../analysis-${study}/analysis.jsp?${request.queryString}&runMode=${analysis.attributes.runMode}"/>
	</c:when>
	<c:otherwise>
		<% response.sendRedirect("../analysis-" + study); %>
	</c:otherwise>
</c:choose>