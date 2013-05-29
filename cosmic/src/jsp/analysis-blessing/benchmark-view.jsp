<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.*" %>
<%@ page import="java.io.*" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>View Benchmark Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="view-benchmark" class="data">
	<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<table border="0" id="main">
<%
	String filename = request.getParameter("filename");
	if (filename == null) {
	    throw new ElabJspException("Please choose a file to view");
	}
	String pfn = RawDataFileResolver.getDefault().resolve(elab, filename);
	BufferedReader br; 
	
	try {
		br = new BufferedReader(new FileReader(pfn));
	}
	catch (FileNotFoundException ex) {
		throw new ElabJspException("Could not find file: " + filename);
	}
	String str = null;
	while ((str = br.readLine()) != null) {
		%>
		<tr><td><%= str %></td></tr>
		<%
	}//while
	br.close();
%> 
</table>
			</div>
		</div>
	</body>
</html>