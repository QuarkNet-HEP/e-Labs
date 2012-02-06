<%@ include file="../include/elab.jsp" %>

<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>

<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.util.*" %>

<%

String operation = request.getParameter("op"); 

if ("blessOneFile".equals(operation)) {
	String file = request.getParameter("file");
	if (StringUtils.isBlank(file)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
	}
	else {
		try {
			Bless.setBlessedState(elab, file, "blessed");
		}
		catch (ElabException ee) {
			// writeback error to user
		}
	}
}
else if ("setGolden".equals(operation)) {
	String file = request.getParameter("file");
	String stateParam = request.getParameter("state"); 
	if (StringUtils.isBlank(file)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
	}
	else {
		try {
			boolean state = Boolean.parseBoolean(stateParam); // true iff state = 'true'
			Bless.setGoldenState(elab, file, state);
		}
		catch (ElabException ee) {
			// writeback error to user
		}
	}
}
else if ("clearRange".equals(operation)) {
	String startDateParam = request.getParameter("startDate");
	String endDateParam = request.getParameter("endDate");
	String detectorParam = request.getParameter("detector");
	
	if (StringUtils.isBlank(startDateParam) || StringUtils.isBlank(endDateParam) || StringUtils.isBlank(detectorParam)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
	}
	else {
		try {
			int detectorId = Integer.parseInt(detectorParam);
			Date startDate = new Date();
			Date endDate   = new Date();
			Bless.setBlessedStates(elab, detectorId, startDate, endDate, "awaiting blessing");
		}
		catch (ElabException ee) {
			// writeback error to user
		}
		catch (NumberFormatException nfe) {
			response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
	}
	}
}
else if ("checkGolden".equals(operation)) {
	String startDateParam = request.getParameter("startDate");
	String endDateParam = request.getParameter("endDate");
	String detectorParam = request.getParameter("detector");
	
	if (StringUtils.isBlank(startDateParam) || StringUtils.isBlank(endDateParam) || StringUtils.isBlank(detectorParam)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
	}
	else {
		try {
			int detectorId = Integer.parseInt(detectorParam);
			Date startDate = new Date();
			Date endDate   = new Date();
			boolean goldenExists = Bless.checkForExistingGolden(elab, detectorId, startDate, endDate);
		}
		catch (ElabException ee) {
			// writeback error to user
		}
		catch (NumberFormatException nfe) {
			response.sendError(HttpURLConnection.HTTP_BAD_REQUEST);
		}
	}
}
else {
	response.sendError(HttpURLConnection.HTTP_BAD_REQUEST); 
}
%> 