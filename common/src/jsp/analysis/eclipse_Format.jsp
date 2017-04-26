<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>

<%@ page import="java.nio.file.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Creating eclipseFormat . . . </title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<%
	//Original file to copy. Avoid the ability to point to arbitrary files
		File s = new File(request.getParameter("src")); 		
		if(s.exists()){
			out.println("Source exists!");
		}

		/*
		Path source = Paths.get(request.getParameter("src"));
		Path destination = Paths.get(request.getParameter("dst"));
		
		try {
			Files.copy(source, destination);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		File srcF= new File(request.getParameter("src"));
		File dstF= new File(request.getParameter("dst"));
		
		out.println("Source: "+srcF.getAbsolutePath());
		out.println("\n");
		out.println("Destination: "+dstF.getAbsolutePath());
		out.println("\n");
		*/
		
	%>
	</body>
</html>

