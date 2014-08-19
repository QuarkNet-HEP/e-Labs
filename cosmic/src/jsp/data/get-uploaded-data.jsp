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
	String filename = request.getParameter("filename");
	String ndx = request.getParameter("ndx");
	String yaxisnum = request.getParameter("yAxisNum");
	String xaxisnum = request.getParameter("xAxisNum");
	
	String plotDir = user.getDir("plots");
	String filePath = plotDir+"/"+filename;
	File file = new File(filePath);
	response.setContentType("application/json");		
	
	PlotData ppd = new PlotData(file, ndx, xaxisnum, yaxisnum, elab);
		
	GsonBuilder gb = new GsonBuilder();
	gb.registerTypeAdapter(PlotData.class, new PlotDataJsonSerializer());
	Gson gson = gb.create(); 
		
	out.write(gson.toJson(ppd));
%>