<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Choose data for shower study</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	
	<body id="shower" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-data.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
				
<h1>Choose data for shower study.</h1>

<table border="0" id="main">
	<tr>
		<td id="center">
			<div id="left">
				<jsp:include page="../data/search-control.jsp">
					<jsp:param name="type" value="split"/>
				</jsp:include>
				<form action="analysis.jsp" method="get" id="results-form">
					<jsp:useBean scope="request" 
						class="gov.fnal.elab.datacatalog.MultiSelectStructuredResultSetDisplayer" 
						id="searchResultsDisplayer"/>
					<div class="search-results">
						<jsp:include page="../data/search-results.jsp"/>
					</div>
					<div id="right">
						<%@ include file="help.jsp" %>
						<div id="analyze" class="study-right">
							<h2>Analyze</h2>
							<input type="submit" value="Run shower study"/>
						</div>
						<%@ include file="../data/legend.jsp" %>
					</div>
				</form>
			</div>
		</td>
	</tr>
</table>


			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>
