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
		String sF = request.getParameter("srcF");
		String sD = request.getParameter("srcD");
		String dF = request.getParameter("dstF");
		String dD = request.getParameter("dstD");

		out.println("Source File: "+sF);
		out.println("Source Dir: "+sD);
		out.println("Destination File: "+dF);
                out.println("Destination Dir: "+dD);

		if (sD != null) {
			ElabUtil.copyFile(sD, sF, dD, dF);
                }				
	%>
	</body>
</html>

