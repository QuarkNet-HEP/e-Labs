<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.net.HttpURLConnection" %>

<%@ include file="../include/elab.jsp" %>

<%
	String file = request.getParameter("file");
	
	if (StringUtils.isBlank(file)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST); 
	}
	else {
		// debug - set to JSON for real stuff
		response.setContentType("application/json");
		
		// add in proper path handling!
		String pfn = RawDataFileResolver.getDefault().resolve(elab, file) + ".bless";
		BlessData bd = new BlessData(new File(pfn));
		
		GsonBuilder gb = new GsonBuilder();
		gb.registerTypeAdapter(BlessData.class, new BlessDataJsonSerializer());
		Gson gson = gb.create(); 
		
		out.write(gson.toJson(bd)); 
	}

%>
