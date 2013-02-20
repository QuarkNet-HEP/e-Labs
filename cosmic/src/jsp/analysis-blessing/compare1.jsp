<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>   
<%
String file = request.getParameter("file");

if (StringUtils.isBlank(file)) {
    throw new ElabJspException("Missing file name.");
}

VDSCatalogEntry entry = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(file);
if (entry == null) {
    throw new ElabJspException("No information about " + file + " found.");
}
entry.sort(); 
request.setAttribute("e", entry);

%>
   
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis List</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>

		<title>Data Blessing</title>
	</head>
	<body class="upload">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.errorbars.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.axislabels.js"></script>
				<script type="text/javascript" src="../include/jquery/flot/jquery.flot.symbol.js"></script>
				<script type="text/javascript" src="../include/excanvas.min.js"></script>
				<script type="text/javascript" src="blessing.js"></script>

				<script type="text/javascript">
				$(document).ready(function() {
					$.ajax({
						url: "get-data.jsp?file=<%= file %>",
						processData: false,
						dataType: "json",
						type: "GET",
						success: onDataLoad1
					});
				}); 
				
				function popUpClosed() {
					window.location.reload();
				}
				</script>
	
				<h1>Data Blessing Test -
				<%= entry.getTupleValue("school") %>, <%= entry.getTupleValue("city") %> - <%= entry.getTupleValue("state") %>
				</h1>
				<h2>Control Registers</h2>
				CR0: <strong><%= entry.getTupleValue("ConReg0") != null? entry.getTupleValue("ConReg0") : "Unknown" %></strong>,
				CR1: <strong><%= entry.getTupleValue("ConReg1") != null? entry.getTupleValue("ConReg1") : "Unknown" %></strong>,
				CR2: <strong><%= entry.getTupleValue("ConReg2") != null? entry.getTupleValue("ConReg2") : "Unknown" %></strong>,
				CR3: <strong><%= entry.getTupleValue("ConReg3") != null? entry.getTupleValue("ConReg3") : "Unknown" %></strong><br />
				<h2>Rates</h2>
				<div id="channels" style="background-color:#FFFFFF">
					<div id="channelChart" style="width:750px; height:250px; text-align: left;"></div>
					<div id="channelChartLegend" style="width: 750px"></div>        
				</div>
				
				<h2>Trigger Rate</h2>
				<div id ="triggerChart" style="width:750px; height:250px; text-align: left;"></div>
	
				<h2>Visible GPS Satellites</h2>
				<div id="satChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Voltage</h2>
				<div id="voltChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Temperature</h2>
				<!-- control added to change axes values -->
				<div id="tempChart" style="width:750px; height:250px; text-align: left;"></div>

				<h2>Barometric Pressure</h2>
				<div id="pressureChart" style="width:750px; height:250px; text-align: left;"></div>
	
		 	</div>
		</div>
	</body>
</html>