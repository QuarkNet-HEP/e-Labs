<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.cosmic.plotly.*" %>
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
	File[] files = new File[4];
	for (int i = 0; i < 4; i++) {
		String fileName = results.getOutputDir()+"/freqOut"+String.valueOf(i+1);
		files[i] = new File(fileName);
	}
//	if (StringUtils.isBlank(freqOut1)) {
//		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST); 
//	}
//	else {
		response.setContentType("application/json");		
		PerformancePlotDataPlotly ppd = new PerformancePlotDataPlotly(files);
		
		GsonBuilder gb = new GsonBuilder();
		gb.registerTypeAdapter(PerformancePlotDataPlotly.class, new PerformanceDataJsonSerializerPlotly());
		Gson gson = gb.create(); 
		
		out.write(gson.toJson(ppd)); 
//	}

%>
