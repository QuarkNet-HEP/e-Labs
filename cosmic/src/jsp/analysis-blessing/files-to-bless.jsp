<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<% 
MultiQueryElement and = new In(); 
and.add(new Equals("type", "split"));
and.add(new Equals("project", "cosmic"));
and.add(new Equals("blessedstatus", "awaiting"));
and.add(new Equals("group", user.getGroup().getName()));

ResultSet searchResults = elab.getDataCatalogProvider().runQuery(and);


%>
    
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Files Awaiting Blessing</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<h1>Files Awaiting Blessing</h1>
<p>Certify that your detector appears to be operating normally and your files appear to be good.</p>

	<table class="blessing-table">
		<tr>
			<th>Candidate File</th>
			<th>Golden File</th>
			<th>&nbsp;</th>
		</tr>
		<c:forEach items="${searchResults}" var="entry">
			<c:set var="run" value="${entry.value}"/>
			<%
				CatalogEntry ce = (CatalogEntry) pageContext.getAttribute("ce");
				Date fileStartDate = (Date) ce.getTupleValue("startdate");
				Date geoStartDate, geoEndDate; 
				// iterate through geometry to get start/end date :(

				// String goldenFileName = Bless.getGoldenFileName(elab, (Integer) ce.getTupleValue("detectorid"), startDate, endDate);
				String goldenFileName = "";
				//get associated golden file, too. 
			%>
			<tr>
				<td><%= ce.getTupleValue("starttime").toString() %></td>
				<td>(Pending)</td>
				<td><a href="compare.jsp?file1=<%= goldenFileName %>&amp;file2="<%= ce.getLFN() %>">Examine This File</a></td>
			</tr>
			
		</c:forEach>
		
		<!-- Quick demo test -->
		<tr>
			<td>14 May 2011 10:20 UTC</td>
			<td><strong>No golden file for geometry configuration, please <a href="golden.jsp?file=FOO">choose one now</a></strong></td>
			<td></td>
		</tr>
		<tr>
			<td>13 June 2011 10:20 UTC</td>
			<td><a href="chart.jsp?file=FOO">10 June 2011 10:20 UTC</a></td>
			<td><a href="compare.jsp?file1=FOO&file2=BAR">Inspect</a></td>
		</tr>
		<tr>
			<td>14 June 2011 10:20 UTC</td>
			<td><a href="chart.jsp?file=FOO">10 June 2011 10:20 UTC</a></td>
			<td><a href="compare.jsp?file1=FOO&file2=BAR">Inspect</a></td>
		</tr>
		
		
		
	</table>

		 	</div>
		</div>
	</body>
</html>