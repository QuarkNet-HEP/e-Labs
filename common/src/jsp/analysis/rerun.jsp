<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page errorPage="../include/errorpage.jsp" %>

<%
	/*
	 * There are many options here on how an analysis would be re-run.
	 * I suppose the idea is to be able to go through the parameters
	 * again. This would be straightforward if the parameters page could
	 * be build automatically from the TR. Unfortunately the TR is not
	 * reach enough to be able to produce the analysis pages currently 
	 * in cosmic, so it's going to stay custom at this time.
	 * You can change this to reflect the way analyses are set up in
	 * your particular case.
	 */
	 
	 String study = request.getParameter("study");
	 if (study == null) {
	     throw new ElabJspException("Missing study");
	 }
	 String dvName = request.getParameter("dvName");
	 if (dvName == null) {
	     throw new ElabJspException("Missing DV name");
	 }
	 ElabAnalysis analysis = elab.getDataCatalogProvider().getAnalysis(dvName);
	 response.sendRedirect("../analysis-" + study + "/analysis.jsp?" + analysis.getEncodedParameters());
%>