<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.net.HttpURLConnection" %>

<%
	String file = request.getParameter("file");

	String prefix = "/Users/phongn/data/bless/"; 
	String suffix = ".bless";
	
	// testing override
	//file = "/Users/phongn/data/6148.2011.0309.0.bless"; 
	//file2 = "/Users/phongn/data/6148.2011.0310.0.bless"; 

	if (StringUtils.isBlank(file)) {
		response.sendError(HttpURLConnection.HTTP_BAD_REQUEST); 
	}
	else {
		// debug - set to JSON for real stuff
		response.setContentType("text/plain");
		
		// add in proper path handling!
		BlessData bd = new BlessData(new File(prefix + file + suffix));
		
		GsonBuilder gb = new GsonBuilder();
		gb.registerTypeAdapter(BlessData.class, new BlessDataJsonSerializer());
		Gson gson = gb.create(); 
		
		out.write(gson.toJson(bd)); 
	}

%>
