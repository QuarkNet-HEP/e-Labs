<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Creating eclipseFormat . . . </title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<%
	//Original file to copy. Avoid the ability to point to arbitrary files
		String src2 = new File(request.getParameter("src")).getName();
	//Destination file to copy to.  	
		String dst2 = new File(request.getParameter("dst")).getName();

		out.println("Source: "+src2);
		out.println("\n");
		out.println("Destination: "+dst2);
		ut.println("\n");
	%>
	</body>
</html>

