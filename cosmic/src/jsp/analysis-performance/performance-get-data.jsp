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
	File[] files = new File[4];
	for (int i = 0; i < 4; i++) {
		String fileName = results.getOutputDir()+"/singleOut"+String.valueOf(i+1);
		files[i] = new File(fileName);
	}
	response.setContentType("application/json");		
	PerformancePlotData ppd = new PerformancePlotData(files);
	
	GsonBuilder gb = new GsonBuilder();
	gb.registerTypeAdapter(PerformancePlotData.class, new PerformanceDataJsonSerializer());
	Gson gson = gb.create(); 
	
	out.write(gson.toJson(ppd)); 
%>
