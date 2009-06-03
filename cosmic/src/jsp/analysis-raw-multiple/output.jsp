<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
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
	
	<body id="raw-analysis-multiple-output" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<table border="1">
    <tr>
        <th align="center">School</th>
        <th align="center">Start Date</th>
        <th align="center">End Date</th>
        <th align="center">Total Events</th>
        <th align="center">Gatewidth</th>
        <th align="center">Average hits per event</th>
        <th align="center">Valid GPS events</th>
        <th align="center">Invalid GPS events</th>
        <th align="center">No CPLD update</th>
    </tr>
	<c:import url="rawanalyzeMultiple.xsl" var="stylesheet" />
	<%
		String[] lfn = request.getParameterValues("f");
		if (lfn == null) {
		   	throw new ElabJspException("No files specified");
		}
		for (int i = 0; i < lfn.length; i++) {
		    String did = AnalysisParameterTools.getDetectorId(lfn[i]);
			File analyze = new File(new File(elab.getProperties().getDataDir(), did), lfn[i] + ".analyze");
			CatalogEntry entry = elab.getDataCatalogProvider().getEntry(analyze.getName());
		    if (entry == null || !analyze.exists()) {
		        %>
					<tr>
						<td colspan="9"><%= lfn[i] %> has not been 
							<a href="<%= "../analysis-raw-single/analysis.jsp?submit=true&filename=" + lfn[i] %>">analyzed</a>
							 yet.
						</td>
					</tr>
				<%
		    }
		    else {
	            BufferedReader br = new BufferedReader(new FileReader(analyze));
	            request.setAttribute("entry", entry);
					%>
			            <tr>
               				<td align="left">${entry.tupleMap.school}</td>
			                <td align="center">${entry.tupleMap.startdate}</td>
							<td align="center">${entry.tupleMap.enddate}</td>
							<x:transform xslt="${stylesheet}">
								<%
									String str;
									while((str = br.readLine()) != null){
										out.println(str);
									}
								%>
							</x:transform>
						</tr>
					<%
			}
		}
	%>
</table>

<p align="right">
	<a href="javascript:history.go(-1)">Back</a> to the study
</p>

			</div>
			<!-- end content -->	
	
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
