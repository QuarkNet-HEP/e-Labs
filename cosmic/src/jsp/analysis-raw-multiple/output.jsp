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

<%
// Process the output of the analysis if any and stick files in the VDC
String id = request.getParameter("id");
AnalysisRun results = null;
if (id != null) {	    
	results = AnalysisManager.getAnalysisRun(elab, user, id);
	if (results == null) {
	    throw new ElabJspException("Invalid analysis id: " + id);
	}
	request.setAttribute("results", results);
    List outfs = (List) results.getAnalysis().getParameter("outFile");
    Iterator i = outfs.iterator();
    while (i.hasNext()) {
        String outf = (String) i.next();
        
		List meta = new ArrayList();
	
		Timestamp timestamp = new Timestamp(System.currentTimeMillis());
		meta.add("transformation string Quarknet.Cosmic::RawAnalyzeStudy");
		meta.add("creationdate date " + timestamp.toString());
		meta.add("source string " + results.getAnalysis().getParameter("inFile"));
		meta.add("gatewidth int " + results.getAnalysis().getParameter("gatewidth"));
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
}
%>


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
		if (lfn == null && results != null) {
		    lfn = (String[]) results.getAnalysis().getAttribute("f");
		}
		if (lfn == null) {
		   	throw new ElabJspException("No files specified");
		}
		for (int i = 0; i < lfn.length; i++) {
		    String did = AnalysisParameterTools.getDetectorId(lfn[i]);
			File analyze = new File(new File(elab.getProperties().getDataDir(), did), lfn[i] + ".analyze");
			CatalogEntry entry = elab.getDataCatalogProvider().getEntry(analyze.getName());
			CatalogEntry raw = elab.getDataCatalogProvider().getEntry(lfn[i]);
		    if (!analyze.exists()) {
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
	            request.setAttribute("raw", raw);
					%>
			            <tr>
               				<td align="left">${entry.tupleMap.school}</td>
			                <td align="center">${raw.tupleMap.startdate}</td>
							<td align="center">${raw.tupleMap.enddate}</td>
							<x:transform xslt="${stylesheet}">
								<%
									String str;
									while((str = br.readLine()) != null){
										//EPeronja-03/26/2013: Bug417- data file stats page: gatewidth
										//This is ugly but I do not want to mess with the metadata saving above
										//Code saves gatewidth as int and but when 0, we want to display N/A
										if (str.trim().equals("<gatewidth>0</gatewidth>")) {
											str = "     <gatewidth>N/A</gatewidth>";
										}
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
