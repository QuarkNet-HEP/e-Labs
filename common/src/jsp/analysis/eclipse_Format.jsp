<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %><%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>
<%@ page import="java.nio.file.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Creating eclipseFormat . . . </title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<%
		String sF = request.getParameter("srcF");
		String sD = request.getParameter("srcD");
		String dF = request.getParameter("dstF");
		String dD = request.getParameter("dstD");
		String src = "webapps"+sD+"/"+sF;
		String dst = "webapps"+dD+"/"+dF;
		
		out.println("Source: "+src);
		out.println("Destination: "+dst);	

		File file1 = new File(src);
        	File file2 = new File(dst);
		
		if (file1.exists()){
			out.println("Source exists!");
			Path source = Paths.get(src);
			Path destination = Paths.get(dst); 
		}		
		try {
			Files.copy(source, destination);
		} catch (IOException e) {
			e.printStackTrace();
		}		

		
		if (file2.exists()){
                        out.println("Destination exists!  Copy successful!");
                }
	%>
	</body>
</html>

