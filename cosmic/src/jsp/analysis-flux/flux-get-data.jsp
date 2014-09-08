<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.cosmic.plot.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp"%>
<%
	String id = request.getParameter("id");
	AnalysisRun results = AnalysisManager.getAnalysisRun(elab, user, id);
	String fileName = results.getOutputDir()+"/flux.out";
	File file = new File(fileName);
//	if (StringUtils.isBlank(freqOut1)) {
//		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST); 
//	}
//	else {
		response.setContentType("application/json");		
		FluxPlotData ppd = new FluxPlotData(file);
		
		GsonBuilder gb = new GsonBuilder();
		gb.registerTypeAdapter(FluxPlotData.class, new FluxDataJsonSerializer());
		Gson gson = gb.create(); 
		
		out.write(gson.toJson(ppd)); 
//	}

%>
