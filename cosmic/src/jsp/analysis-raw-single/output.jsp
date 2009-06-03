<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Raw Analysis Results</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="raw-analysis-single-output" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<%
	String id = request.getParameter("id");
	String outf;
	if (id != null) {
	    AnalysisRun results = AnalysisManager.getAnalysisRun(elab, user, id);
	    outf = (String) results.getAnalysis().getParameter("outFile");
		List meta = new ArrayList();
	
		Timestamp timestamp = new Timestamp(System.currentTimeMillis());
		meta.add("transformation string Quarknet.Cosmic::RawAnalyzeStudy");
		meta.add("creationdate date " + timestamp.toString());
		meta.add("source string " + results.getAnalysis().getParameter("inFile"));
		meta.add("gatewidth int " + results.getAnalysis().getParameter("gatewidth"));
		meta.add("name string " + new File(outf).getName());
		
		//path data
		meta.add("city string " + user.getCity());
		meta.add("group string " + user.getName());
		meta.add("project string " + elab.getName());
		meta.add("school string " + user.getSchool());
		meta.add("state string " + user.getState());
		meta.add("teacher string " + user.getTeacher());
		meta.add("year string " + user.getYear());
		elab.getDataCatalogProvider().insert(DataTools.buildCatalogEntry(new File(outf).getName(), meta));
	}
	else {
	    outf = request.getParameter("filename");
	    if (outf == null) {
	        throw new ElabJspException("No analysis found and no file was specified");
	    }
	}
%>

<c:import url="rawanalyze.xsl" var="stylesheet" />
<x:transform xslt="${stylesheet}">
	<%
		File f = new File(outf);
		BufferedReader br = new BufferedReader(new FileReader(f));
		String str;
		while((str = br.readLine()) != null){
		    out.println(str);
		}
	%>
</x:transform>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
